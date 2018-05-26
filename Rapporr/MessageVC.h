//
//  MessageVC.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 06/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"
#import "VCFloatingActionButton.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Utils.h"
#import "SWTableViewCell.h"
#import "UIScrollView+FloatingButton.h"
#import "RapporrAlertView.h"
#import "ConversationDetailVC.h"
#import "CompanyModel.h"
#import "WelcomeRapporrVC.h"
#import "JoinCompanyVC.h"

@interface MessageVC : UIViewController<floatMenuDelegate,UISearchDisplayDelegate, UISearchBarDelegate,MEVFloatingButtonDelegate,SWTableViewCellDelegate,RapporrAlertViewDelegate,UITableViewDelegate> {
   
    NSArray *currencies;
    NSMutableArray *conversations;
    NSMutableArray *messagesDictArray;
    NSMutableArray *messagesDictArrayforSearch;
    NSMutableArray *users;
    NSMutableArray *searchResults;
    UITableView *searchTblView;
//    NSString *timeStamp;

    NSString *userTimeStamp;
    NSMutableArray *headersArray;
    BOOL isPinnedPressed;
    BOOL isSearching;
    MessageModel *selectedMessageModel;
    int alertViewTag;
    
    int totalPages;
    int currentPage;
    
    IBOutlet UIView *overlay;

}



@property (strong, nonatomic) NSManagedObjectContext *objectController;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *mainTblView;
@property (strong, nonatomic) VCFloatingActionButton *addMenuButton;
@property (nonatomic, strong) RapporrAlertView *customAlert;
@property (nonatomic, strong) VerifiedCompanyModel *vcModel;
@property (nonatomic, strong) UIRefreshControl *refresh;
@property (nonatomic, strong) MEVFloatingButton *btnScrollToTop;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

- (IBAction)btnChangeCompany:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *downArrowImageView;

@property (nonatomic) AFNetworkReachabilityStatus reachabilityStatus;

@property (weak, nonatomic) IBOutlet UIView *actionSheetButtonView;
@property (weak, nonatomic) IBOutlet UIView *actionBgView;

- (IBAction)actionSheetButtons:(id)sender;
- (IBAction)btnHideActionSheet:(id)sender;
- (void) getMessageList;




@end
