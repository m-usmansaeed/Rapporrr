//
//  CompanySettingsVC.h
//  Rapporr
//
//  Created by Rapporr-Dev-OR on 17/06/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HubUrlDelegate <NSObject>
-(void)didChangeCompanyUrl:(NSString *)hubUrl;
@end

@interface CompanySettingsVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *urlField;
@property (weak, nonatomic) IBOutlet UITextField *hubNameField;
@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;

@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (nonatomic, strong) RapporrAlertView *customAlert;

@property (weak, nonatomic) id<HubUrlDelegate>delegate;
@end
