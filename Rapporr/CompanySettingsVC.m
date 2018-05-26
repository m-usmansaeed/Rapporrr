//
//  CompanySettingsVC.m
//  Rapporr
//
//  Created by Rapporr-Dev-OR on 17/06/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "CompanySettingsVC.h"

@interface CompanySettingsVC (){
    UIGestureRecognizer *tap;
    NSString *urlKey;
    NSString *hubName;
}
@end

@implementation CompanySettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.urlField.enabled = NO;
    self.hubNameField.enabled = NO;
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    [self setUpAlertView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;
    
    urlKey = [[NSUserDefaults standardUserDefaults]
              stringForKey:@"urlKey"];
    hubName = [[NSUserDefaults standardUserDefaults]
               stringForKey:@"hubName"];
    if((urlKey == nil || [urlKey isKindOfClass:[NSNull class]] || [urlKey isEqualToString:@""])){
        [self updateKeys];
    }
    else{
        [self updateText];
    }
}

#pragma mark DismissKeyboard
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)popVC:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)updateText{
    self.urlField.text = urlKey;
    self.hubNameField.text = hubName;
}

-(void)updatePlaceholder{
    [self.hubNameField setPlaceholder:hubName];
    [self.urlField setPlaceholder:urlKey];
}

#pragma mark CustomAlert Delegates
- (void) setUpAlertView {
    _customAlert = [[RapporrAlertView alloc] init];
    [_customAlert setDelegate:(id)self];
}

-(void)RapporrAlertOK:(id)sender{
    [self.customAlert removeCustomAlertFromViewInstantly];
}

-(void)RapporrAlertCancel{
}

-(void)RapporrAlertCancel:(id)sender{
}

-(void)updateKeys{
    if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        NetworkManager *nManager = [[NetworkManager alloc]init];
        [nManager getTeamsWithCompletion:^(BOOL success) {
            [SVProgressHUD dismiss];
            
            
            urlKey = [[NSUserDefaults standardUserDefaults]
                      stringForKey:@"urlKey"];
            hubName = [[NSUserDefaults standardUserDefaults]
                       stringForKey:@"hubName"];
            if((urlKey == nil || [urlKey isKindOfClass:[NSNull class]] || [urlKey isEqualToString:@""])){
                urlKey = @"www.google.com";
                hubName = @"Google";
                [self updatePlaceholder];
            }
            else{
                [self updateText];
            }
        }];
    }else{
        [appDelegate showUnavailablityAlert];
    }
}

-(IBAction)editButtonPressed:(id)sender{
    
    if([_editBtn.titleLabel.text isEqualToString:@"Edit"]){
        [self.editBtn setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
        self.hubNameField.enabled = YES;
        self.urlField.enabled = YES;
        [self.urlField becomeFirstResponder];
    }
    else{
        NSString *url = [[NSUserDefaults standardUserDefaults]
                         stringForKey:@"urlKey"];
        NSString *hubname = [[NSUserDefaults standardUserDefaults]
                             stringForKey:@"hubName"];
        if([self.urlField.text isEqualToString:url] && [self.hubNameField.text isEqualToString:hubname]){
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            if([self.urlField.text isEqualToString:@""] || ![self.urlField.text isValidURL]){
                [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Invalid Info Hub",nil) andDescription:NSLocalizedString(@"Please enter valid URL",nil)];
            }
            else{
                [self updateURLCall];
            }
        }
    }
}

-(void)updateURLCall{
    NSString *fullId = [NSString stringWithFormat:@"%@-%@",[RapporrManager sharedManager].vcModel.hostID,[RapporrManager sharedManager].vcModel.orgId];
    NSString *urlString = self.urlField.text;
    NSString *hubNameString = self.hubNameField.text;
    NSString *intranet = [@{@"name":hubNameString,@"address":urlString} jsonString];
    NSString *objects = [@{@"intranetDetails":@"Active",@"intranet":@{@"name":hubNameString,@"address":urlString}} jsonString];
    [SVProgressHUD show];
    
    NSDictionary *params = @{
                             @"fullid" : fullId,
                             @"objects" : objects,
                             @"intranet" : intranet
                             };
    [NetworkManager makePOSTCall:URI_UPDATE_URL_CALL parameters:params success:^(id data, NSString *timestamp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils saveUrlAndHubName:urlString hubname:hubNameString];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ChangeURLNotification"
             object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        });
    } failure:^(NSError *error) {
        
    }];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
