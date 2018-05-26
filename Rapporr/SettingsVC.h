//
//  SettingsVC.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 17/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditProfileVC.h"

@interface SettingsVC : UIViewController<RapporrAlertViewDelegate,ProfilePictureDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgViewUserProfile;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedLanguage;
@property (weak, nonatomic) IBOutlet UIView *adminSettingsView;

@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;
@property (nonatomic, strong) RapporrAlertView *customAlert;
@property (nonatomic, strong) ActionSheet *actionSheet;

@property (nonatomic, weak) IBOutlet UISwitch *notificationSwitch;
- (IBAction)btnBack:(id)sender;

@end
