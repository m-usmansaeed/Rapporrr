//
//  CreateTeamVC.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 25/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConversationUser.h"
#import "DataManager.h"
#import "UITextFieldLimit.h"
#import "Utils.h"
#import "HMSegmentedControl.h"



@protocol CreateTeamVCDelegate <NSObject>

-(void)didTeamCreatedSuccessfully;
-(void)didTeamUpdatedSuccessfully:(TeamModel *)team;

@end

@interface CreateTeamVC : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate>{
    
    BOOL isSearchBecomeActive;
    ListType listType;
    CONTENTType contentType;
    

}

@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;
@property (weak, nonatomic) IBOutlet UILabel *navTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *tableContainer;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *collectionSearchBar;
@property (weak, nonatomic) IBOutlet UIButton *listBtn;
@property (weak, nonatomic) IBOutlet UIButton *gridBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;


@property (weak, nonatomic) IBOutlet UIView   *detailsView;
@property (weak, nonatomic) IBOutlet UIButton *btnEditTeam;
- (IBAction)btnEditTeam:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTeamTitle;

@property (weak, nonatomic) IBOutlet UIImageView *adminImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblAdminName;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UICollectionView *teamDetailsCollectionView;

@property (nonatomic, strong) TeamModel *team;

@property (nonatomic, strong) NSMutableArray *userList;
@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) NSMutableArray *sectionizedUsers;
@property (nonatomic, strong) NSMutableArray *resultUserList;
@property (nonatomic, strong) NSMutableArray *resultCollection;

@property (strong, nonatomic) IBOutlet UIView *scrollContainer;
@property (strong, nonatomic) IBOutlet UIScrollView *innerScroll;
@property (strong, nonatomic) IBOutlet UICollectionView *innerCollectionView;
@property (weak, nonatomic) IBOutlet UITextFieldLimit *txtFieldTeamTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblCounter;
@property (nonatomic, strong) RapporrAlertView *customAlert;


- (IBAction)btnBack:(id)sender;

- (IBAction)listPressed:(id)sender;
- (IBAction)gridPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnDoneMakingTeam;
- (IBAction)btnDoneMakingTeam:(id)sender;


@property (weak,nonatomic) id<CreateTeamVCDelegate>delegate;
@property (nonatomic) BOOL isEditingTeam;

@property (nonatomic) float innerCollectionViewContentSizeHeight;


@property (nonatomic) CGFloat yContentOffset;
@property (nonatomic) CGFloat oldYContentOffset;
@property (nonatomic) BOOL isConfirmEdit;

@property (weak, nonatomic) IBOutlet UIView* contactSegmentContainer;
@property (nonatomic)     BOOL isSearching;


@property (nonatomic, strong) HMSegmentedControl *contactSegment;
@property (nonatomic) BOOL isMyTeamSelected;
@property (nonatomic) BOOL isCompanySelected;

@end
