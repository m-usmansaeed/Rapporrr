//
//  SuccessRapporVC.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 27/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "SuccessRapporVC.h"
#import "JoinCompanyVC.h"

@interface SuccessRapporVC ()

@end

@implementation SuccessRapporVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    
    CGRect rect = self.successMessageView.frame;
    rect.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height + 2;
    self.successMessageView.frame = rect;
    
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

- (IBAction)thanksPressed:(id)sender {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        //Do not forget to import AnOldViewController.h
        if ([controller isKindOfClass:[JoinCompanyVC class]]) {
            
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
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
