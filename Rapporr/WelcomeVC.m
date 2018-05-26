//
//  WelcomeVC.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 15/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "Utils.h"
#import "WelcomeVC.h"
#import "NetworkManager.h"
#import "NBPhoneNumberUtil.h"
#import "JoinCompanyVC.h"

@interface WelcomeVC ()

@end

@implementation WelcomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    [self initData];
    [self initViews];

}

- (void) initData {
    selectedCountry = [[EMCCountry alloc] initWithCountryCode:@"AU"];
}

- (void) initViews {
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    [_numberTxt addTarget:self action:@selector(updateButtonUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark Utility Methods

- (IBAction)countryCodeBtnPressed:(id)sender {
    
}

- (IBAction)invalidNumberOkPressed:(id)sender {
    _invalidNumView.hidden = true;
}
- (IBAction)validateNumPressed:(id)sender {
    
    [self.view endEditing:true];
    NSString *number = [NSString stringWithFormat:@"%@%@",_countryCodeLbl.text,_numberTxt.text];
   
    NSLog(@"%ld",(long)self.seachabilityStatus);
    
       if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
    [NetworkManager validateMobileNumber:@"" parameters:number success:^(id data, NSString *timestamp) {
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        userPhoneNumber = [json objectForKey:@"phone_number"];
        if(userPhoneNumber) {
            [self performSegueWithIdentifier:@"newCompanySegue" sender:self];
        }
        else {
            _invalidNumView.hidden = false;
        }
        
    }failure:^(NSError *error) {
        NSLog(@"Error");
    }];}else{
        [appDelegate showUnavailablityAlert];
    }
   
}

- (IBAction)learnMoreBtnPressed:(id)sender {

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
- (void)addTouchGestureForKeyboard {
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}
-(void)dismissKeyboard {
    [self.view endEditing:true];
}


- (void)updateButtonUsingContentsOfTextField:(id)sender {
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:_numberTxt.text
                                 defaultRegion:selectedCountry.countryCode error:&anError];
    if (anError == nil) {
        if([phoneUtil isValidNumber:myNumber]) {
            _validateNumBtn.enabled = true;
            _validateNumBtn.backgroundColor = [UIColor clearColor];
            [_validateNumBtn setBackgroundImage:[UIImage imageNamed:@"btnBg"] forState:UIControlStateNormal];
        }
        else {
            _validateNumBtn.enabled = false;
            _validateNumBtn.backgroundColor = [UIColor lightGrayColor];
            [_validateNumBtn setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }
}

- (void)countryController:(id)sender didSelectCountry:(EMCCountry *)chosenCity
{
    self.countryLbl.text = chosenCity.countryName;
    self.countryCodeLbl.text = [Utils getTelephonicCountryCode:chosenCity.countryCode];
    selectedCountry = chosenCity;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self updateButtonUsingContentsOfTextField:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"openCountryPicker"])
    {
        EMCCountryPickerController *countryPicker = segue.destinationViewController;
        countryPicker.showFlags = true;
        countryPicker.countryDelegate = self;
        countryPicker.drawFlagBorder = true;
        countryPicker.flagBorderColor = [UIColor grayColor];
        countryPicker.flagBorderWidth = 0.5f;
        countryPicker.flagSize = 30;
    }
    else if ([[segue identifier] isEqualToString:@"newCompanySegue"]) {
        
        JoinCompanyVC *destSegue = [segue destinationViewController];
        [[NSUserDefaults standardUserDefaults] setObject:userPhoneNumber forKey:@"UserPhoneNumber"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        destSegue.userPhoneNumber = userPhoneNumber;
    }
}

-(void)keyboardWillShow:(NSNotification *)notification {
    
    if(IS_IPHONE_4 || IS_IPHONE_5){
    CGRect rect = self.view.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    rect.origin.y = -120;
    self.view.frame = rect;
        [UIView commitAnimations];
    }

}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    if(IS_IPHONE_4 || IS_IPHONE_5){
    CGRect rect = self.view.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    rect.origin.y = 0;
    self.view.frame = rect;
    [UIView commitAnimations];
    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
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
