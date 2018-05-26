//
//  CreateConversationVC.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 14/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InternetAvailability.h"
#import "RKDropdownAlert.h"
#import "CreateTeamCollectionCell.h"
#import "CreateTeamCell.h"
#import "ConversationDetailVC.h"


@interface CreateConversationVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate>{

    ListType listType;
    CONTENTType contentType;


}

@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
- (IBAction)btnCancel:(id)sender;


@property (weak, nonatomic) IBOutlet UIView* SegmentContainer;
@property (weak, nonatomic) IBOutlet UISearchBar *tableSearchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *collectionSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (weak, nonatomic) IBOutlet UIView *tableContainerView;
@property (weak, nonatomic) IBOutlet UIView *collectionContainerView;

@property (weak, nonatomic) IBOutlet UIButton *listBtn;
@property (weak, nonatomic) IBOutlet UIButton *gridBtn;
@property (weak, nonatomic) IBOutlet UITextFieldLimit *txtFieldTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblCounter;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;



- (IBAction)listPressed:(id)sender;
- (IBAction)gridPressed:(id)sender;
- (IBAction)btnDone:(id)sender;


@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *sectionizedUsers;
@property (nonatomic, strong) NSMutableArray *tableResults;
@property (nonatomic, strong) NSMutableArray *teams;
@property (nonatomic, strong) NSMutableArray *teamSectionized;
@property (nonatomic, strong) NSMutableArray *collectionResults;

@property (nonatomic, strong) NSMutableArray *dataArray;


@property (nonatomic)     BOOL isSearching;
@property (nonatomic, strong) HMSegmentedControl *contactSegment;
@property (nonatomic) BOOL isKeyboardActive;
@property (nonatomic, strong) RapporrAlertView *customAlert;
@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;


@end
