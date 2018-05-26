//
//  VerifyRapporrVC.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 22/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "VerifyRapporrVC.h"
#import "NetworkManager.h"
#import "RapporrManager.h"
#import "VerifiedCompanyModel.h"
#import "MessageVC.h"


@interface VerifyRapporrVC ()

@end
#define MAX_LENGTH 6
@implementation VerifyRapporrVC
@synthesize cModel;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    if(cModel.companyName.length > 20){
        [_companyName setFrame:CGRectMake(_companyName.frame.origin.x, 25, _companyName.frame.size.width, 58)];
    }
    
    _companyName.text = cModel.companyName;
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(limitTextField) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self initViews];
    
}

- (void) initViews {
    _verificationCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Your verification code" attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField canResignFirstResponder]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    // add your method here
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.view removeGestureRecognizer:tap];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField  {
    [self addTouchGestureForKeyboard];
    
}

-(void)limitTextField
{
    if(_verificationCode.text.length >= 6) {
        _verificationCode.text = [_verificationCode.text substringToIndex:6];
        _verifyBtn.backgroundColor = [UIColor colorWithRed:0.996 green:0.341 blue:0.129 alpha:1.0];
        _verifyBtn.enabled = true;
    }
    else {
        _verifyBtn.enabled = false;
        _verifyBtn.backgroundColor = [UIColor lightGrayColor];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= MAX_LENGTH && range.length == 0)
    {
        _verifyBtn.backgroundColor = [UIColor colorWithRed:0.996 green:0.341 blue:0.129 alpha:1.0];
        _verifyBtn.enabled = true;
        return NO; // return NO to not change text
    }
    else
    {
        _verifyBtn.enabled = false;
        _verifyBtn.backgroundColor = [UIColor lightGrayColor];
        return YES;
    }
}
- (void)addTouchGestureForKeyboard {
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}
-(void)dismissKeyboard {
    [self.view endEditing:true];
}

- (IBAction)verifyBtnPressed:(id)sender {
    [self.view endEditing:true];
        
    NSDictionary *paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:cModel.hostID,@"hostId",_verificationCode.text,@"pincode",@"OS_IOS",@"platform", nil];
    
    if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {

    [NetworkManager validatePinCode:URI_VALIDATE_CODE parameters:paramsToBeSent success:^(id data,NSString *timestamp) {
        
        [[CoreDataController sharedManager] removeAllUsers];
        [[CoreDataController sharedManager] removeAllMessageModel];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kfetchWithConversationTimestamp];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kfetchWithUserTimestamp];

        [[CoreDataController sharedManager] updateDeactiveCompanies];
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        VerifiedCompanyModel *vcModelTemp = [[VerifiedCompanyModel alloc] initWithDictionary:json];
        [[CoreDataController sharedManager] saveVerifiedCompany:vcModelTemp];
        [RapporrManager sharedManager].vcModel = vcModelTemp;
        //clear user Defaults
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"urlKey"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hubName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSegueWithIdentifier:@"mainTabBar" sender:self];
        
    }failure:^(NSError *error) {
        _invalidCodeView.hidden=false;
        NSLog(@"%@", error.description);
    }];
    }
    else{
        [appDelegate showUnavailablityAlert];
    }
}

- (IBAction)invalidCodeOkPressed:(id)sender {
    _invalidCodeView.hidden=true;
}


-(void)keyboardWillShow:(NSNotification *)notification {
    
    if(IS_IPHONE_4){
        CGRect rect = self.view.frame;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        rect.origin.y = -120;
        self.view.frame = rect;
        [UIView commitAnimations];
    }
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    if(IS_IPHONE_4){
        CGRect rect = self.view.frame;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        rect.origin.y = 0;
        self.view.frame = rect;
        [UIView commitAnimations];
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;

    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Network Status
-(void)didNetworkConnected:(AFNetworkReachabilityStatus)status;{
    self.seachabilityStatus = status;
    [RKDropdownAlert dismissAllAlert];

}

-(void)didNetworkDisconnected:(AFNetworkReachabilityStatus)status;{
    self.seachabilityStatus = status;
    [RKDropdownAlert dismissAllAlert];
    [appDelegate showAlertView];
}



@end
