//
//  ContactsVC.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 17/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfileViewController.h"
#import "ConversationDetailVC.h"
#import "CreateTeamVC.h"
#import "InviteNewUserVC.h"

#import "HMSegmentedControl.h"
#import "UserContactTVCell.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ZLPeoplePickerViewController.h"


@interface ContactsVC : UIViewController<UISearchBarDelegate,UserContactTVCellDelegate,ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate,ZLPeoplePickerViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    NSString *userTimeStamp;
    ListType listType;
    NSMutableArray *conversations;
    BOOL isDataLoaded;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView* teamSegmentContainer;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *teamTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *teamSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *contactsFirstSegView;
@property (weak, nonatomic) IBOutlet UIView *contactsTeamSegView;
@property (weak, nonatomic) IBOutlet UIView *createNewTeamView;
@property (weak, nonatomic) IBOutlet UIView* contactSegmentContainer;


- (IBAction)segmentControl:(id)sender;


@property (nonatomic) NSIndexPath *expandIndexPath;

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *sectionizedUsers;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) NSMutableArray *teams;
@property (nonatomic, strong) NSMutableArray *teamSectionized;
@property (nonatomic, strong) NSMutableArray *teamSearchResults;

@property (nonatomic, strong) UIRefreshControl *refresh;
@property (nonatomic, strong) UIRefreshControl *refreshTeams;

@property (nonatomic, strong) VerifiedCompanyModel *vcModel;

@property (nonatomic) BOOL isMyTeamSelected;
@property (nonatomic) BOOL isCompanySelected;

@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, strong) ZLPeoplePickerViewController *peoplePicker;

- (IBAction)createTeam:(id)sender;
@property (nonatomic, strong) RapporrAlertView *customAlert;
@property (nonatomic, strong) APContact *selectedContact;
@property (nonatomic, strong) TeamModel *selectedTeam;
@property (nonatomic)     BOOL isSearching;


@property (weak, nonatomic) IBOutlet UIView *actionSheetButtonView;
@property (weak, nonatomic) IBOutlet UIView *actionBgView;

- (IBAction)actionSheetButtons:(id)sender;
- (IBAction)btnHideActionSheet:(id)sender;
@property (strong ,nonatomic) NSMutableDictionary *cellHeighs;
@property (nonatomic) BOOL initailTeamFetch;
@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;


@end
