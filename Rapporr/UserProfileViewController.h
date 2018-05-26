//
//  UserProfileViewController.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 24/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConversationUser.h"
#import "ConversationDetailVC.h"
#import "RapporrAlertView.h"
#import "UserProfileCell.h"

@protocol UserProfileViewControllerDelegate <NSObject>

-(void)didUpdatedUserSuccess:(ConversationUser *)user;
-(void)didDeactivateUserSuccess:(ConversationUser *)user;

@end

@interface UserProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
    
    NSString *phoneNumStr;
    NSString *nameStr;
    NSString *roleStr;
    NSString *titleStr;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;



@property (nonatomic, retain) IBOutlet UITextField *txtField;
@property (strong,nonatomic) NSMutableDictionary *userValues;
@property (strong, nonatomic) NSMutableArray *conversations;

- (IBAction)btnSendMessage:(id)sender;
- (IBAction)btnMakeCall:(id)sender;
- (IBAction)btnEditProfile:(id)sender;
- (IBAction)btnBack:(id)sender;

@property(strong, nonatomic) ConversationUser *user;
@property (nonatomic, strong) RapporrAlertView *customAlert;
@property (nonatomic, weak) id<UserProfileViewControllerDelegate>delegate;

@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;


@property(nonatomic) BOOL isDoneEditing;

@end
