//
//  WelcomeRapporrVC.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 19/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "WelcomeRapporrVC.h"

@interface WelcomeRapporrVC ()

@end

@implementation WelcomeRapporrVC

- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

/*!
 * Called by Reachability whenever status changes.
 
 */

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
