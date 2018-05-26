//
//  AddNewMemberVC.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/1/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InternetAvailability.h"
#import "RKDropdownAlert.h"
#import "CreateTeamCollectionCell.h"
#import "CreateTeamCell.h"
#import "Utils.h"

@protocol AddNewMemberVCDelegate <NSObject>

-(void)didNewMembersSelected:(NSMutableArray *)users;

@end

@interface AddNewMemberVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate>{
    
    ListType listType;
    CONTENTType contentType;
    
    
}

@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


- (IBAction)btnDone:(id)sender;
- (IBAction)btnCancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnShowList;
@property (weak, nonatomic) IBOutlet UIButton *btnShowCollection;

- (IBAction)btnShowList:(id)sender;
- (IBAction)btnShowCollection:(id)sender;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *tableContainer;
@property (weak, nonatomic) IBOutlet UIView *collectionContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *sectionizedUsers;
@property (nonatomic, strong) NSMutableArray *tableResults;

@property (nonatomic, strong) NSMutableArray *collectionResults;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic)     BOOL isSearching;
@property (nonatomic) BOOL isKeyboardActive;
@property (nonatomic, strong) RapporrAlertView *customAlert;
@property (nonatomic, strong) MessageModel *conversation;
@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;

@property (nonatomic,weak) id<AddNewMemberVCDelegate>delegate;


@end
