//
//  WelcomeVC.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 15/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "EMCCountry.h"
#import <UIKit/UIKit.h>
#import "EMCCountryPickerController.h"

@interface WelcomeVC : UIViewController<UITextFieldDelegate,EMCCountryDelegate> {
    EMCCountry *selectedCountry;
    UITapGestureRecognizer *tap;
    NSString *userPhoneNumber;

    
}
    
@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;
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

@end
