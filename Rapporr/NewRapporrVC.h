//
//  NewRapporrVC.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 19/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMCCountry.h"
#import "EMCCountryPickerController.h"

@interface NewRapporrVC : UIViewController<UITextFieldDelegate,EMCCountryDelegate> {
    EMCCountry *selectedCountry;
    UITapGestureRecognizer *tap;
    BOOL validPhoneNum;
    BOOL validInfoHub;
    
}
    
@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;


@property (strong, nonatomic) IBOutlet UITextField *organisationTxt;
@property (strong, nonatomic) IBOutlet UITextField *adminTxt;
@property (strong, nonatomic) IBOutlet UITextField *adminNumTxt;
@property (strong, nonatomic) IBOutlet UITextField *adminEmailTxt;
@property (strong, nonatomic) IBOutlet UITextField *infoHubTxt;
@property (strong, nonatomic) IBOutlet UIButton    *countryCodeTb;
@property (strong, nonatomic) IBOutlet UIButton    *finishBtn;

- (IBAction)countryPressed:(id)sender;
- (IBAction)finishPressed:(id)sender;



@end
