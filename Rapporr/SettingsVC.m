//
//  SettingsVC.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 17/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "SettingsVC.h"
#import "WelcomeRapporrVC.h"
#import "WebViewVC.h"

@interface SettingsVC (){
    
    ConversationUser *user;
    NSString *urlToOpen;
    NSString *webViewTitle;
    NSMutableArray *pingTime;
    
}
@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;
    [self adjustTabBarImageOffset];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 600)];
    user = [[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId];
    [self setUpAlertView];
    
    if(user.avatarUrl.length > 1) {
        NSURL *imageUrl = [NSURL URLWithString:user.avatarUrl];
        UIImage *placeholder = [UIImage imageNamed:@"placeholder_user"];
        if([Utils hasCachedImage]){
            placeholder = [Utils loadImage];
        }
        [self.imgViewUserProfile setImageWithURL:imageUrl placeholderImage:placeholder options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    else {
        [self.imgViewUserProfile setImageWithString:user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
    }
    pingTime = [[NSMutableArray alloc] init];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.swipeBackEnabled = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[RapporrManager sharedManager].vcModel.uType isEqualToString:kUSER_TYPE_ADMIN]){
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:143.0 onView:self.adminSettingsView completion:^(BOOL finished) {
            }];
        }];
    }
    self.navigationController.tabBarController.tabBar.hidden = NO;
    [RKDropdownAlert dismissAllAlert];
    NSString *selectedLanguage = [[NSUserDefaults standardUserDefaults] valueForKey:@"langEngName"];
    self.lblSelectedLanguage.text = [NSString validStringForObject:selectedLanguage];
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;
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

#pragma mark Alert Delegates
- (void) setUpAlertView {
    _customAlert = [[RapporrAlertView alloc] init];
    [_customAlert setDelegate:(id)self];
}

-(void)RapporrAlertOK:(id)sender{
    if(self.customAlert.alertTag == 998){
        self.notificationSwitch.on = NO;
    }
    else if(self.customAlert.alertTag == 999){
        self.notificationSwitch.on = YES;
    }
    [self.customAlert removeCustomAlertFromViewInstantly];
}

-(void)RapporrAlertCancel{
    NSLog(@"");
    [self.customAlert removeCustomAlertFromViewInstantly];
}

-(void)RapporrAlertCancel:(id)sender{
    NSLog(@"");
    [self.customAlert removeCustomAlertFromViewInstantly];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"editProfile"]) {
        EditProfileVC *destSegue = [segue destinationViewController];
        destSegue.delegate = self;
    }
    else if([[segue identifier] isEqualToString:@"pushToWebView"]) {
        WebViewVC *destSegue = [segue destinationViewController];
        destSegue.baseURL = urlToOpen;
        destSegue.headerString = webViewTitle;
    }
}

#pragma mark ButtonActions

-(IBAction)notificationValueChanged:(id)sender{
    if([self.notificationSwitch isOn]){
        _customAlert.alertTag = 998;
        _customAlert.isButtonSwitch = YES;
        [_customAlert showCustomAlertInView:self.view withMessage:NSLocalizedString(@"Confirmation!",nil) andDescription:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to turn off notifications for Rapporr?",nil)] setOkTitle:@"NO" setCancelTitle:@"YES"];
    }
    else{
        _customAlert.alertTag = 999;
        _customAlert.isButtonSwitch = YES;
        [_customAlert showCustomAlertInView:self.view withMessage:NSLocalizedString(@"Confirmation!",nil) andDescription:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to turn on notifications for Rapporr?",nil)] setOkTitle:@"NO" setCancelTitle:@"YES"];
    }
}

- (IBAction)btnBack:(id)sender {
}

-(IBAction)editProfileTapped:(id)sender{
    [self performSegueWithIdentifier:@"editProfile" sender:nil];
}

-(IBAction)companySettings:(id)sender{
    if ([[RapporrManager sharedManager].vcModel.uType isEqualToString:kUSER_TYPE_ADMIN]) {
        //perform segue
        [self performSegueWithIdentifier:@"companySettings" sender:nil];
    }
    else{
        [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Admin access only",nil) andDescription:NSLocalizedString(@"Sorry you don't have access rights to the Company Settings screen",nil)];
    }
}

-(IBAction)helpAndSupportTapped:(id)sender{
    self.actionSheet = [self.storyboard instantiateViewControllerWithIdentifier:@"ActionSheet"];
    self.actionSheet.items = [@[@"Terms of Use",@"Privacy Policy",@"Help"] mutableCopy];
    self.actionSheet.images = [@[@"termsofuse_icon",@"privacypolicy_icon",@"help_icon"] mutableCopy];
    
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self.actionSheet showActionSheet:top.view withTitle:@"Help & Support"];
    __weak __typeof(self)weakSelf = self;
    [self.actionSheet setItemSelectedAtIndexPath:^(NSIndexPath *indexPath){
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if(indexPath.row == 0){
            urlToOpen = TERMS_URL;
            webViewTitle = @"Terms of Use";
        }
        else if(indexPath.row == 1){
            urlToOpen = PRIVACY_URL;
            webViewTitle = @"Privacy Policy";
        }
        else if(indexPath.row == 2){
            urlToOpen = HELP_URL;
            webViewTitle = @"Help";
        }
        [strongSelf performSegueWithIdentifier:@"pushToWebView" sender:nil];
        [strongSelf.actionSheet hide];
        
    }];
}

-(IBAction)aboutAndInfo:(id)sender{
    self.actionSheet = [self.storyboard instantiateViewControllerWithIdentifier:@"ActionSheet"];
    self.actionSheet.items = [@[@"Network Test",@"System Information"] mutableCopy];
    self.actionSheet.images = [@[@"network_icon",@"info_icon"] mutableCopy];
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self.actionSheet showActionSheet:top.view withTitle:@"About/Info"];
    __weak __typeof(self)weakSelf = self;
    [self.actionSheet setItemSelectedAtIndexPath:^(NSIndexPath *indexPath){
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if(indexPath.row == 0){
            [strongSelf pingCall];
        }
        else if(indexPath.row == 1){
            [strongSelf showAlertsystemInformation];
        }
        
        [strongSelf.actionSheet hide];
    }];
}

-(void)showAlertsystemInformation{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *userId = [RapporrManager sharedManager].vcModel.userId;
    NSString *hostId = [RapporrManager sharedManager].vcModel.hostID;
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *infoString = [NSString stringWithFormat:@"Host Id: %@\n User Id: %@\n Version: %@",hostId,userId,majorVersion];
    [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"System Information",nil) andDescription:infoString];
}

