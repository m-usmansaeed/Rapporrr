//
//  InviteNewUserVC.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 26/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "InviteNewUserVC.h"

@interface InviteNewUserVC ()

@end

@implementation InviteNewUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    

    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    [self initData];
    [self initViews];
    
    UITapGestureRecognizer *hideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:hideKeyboard];
    
}

- (void)hideKeyboard:(UITapGestureRecognizer*)sender {
    
    [self.view endEditing:YES];
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


#pragma mark -
#pragma mark Utility Methods

- (IBAction)countryCodeBtnPressed:(id)sender {
    
}

- (IBAction)invalidNumberOkPressed:(id)sender {
    _invalidNumView.hidden = true;
}

- (IBAction)btnBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)validateNumPressed:(id)sender {
    
    [self.view endEditing:true];
    NSString *number = [NSString stringWithFormat:@"%@%@",_countryCodeLbl.text,_numberTxt.text];
   __block NSString *name = [NSString stringWithFormat:@"%@", self.lblUserName.text];
    
    NSDictionary *param = @{
                            @"name": [NSString stringWithFormat:@"%@",name],
                            @"phone": [NSString stringWithFormat:@"%@",number],
                            @"organisationId":[RapporrManager sharedManager].vcModel.orgId,
                            @"invitername":[RapporrManager sharedManager].vcModel.userName
                            };
    
    
    __weak __block typeof(self) weakself = self;
    
    
     if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
    [NetworkManager inviteUser:param success:^(id data,NSString *timestamp) {
            
        NSDictionary *dict = (NSDictionary *)data;

        if (dict[@"error"]) {
            
            [self setUpAlertView];
            _customAlert.isButtonSwitch = YES;
            _customAlert.alertTag = 1000;
            _customAlert.alertType = kAlertTypeMessage;
            [_customAlert showPopUpInView:self.view withMessage:@"Number already in use" andDescription:dict[@"error"]];
        }else{
            [weakself.navigationController.view makeToast:[NSString stringWithFormat:@"%@ was successfully added as a contact.",name]];

            [self.delegate didNewUserAdded];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",[error description]);
    }];
     }else{
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
    
    if(IS_IPHONE_4){
        CGRect rect = self.view.frame;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        rect.origin.y = -50;
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
    
    self.navigationController.tabBarController.tabBar.hidden = NO;
    [self.view endEditing:YES];


}


- (void) setUpAlertView {
    _customAlert = [[RapporrAlertView alloc] init];
    [_customAlert setDelegate:(id)self];
}

-(void)RapporrAlertOK:(id)sender{
    
    [_customAlert removeCustomAlertFromViewInstantly];
    
}


-(void)RapporrAlertCancel{
    [_customAlert removeCustomAlertFromViewInstantly];
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
