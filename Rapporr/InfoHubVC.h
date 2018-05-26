//
//  InfoHubVC.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 17/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanySettingsVC.h"
@interface InfoHubVC : UIViewController


@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UIButton *home;
@property (weak, nonatomic) IBOutlet UIButton *refresh;
@property (weak, nonatomic) IBOutlet UIButton *forward;

@property (strong, nonatomic) NSString *urlKey;
@property (strong, nonatomic) NSString *hubName;

@end
