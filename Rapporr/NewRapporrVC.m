//
//  NewRapporrVC.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 19/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "NewRapporrVC.h"
#import "NBPhoneNumberUtil.h"
#import "NetworkManager.h"
#import "DataManager.h"
#import "Utils.h"
#import "Constants.h"
#import "NSString+email.h"
@interface NewRapporrVC ()

@end

@implementation NewRapporrVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;
    
    
    [self initView];
    [self initData];
    
}
- (void)initView {
    [_adminNumTxt addTarget:self action:@selector(updateButtonUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged];
    _mainScrollView.contentSize = CGSizeMake(320, 745);
}

- (void)initData {
    selectedCountry = [[EMCCountry alloc] initWithCountryCode:@"AU"];
    NSString *countryCodeLbl = [Utils getTelephonicCountryCode:selectedCountry.countryCode];
    [_countryCodeTb setTitle:countryCodeLbl forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addTouchGestureForKeyboard {
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}
-(void)dismissKeyboard {
    [self.view endEditing:true];
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
#pragma mark Text Field Delegate and Helpher Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if([textField isEqual:_organisationTxt]){
        [self.adminTxt becomeFirstResponder];
    }else if([textField isEqual:_adminTxt]){
        [self.adminNumTxt becomeFirstResponder];
    }
    else if([textField isEqual:_adminEmailTxt]){
        [self.infoHubTxt becomeFirstResponder];
        
    }else if([textField isEqual:_infoHubTxt]){
        [textField resignFirstResponder];
    }
    
    
    //    if ([textField canResignFirstResponder]) {
    //        [textField resignFirstResponder];
    //    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField  {
    [self addTouchGestureForKeyboard];
    
    if(textField.tag > 3) {
        //        [self animateTextField:nil up:YES];
    }
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    // add your method here
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.view removeGestureRecognizer:tap];
    
    if(textField.tag > 3) {
        //        [self animateTextField:nil up:NO];
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 185; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Utility Methods

- (BOOL) validateFields {
    if(_organisationTxt.text.length >= 1) {
        if(_adminTxt.text.length >= 1) {
            if(validPhoneNum) {
                if([_adminEmailTxt.text isValidEmail]) {
                    if(_infoHubTxt.text.length > 0) {
                        NSString * urlString = _infoHubTxt.text;
                        urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
                        
                        
                        if([urlString isValidURL]) {
                            validInfoHub = true;
                            _infoHubTxt.text = urlString;
                            return true;
                        }
                        else {
                            [self showTostMsg:@"Info Hub information is not valid"];
                        }
                    }
                    else {
                        return true;
                    }
                }
                else {
                    [self showTostMsg:@"Admin email is not in valid format"];
                }
            }
            else {
                [self showTostMsg:@"Phone number is not in valid format"];
            }
        }
        else {
            [self showTostMsg:@"Please specify administrator name"];
        }
    }
    else {
        [self showTostMsg:@"Organization name cannot be empty"];
    }
    
    return false;
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)countryPressed:(id)sender {
}

- (IBAction)finishPressed:(id)sender {
    
    
    if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        
        
        if([self validateFields]) {
            NSString *phone = [NSString stringWithFormat:@"%@%@",_countryCodeTb.titleLabel.text,_adminNumTxt.text];
            NSString *hostID = [DataManager createNewHostFor:_organisationTxt.text];
            NSString *intranet;
            NSString *object;
            
            if(validInfoHub) {
                NSDictionary *intranetDict = [NSDictionary dictionaryWithObjectsAndKeys:_organisationTxt.text,@"name",_infoHubTxt.text,@"address",nil];
                intranet = [NSString stringWithFormat:@"%@", intranetDict];
                
                NSDictionary *objectDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Active",@"intranetDetails",intranet,@"intranet",nil];
                
                object = [NSString stringWithFormat:@"%@", objectDict];
                
            }
            NSDictionary *paramsToBeSent;
            
            if(intranet != nil) {
                paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:phone,@"phone",_adminTxt.text,@"name",@"0001",@"organisationId",_adminEmailTxt.text,@"email",_organisationTxt.text,@"company",hostID,@"host",intranet ,@"intranet",object,@"objects",nil];
            }
            else {
                paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:phone,@"phone",_adminTxt.text,@"name",@"0001",@"organisationId",_adminEmailTxt.text,@"email",_organisationTxt.text,@"company",hostID,@"host",nil];
            }
            
            [NetworkManager validatePinCode:URI_CREATE_RAPPORR parameters:paramsToBeSent success:^(id data, NSString *timestamp) {
                
                NSError* error;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSString *status = [json objectForKey:@"Status"];
                if([status isEqualToString:@"OK"]) {
                    //Success
                    [self performSegueWithIdentifier:@"rapporrSuccess" sender:self];
                    
                }
                
            }failure:^(NSError *error) {
                NSLog(@"Error");
            }];
        }
        else {
            
        }
    }
    else{
        [appDelegate showUnavailablityAlert];
        
    }
}

- (void)updateButtonUsingContentsOfTextField:(id)sender {
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:_adminNumTxt.text
                                 defaultRegion:selectedCountry.countryCode error:&anError];
    if (anError == nil) {
        if([phoneUtil isValidNumber:myNumber]) {
            validPhoneNum = true;
        }
        else {
            validPhoneNum = false;
        }
    }
}

- (void)countryController:(id)sender didSelectCountry:(EMCCountry *)chosenCity
{
    
    NSString *countryCodeLbl = [Utils getTelephonicCountryCode:chosenCity.countryCode];
    
    [_countryCodeTb setTitle:countryCodeLbl forState:UIControlStateNormal];
    
    selectedCountry = chosenCity;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"openCountryPicker"])
    {
        EMCCountryPickerController *countryPicker = segue.destinationViewController;
        
        // default values
        countryPicker.showFlags = true;
        countryPicker.countryDelegate = self;
        countryPicker.drawFlagBorder = true;
        countryPicker.flagBorderColor = [UIColor grayColor];
        countryPicker.flagBorderWidth = 0.5f;
        countryPicker.flagSize = 30;
    }
}

#pragma mark -
#pragma mark Show Toast Message

- (void) showTostMsg : (NSString*) message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    int duration = 1; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
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