-(void)pingCall{
    [SVProgressHUD showWithStatus:@"Calculating..."];
    [pingTime removeAllObjects];
    [NetworkManager GETCall:URI_PING_CALL parameters:nil success:^(id data, NSString *timeStamp) {
        if(timeStamp){
            [pingTime addObject:timeStamp];
            [self pingCall2];
        }
    }failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

-(void)pingCall2{
    [NetworkManager GETCall:URI_PING_CALL parameters:nil success:^(id data, NSString *timeStamp) {
        if(timeStamp){
            [pingTime addObject:timeStamp];
            [self pingCall3];
        }
    }failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

-(void)pingCall3{
    [NetworkManager GETCall:URI_PING_CALL parameters:nil success:^(id data, NSString *timeStamp) {
        if(timeStamp){
            [pingTime addObject:timeStamp];
            [self pingCall4];
        }
    }failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

-(void)pingCall4{
    [NetworkManager GETCall:URI_PING_CALL parameters:nil success:^(id data, NSString *timeStamp) {
        if(timeStamp){
            [pingTime addObject:timeStamp];
            [self pingCall5];
        }
    }failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

-(void)pingCall5{
    [NetworkManager GETCall:URI_PING_CALL parameters:nil success:^(id data, NSString *timeStamp) {
        if(timeStamp){
            [SVProgressHUD dismiss];
            [pingTime addObject:timeStamp];
            [self calculatePing];
        }
    }failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

-(void)calculatePing{
    
    NSMutableArray *pingList = [[NSMutableArray alloc] init];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = 4;
    formatter.maximumFractionDigits = 4;
    formatter.usesSignificantDigits = NO;
    formatter.usesGroupingSeparator = NO;
    formatter.decimalSeparator = @".";

    
    for(int i = 0; i < pingTime.count; i++){
        NSArray *seperatedArray = [[pingTime objectAtIndex:i] componentsSeparatedByString:@":"];
        NSString *lastObj = [seperatedArray objectAtIndex:2];
        NSString* formattedNumber = [NSString stringWithFormat:@"%.06f", [lastObj floatValue]];
        [pingList addObject:formattedNumber];
    }
    
    for (int i = 1; i < pingList.count ; i++){
        float number = [[pingList objectAtIndex:i] floatValue];
        float number2 = [[pingList objectAtIndex:i - 1] floatValue];
        float resultNumber = number - number2;
        float numb = roundf(resultNumber*10000)/10000.0;
        if (numb < 0){
            continue;
        }
        [formatter stringFromNumber:[NSNumber numberWithFloat:numb]];
        [result addObject:[formatter stringFromNumber:[NSNumber numberWithFloat:numb]]];
    }
    
    NSString *joinedComponents = [result componentsJoinedByString:@"\n"];
    [_customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Ping Details",nil) andDescription:[NSString stringWithFormat:@"Ping Rate (Seconds)\n%@", joinedComponents]];
}

-(IBAction)createJoinTapped:(id)sender{
    self.actionSheet = [self.storyboard instantiateViewControllerWithIdentifier:@"ActionSheet"];
    self.actionSheet.items = [@[@"Join a Company",@"Create New Company"] mutableCopy];
    self.actionSheet.images = [@[@"logo",@"logo"] mutableCopy];
    
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self.actionSheet showActionSheet:top.view withTitle:@"Chnage Company"];
    __weak __typeof(self)weakSelf = self;
    [self.actionSheet setItemSelectedAtIndexPath:^(NSIndexPath *indexPath){
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if(indexPath.row == 0){
            
            JoinCompanyVC *joinCompanyVC = [strongSelf.storyboard instantiateViewControllerWithIdentifier:@"JoinCompanyVC"];
            joinCompanyVC.isPushedFromHome = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.navigationController.tabBarController.tabBar.hidden = YES;
                [strongSelf.navigationController pushViewController:joinCompanyVC animated:YES];
            });
            
        }else if(indexPath.row == 1){
            WelcomeRapporrVC *newRapporrVC = [strongSelf.storyboard instantiateViewControllerWithIdentifier:@"WelcomeRapporrVC"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.navigationController.tabBarController.tabBar.hidden = YES;
                [strongSelf.navigationController pushViewController:newRapporrVC  animated:YES];
            });
        }
        [strongSelf.actionSheet hide];
    }];
}

-(void)didChangeProfilePic:(NSString *)avatarUrl{
    NSURL *imageUrl = [NSURL URLWithString:avatarUrl];
    UIImage *placeholder = [Utils loadImage];
    [self.imgViewUserProfile setImageWithURL:imageUrl placeholderImage:placeholder options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
