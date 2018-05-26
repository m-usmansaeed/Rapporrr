//
//  WebViewVC.h
//  Rapporr
//
//  Created by Rapporr-Dev-OR on 18/06/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewVC : UIViewController

@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSString *headerString;

@property (weak, nonatomic) IBOutlet UILabel *headerTitle;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UIButton *home;
@property (weak, nonatomic) IBOutlet UIButton *refresh;
@property (weak, nonatomic) IBOutlet UIButton *forward;
@end
