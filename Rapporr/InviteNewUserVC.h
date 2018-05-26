//
//  InviteNewUserVC.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 26/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import "NetworkManager.h"
#import "NBPhoneNumberUtil.h"
#import "JoinCompanyVC.h"
#import "EMCCountry.h"
#import "EMCCountryPickerController.h"

@protocol InviteNewUserVCDelegate <NSObject>

-(void)didNewUserAdded;

@end

@interface InviteNewUserVC : UIViewController<UITextFieldDelegate,EMCCountryDelegate> {
    EMCCountry *selectedCountry;
    UITapGestureRecognizer *tap;
    NSString *userPhoneNumber;
    
}

@property (weak, nonatomic) id<InviteNewUserVCDelegate>delegate;
@property (weak, nonatomic) IBOutlet UITextField *lblUserName;
@property (strong, nonatomic) IBOutlet UILabel     *countryLbl;
@property (strong, nonatomic) IBOutlet UITextField *numberTxt;
@property (strong, nonatomic) IBOutlet UIButton    *countryCodeBtn;
@property (strong, nonatomic) IBOutlet UIButton    *validateNumBtn;
@property (strong, nonatomic) IBOutlet UILabel     *countryCodeLbl;
@property (strong, nonatomic) IBOutlet UIView *invalidNumView;

- (IBAction)validateNumPressed:(id)sender;
- (IBAction)learnMoreBtnPressed:(id)sender;
- (IBAction)countryCodeBtnPressed:(id)sender;
- (IBAction)invalidNumberOkPressed:(id)sender;
- (IBAction)btnBack:(id)sender;

@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;
@property (nonatomic, strong) RapporrAlertView *customAlert;


@end
