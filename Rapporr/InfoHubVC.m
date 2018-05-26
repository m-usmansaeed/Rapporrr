//
//  InfoHubVC.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 17/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "InfoHubVC.h"

@interface InfoHubVC ()<UIWebViewDelegate>

@end

@implementation InfoHubVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self adjustTabBarImageOffset];
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;
    self.webView.delegate = self;
    self.urlKey = [[NSUserDefaults standardUserDefaults]
                   stringForKey:@"urlKey"];
    self.hubName = [[NSUserDefaults standardUserDefaults]
                    stringForKey:@"hubName"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveChangeURlRequest:)
                                                 name:@"ChangeURLNotification"
                                               object:nil];
    if((self.urlKey == nil || [self.urlKey isKindOfClass:[NSNull class]] || [self.urlKey isEqualToString:@""])){
        [self updateKeys];
    }
    [self loadRequestFromString:self.urlKey];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;
    [RKDropdownAlert dismissAllAlert];
}

- (void)loadRequestFromString:(NSString*)urlString
{
    
    NSURL *url;
    if ([urlString.lowercaseString hasPrefix:@"http://"] || [urlString.lowercaseString hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:urlString];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlString]];
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) adjustTabBarImageOffset {
    UITabBar *tabBar = self.navigationController.tabBarController.tabBar;
    [[tabBar.items objectAtIndex:0] setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [[tabBar.items objectAtIndex:1] setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [[tabBar.items objectAtIndex:2] setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [[tabBar.items objectAtIndex:3] setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    self.title = nil;
}

-(void)updateKeys{
    if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        NetworkManager *nManager = [[NetworkManager alloc]init];
        [nManager getTeamsWithCompletion:^(BOOL success) {
            [SVProgressHUD dismiss];
            self.urlKey = [[NSUserDefaults standardUserDefaults]
                           stringForKey:@"urlKey"];
            self.hubName = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"hubName"];
            if((self.urlKey == nil || [self.urlKey isKindOfClass:[NSNull class]] || [self.urlKey isEqualToString:@""])){
                self.urlKey = RAPPORR_DEFAULT_URL;
                [self loadRequestFromString:self.urlKey];
            }
            else{
                [self loadRequestFromString:self.urlKey];
            }            
        }];
    }else{
        [appDelegate showUnavailablityAlert];
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


-(IBAction)homePressed:(id)sender{
    [self loadRequestFromString:self.urlKey];
}

#pragma mark - Updating the UI
- (void)updateButtons
{
    NSLog(@"%s loading = %@", __PRETTY_FUNCTION__, self.webView.loading ? @"YES" : @"NO");
    self.forward.enabled = self.webView.canGoForward;
    self.back.enabled = self.webView.canGoBack;
    
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void) receiveChangeURlRequest:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    if ([[notification name] isEqualToString:@"ChangeURLNotification"])
    {
        self.urlKey = [[NSUserDefaults standardUserDefaults]
                       stringForKey:@"urlKey"];
        [self loadRequestFromString:self.urlKey];
    }
}

#pragma mark Hub Delegate
-(void)didChangeCompanyUrl:(NSString *)hubUrl{
    [self loadRequestFromString:self.urlKey];
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
