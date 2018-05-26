//
//  CreateTeamVC.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 25/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "CreateTeamVC.h"
#import "CreateTeamCell.h"
#import "CreateTeamCollectionCell.h"
#import "Constants.h"
#import <Foundation/Foundation.h>

static NSString *cellIdentifier = @"CreateTeamCell";

@interface CreateTeamVC ()
#define MIN_LENGTH 4

@property (strong, nonatomic) NSMutableArray *array;

@end

@implementation CreateTeamVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    [self.txtFieldTeamTitle setLimit:25];
    self.txtFieldTeamTitle.delegate = (id)self;
    
    [Utils prepareSearchBarUI:self.searchBar];
    [Utils prepareSearchBarUI:self.collectionSearchBar];
    
    
    
    [self.scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 0)];
    //    [self.scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 736)];
    
    self.scrollView.panGestureRecognizer.delaysTouchesBegan = YES;
    self.scrollView.delaysContentTouches = YES;
    self.scrollView.canCancelContentTouches = NO;
    
    //    self.innerCollectionView.scrollEnabled = NO;
    //    self.tableView.scrollEnabled = NO;
    
    [self.innerCollectionView registerNib:[UINib nibWithNibName:@"CreateTeamCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"CreateTeamCollectionCell"];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CreateTeamCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    
    self.resultUserList = [[NSMutableArray alloc] init];
    self.resultCollection = [[NSMutableArray alloc] init];
    
    
    //    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    //    self.innerCollectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    UITapGestureRecognizer *hideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    hideKeyboard.delegate = (id)self;
    hideKeyboard.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:hideKeyboard];
    
    isSearchBecomeActive = NO;
    
    
    [self setupSegmentsWithTabs:@[@"Company", @"External"] andTag:201 inView:self.contactSegmentContainer];
    
    listType = kContacts;
    contentType = kCONTENTTypeCollection;
    
//    [self setupNetworkReachability];
    
    self.btnDoneMakingTeam.enabled = YES;
}



- (void)hideKeyboard:(UITapGestureRecognizer*)sender {
    
    [self.view endEditing:YES];
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.tableView] || [touch.view isDescendantOfView:self.innerCollectionView]) {
        return NO;
    }
    
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.fullId contains[cd] %@",self.team.userId];
    
    [self getUserList];
    
    NSArray *currentUser = [[self.userList filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    
    ConversationUser *adminUser = nil;
    if ([currentUser count]) {
        adminUser = [currentUser objectAtIndex:0];
        adminUser.isSelected = YES;
        [self showDetails:adminUser];
        
    }
    
    
    self.innerCollectionViewContentSizeHeight = [self collectionViewContentSize].height;
    
    self.tabBarController.tabBar.hidden = YES;
    
}

-(void)showDetails :(ConversationUser *)adminUser{
    
    if(self.team != nil){
        
        self.navTitle.text = @"Edit Team";
        
        if (self.isConfirmEdit) {
            self.detailsView.hidden = YES;
        }else{
            self.detailsView.hidden = NO;
        }
        
        if([[RapporrManager sharedManager].vcModel.userId isEqualToString:self.team.userId]){
            
            _btnEditTeam.hidden = NO;
            _btnDoneMakingTeam.enabled = YES;
        }else{
            _btnEditTeam.hidden = YES;
        }
        
        
        NSDateFormatter *formatter = [NSDateFormatter defaultDateManager];
        NSLocale *enUSPosixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        //        NSTimeZone *gmtZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        //        [formatter setTimeZone:gmtZone];
        [formatter setLocale:enUSPosixLocale];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
        NSDate *date = [formatter dateFromString:self.team.timeStamp];
        [formatter setDateFormat:@"hh:mm a dd-MMM-yyyy"];
        NSString *dateTimeString = [formatter stringFromDate:date];
        
        if(adminUser.avatarUrl.length > 1) {
            NSURL *imageUrl = [NSURL URLWithString:adminUser.avatarUrl];
            [self.adminImageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
        }
        else {
            
            [self.adminImageView setImageWithString:adminUser.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
        }
        
        self.lblTeamTitle.text = [NSString stringWithFormat:@"%@",self.team.name];
        
        self.lblAdminName.text = [NSString validStringForObject:adminUser.fName];
        self.lblDate.text = [NSString stringWithFormat:@"%@",dateTimeString];
        self.txtFieldTeamTitle.text = self.team.name;
        
        for (ConversationUser *user in self.userList) {
            for (ConversationUser *teamUser in self.team.members) {
                if (user.fullId == teamUser.fullId) {
                    //                    user.isSelected = YES;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.innerCollectionView reloadData];
        });
        
    }else{
        self.detailsView.hidden = YES;
    }
}

-(void)getUserList{
    
    self.userList = [[NSMutableArray alloc]init];
    self.dataList = [[NSMutableArray alloc]init];
    self.userList = [[CoreDataController sharedManager] fetchUserFromDBUnblockedUsers];
    
    NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                            ascending:YES
                                                             selector:@selector(caseInsensitiveCompare:)];
    
    NSArray *array = [self.userList sortedArrayUsingDescriptors:@[sort]];
    self.userList = [array mutableCopy];
    
    if(self.team != nil){
        for (ConversationUser *teamMember in self.team.members) {
            for (ConversationUser *user in self.userList) {
                
                if([teamMember.fullId isEqualToString:user.fullId]){
                    user.isSelected = YES;
                    break;
                }
            }
        }
    }
    
    self.dataList = self.userList;
    [self populateData:self.userList];
    
}


- (void) populateData:(NSMutableArray *)dataArray {
    
    if (contentType == kCONTENTTypeCollection) {
        
        if(self.isSearching){
            if(listType == kContacts){
                
                NSMutableArray *collectionUsers = [[NSMutableArray alloc]init];
                for (ConversationUser *user in dataArray) {
                    if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                        user.isSelected = YES;
                    }
                    if (![user.uType isEqualToString:kUSER_TYPE_EXT]) {
                        [collectionUsers addObject:user];
                    }
                }
                self.resultCollection = [collectionUsers mutableCopy];
            }else if(listType == kExternal){
                
                NSMutableArray *collectionUsers = [[NSMutableArray alloc]init];
                for (ConversationUser *user in dataArray) {
                    if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                        user.isSelected = YES;
                    }
                    if ([user.uType isEqualToString:kUSER_TYPE_EXT]) {
                        [collectionUsers addObject:user];
                    }
                }
                self.resultCollection = [collectionUsers mutableCopy];
            }
        }else{
            
            if(listType == kContacts){
                
                NSMutableArray *collectionUsers = [[NSMutableArray alloc]init];
                for (ConversationUser *user in dataArray) {
                    if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                        user.isSelected = YES;
                    }
                    if (![user.uType isEqualToString:kUSER_TYPE_EXT]) {
                        [collectionUsers addObject:user];
                    }
                }
                self.dataList = [collectionUsers mutableCopy];
                [self.innerCollectionView reloadData];
                
            }else if(listType == kExternal){
                
                NSMutableArray *collectionUsers = [[NSMutableArray alloc]init];
                for (ConversationUser *user in dataArray) {
                    if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                        user.isSelected = YES;
                    }
                    if ([user.uType isEqualToString:kUSER_TYPE_EXT]) {
                        [collectionUsers addObject:user];
                    }
                }
                self.dataList = [collectionUsers mutableCopy];
            }
            [self.innerCollectionView reloadData];
            
        }
        
        
        
    }else if (contentType == kCONTENTTypeTable){
        
        _resultUserList = [[NSMutableArray alloc]init];
        
        if(listType == kContacts){
            
            NSMutableArray *sections = [NSMutableArray array];
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            if(self.isSearching){
                for (ConversationUser *user in dataArray) {
                    if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                        user.isSelected = YES;
                    }
                    if (![user.uType isEqualToString:kUSER_TYPE_EXT]) {
                        NSInteger section = [collation sectionForObject:user collationStringSelector:@selector(fName)];
                        [sections addObject:user toSubarrayAtIndex:section];
                    }
                }
                
                NSInteger section = 0;
                for (section = 0; section < [sections count]; section++) {
                    NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]
                                                      collationStringSelector:@selector(fName)];
                    [sections replaceObjectAtIndex:section withObject:sortedSubarray];
                }
                
                _resultUserList = [sections mutableCopy];
            }else{
                
                NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                                        ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                
                dataArray = [[dataArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                
                for (ConversationUser *user in dataArray) {
                    if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                        user.isSelected = YES;
                    }
                    if (![user.uType isEqualToString:kUSER_TYPE_EXT]) {
                        
                        NSInteger section = [collation sectionForObject:user collationStringSelector:@selector(fName)];
                        [sections addObject:user toSubarrayAtIndex:section];
                    }
                }
                
                NSInteger section = 0;
                for (section = 0; section < [sections count]; section++) {
                    NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]
                                                      collationStringSelector:@selector(fName)];
                    [sections replaceObjectAtIndex:section withObject:sortedSubarray];
                }
                _sectionizedUsers = [sections mutableCopy];
            }
        }
        else if(listType == kExternal){
            
            NSMutableArray *sections = [NSMutableArray array];
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            if(self.isSearching){
                
                for (ConversationUser *user in dataArray) {
                    if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                        user.isSelected = YES;
                    }
                    NSInteger section = [collation sectionForObject:user collationStringSelector:@selector(fName)];
                    [sections addObject:user toSubarrayAtIndex:section];
                }
                
                NSInteger section = 0;
                for (section = 0; section < [sections count]; section++) {
                    NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]  collationStringSelector:@selector(fName)];
                    [sections replaceObjectAtIndex:section withObject:sortedSubarray];
                }
                
                _resultUserList = [sections mutableCopy];
                
            }else{
                
                NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                                        ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                
                
                dataArray = [[dataArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.uType contains[c] %@",kUSER_TYPE_EXT];
                NSArray *filteredList = [dataArray filteredArrayUsingPredicate:predicate];
                
                for (ConversationUser *user in filteredList) {
                    if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                        user.isSelected = YES;
                    }
                    NSInteger section = [collation sectionForObject:user collationStringSelector:@selector(fName)];
                    [sections addObject:user toSubarrayAtIndex:section];
                }
                
                NSInteger section = 0;
                for (section = 0; section < [sections count]; section++) {
                    NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]
                                                      collationStringSelector:@selector(fName)];
                    [sections replaceObjectAtIndex:section withObject:sortedSubarray];
                }
                _sectionizedUsers = [sections mutableCopy];
            }
        }
        [self.tableView reloadData];
        
    }
}

# pragma mark - UITableView Delegate and Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath*)indexPath
{
    return 59;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isSearching)
    {
        return [self.resultUserList count];
    }
    else
    {
        return [self.sectionizedUsers count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_isSearching) {
        return nil;
    } else {
        return [[self.sectionizedUsers objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearching)
    {
        return [[self.resultUserList objectAtIndex:section] count];
    }
    else
    {
        return [[self.sectionizedUsers objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CreateTeamCell * cell = (CreateTeamCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    ConversationUser *user = nil;
    
    if (_isSearching)
    {
        NSArray *array = [self.resultUserList objectAtIndex:indexPath.section];
        user = [array objectAtIndex:indexPath.row];
    }
    else
    {
        NSArray *array = [self.sectionizedUsers objectAtIndex:indexPath.section];
        user = [array objectAtIndex:indexPath.row];
    }
    
    
    cell.titleLbl.text = user.name;
    cell.jobTitleLbl.text = user.jobTitle;
    
    if(user.avatarUrl.length > 1) {
        
        NSURL *imageUrl = [NSURL URLWithString:user.avatarUrl];
        [cell.mainImg setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    else {
//        [cell.mainImg setImageWithString:user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
        
        cell.contactTxtLbl.text = [Utils getInitialsFromString:user.name];
        cell.contactTxtLbl.hidden = false;
        cell.contactTxtLbl.backgroundColor = [UIColor colorFromHexCode:@"#FF9433"];

    }
    
    if(user.isSelected || [user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
        cell.tickImg.hidden = false;
        user.isSelected = YES;
    }
    else {
        cell.tickImg.hidden = true;
        user.isSelected = NO;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ConversationUser *user = nil;
    
    if (_isSearching)
    {
        NSArray *array = [self.resultUserList objectAtIndex:indexPath.section];
        user = [array objectAtIndex:indexPath.row];
    }
    else
    {
        NSArray *array = [self.sectionizedUsers objectAtIndex:indexPath.section];
        user = [array objectAtIndex:indexPath.row];
    }
    
    
    if(![user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
        if (user.isSelected) {
            user.isSelected = false;
        }
        else {
            user.isSelected = true;
        }
        NSArray *indexPaths = @[indexPath];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        user.isSelected = true;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width-20, 20)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, tableView.frame.size.width, 19)];
    if (IS_IPHONE_4) {
        [label setFont:ROBOTO_REGULAR(13)];
    }
    [label setFont:ROBOTO_REGULAR(15)];
    NSString *sectionTitle = @"";
    
    
    if (_isSearching) {
        sectionTitle = @"";
    } else {
        sectionTitle = [[self.sectionizedUsers objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    }
    
    
    [label setText:sectionTitle];
    [view addSubview:label];
    [view setBackgroundColor:App_GrayColor];
    return view;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (_isSearching) {
        return nil;
    } else {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
}


#pragma mark - UISearchBar Delegates


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if([searchText isEqualToString:@""] || searchText==nil) {
        _isSearching = NO;
        [self.tableView reloadData];
        [self.innerCollectionView reloadData];
    }else{
        
        _isSearching = YES;
        
        if (contentType == kCONTENTTypeTable) {
            
            
            [self.resultUserList removeAllObjects];
            
            NSPredicate *predicate = [NSPredicate
                                      predicateWithFormat:@"SELF.name contains[c] %@",
                                      searchText];
            
            for(NSArray *subAry in self.sectionizedUsers)
            {
                NSArray *result = [subAry filteredArrayUsingPredicate:predicate];
                if(result && result.count > 0)
                {
                    [self.resultUserList addObjectsFromArray:result];
                }
            }
            
            [self populateData:self.resultUserList];
        }
        
        else if (contentType == kCONTENTTypeCollection){
            
            NSPredicate *predicate = [NSPredicate
                                      predicateWithFormat:@"SELF.name contains[c] %@",
                                      searchText];
            
            
            NSArray *arrFilteredCollec = [self.userList filteredArrayUsingPredicate:predicate];
            
            [self.resultCollection removeAllObjects];
            
            self.resultCollection = [arrFilteredCollec mutableCopy];
            
            [self populateData:self.resultCollection];
        }
        
        [self.innerCollectionView reloadData];
    }
}


-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    isSearchBecomeActive = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    
    return YES;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    isSearchBecomeActive = NO;
    [searchBar resignFirstResponder];
    // Do the search...
}

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    if( [collectionView isEqual:self.teamDetailsCollectionView]){
        return [self.team.members count];
    }else{
        
        if(_isSearching){
            if([_resultCollection count]){
                return self.resultCollection.count;
            }
        }else{
            if([_dataList count]){
                return _dataList.count;
            }
        }
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CreateTeamCollectionCell *cell = [_innerCollectionView dequeueReusableCellWithReuseIdentifier:@"CreateTeamCollectionCell" forIndexPath:indexPath];
    
    ConversationUser *user = nil;
    
    if( [collectionView isEqual:self.teamDetailsCollectionView]){
        
        user = [self.team.members objectAtIndex:indexPath.row];
        if(user.isAdmin || [user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
            user.isSelected = YES;
        }
        
        cell.titleLbl.text = user.name;
        
        if(user.avatarUrl.length > 1) {
            
            NSURL *imageUrl = [NSURL URLWithString:user.avatarUrl];
            [cell.mainImg setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        else {
            
            cell.contactTxtLbl.text = [Utils getInitialsFromString:user.name];
            cell.contactTxtLbl.hidden = false;
            cell.contactTxtLbl.backgroundColor = [UIColor colorFromHexCode:@"#FF9433"];

            
//            [cell.mainImg setImageWithString:user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
        }
        
        if(user.isSelected){
            if (self.team) {
                cell.tickImg.hidden = YES;
            }else{
                cell.tickImg.hidden = false;
            }
        }
        else {
            cell.tickImg.hidden = true;
        }
    }else{
        
        if(_isSearching){
            if([self.resultCollection count])
                user = [self.resultCollection objectAtIndex:indexPath.row];
        }else{
            if([_dataList count])
                user = [_dataList objectAtIndex:indexPath.row];
        }
        if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
            user.isSelected = YES;
        }
        
        
        cell.titleLbl.text = user.name;
        
        if(user.avatarUrl.length > 1) {
            
            NSURL *imageUrl = [NSURL URLWithString:user.avatarUrl];
            [cell.mainImg setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        else {
//            [cell.mainImg setImageWithString:user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
            
            cell.contactTxtLbl.text = [Utils getInitialsFromString:user.name];
            cell.contactTxtLbl.hidden = false;
            cell.contactTxtLbl.backgroundColor = [UIColor colorFromHexCode:@"#FF9433"];
            

        }
        
        if(user.isSelected){
            cell.tickImg.hidden = false;
        }
        else {
            cell.tickImg.hidden = true;
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ConversationUser *user = nil;
    if( [collectionView isEqual:self.teamDetailsCollectionView]){
        
    }
    else{
        if(_isSearching){
            if([self.resultCollection count])
                user = [self.resultCollection objectAtIndex:indexPath.row];
        }else{
            if([_dataList count])
                user = [_dataList objectAtIndex:indexPath.row];
        }
        
        if(![user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
            
            if (user.isSelected) {
                user.isSelected = false;
            }
            else {
                user.isSelected = true;
            }
            
            [UIView performWithoutAnimation:^{[self.innerCollectionView reloadData];}];
        }
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        return CGSizeMake(90, 90);
    }
    return CGSizeMake(CGRectGetWidth(collectionView.frame)/3 - 30, (CGRectGetWidth(collectionView.frame)/3  - 30));
}


- (CGSize)collectionViewContentSize
{
    NSInteger itemCount = [self.innerCollectionView numberOfItemsInSection:0];
    NSInteger pages = ceil(itemCount / 16.0);
    return CGSizeMake(self.innerCollectionView.frame.size.width ,320 * pages);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IBAction

- (IBAction)btnBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)listPressed:(id)sender {
    
    
    contentType = kCONTENTTypeTable;
    
    [_listBtn setBackgroundImage:[UIImage imageNamed:@"list_sel"] forState:UIControlStateNormal];
    [_gridBtn setBackgroundImage:[UIImage imageNamed:@"grid_normal"] forState:UIControlStateNormal];
    
    _tableContainer.hidden = false;
    _scrollContainer.hidden = true;
    
    _isSearching = NO;
    [self.searchBar performSelector:@selector(resignFirstResponder)
                         withObject:nil
                         afterDelay:0];
    
    [self.collectionSearchBar performSelector:@selector(resignFirstResponder)
                                   withObject:nil
                                   afterDelay:0];
    
    [self.searchBar setText:@""];
    [self.collectionSearchBar setText:@""];
    
    
    
    listType = kContacts;
    self.contactSegment.selectedSegmentIndex = 0;
    [self populateData:self.userList];
    
}

- (IBAction)gridPressed:(id)sender {
    
    contentType = kCONTENTTypeCollection;
    
    [_listBtn setBackgroundImage:[UIImage imageNamed:@"list_normal"] forState:UIControlStateNormal];
    [_gridBtn setBackgroundImage:[UIImage imageNamed:@"grid_sel"] forState:UIControlStateNormal];
    _isSearching = NO;
    
    _tableContainer.hidden = true;
    _scrollContainer.hidden = false;
    
    [self.searchBar performSelector:@selector(resignFirstResponder)
                         withObject:nil
                         afterDelay:0];
    
    [self.collectionSearchBar performSelector:@selector(resignFirstResponder)
                                   withObject:nil
                                   afterDelay:0];
    
    [self.searchBar setText:@""];
    [self.collectionSearchBar setText:@""];
    
    listType = kContacts;
    
    
    
    self.contactSegment.selectedSegmentIndex = 0;
    [self populateData:self.userList];
}

- (IBAction)btnDoneMakingTeam:(id)sender {
    
    
     if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
    NSMutableArray *users = [[NSMutableArray alloc]init];
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    
    if(_isSearching){
        
        if (contentType == kCONTENTTypeCollection) {
            dataArray = self.resultCollection;
            
            if ([[dataArray objectAtIndex:0] isKindOfClass:[NSMutableArray class]] || [[dataArray objectAtIndex:0] isKindOfClass:[NSArray class]]) {
                for (NSMutableArray *arr in dataArray) {
                    for (ConversationUser *user in arr) {
                        if (user.isSelected) {
                            [users addObject:user.fullId];
                        }
                    }
                }
            }else{
                
                for (ConversationUser *user in dataArray) {
                    if (user.isSelected) {
                        [users addObject:user.fullId];
                    }
                }
                [users addObject:[RapporrManager sharedManager].vcModel.userId];
            }
            
        }else{
            dataArray = self.resultUserList;
            
            if ([[dataArray objectAtIndex:0] isKindOfClass:[NSMutableArray class]] || [[dataArray objectAtIndex:0] isKindOfClass:[NSArray class]]) {
                for (NSMutableArray *arr in dataArray) {
                    for (ConversationUser *user in arr) {
                        if (user.isSelected) {
                            [users addObject:user.fullId];
                        }
                    }
                }
            }
            [users addObject:[RapporrManager sharedManager].vcModel.userId];
        }
        
    }else{
        dataArray = self.userList;
        
        for (ConversationUser *user in dataArray) {
            if (user.isSelected) {
                [users addObject:user.fullId];
            }
        }
    }
    
    if (_txtFieldTeamTitle.text.length >=5) {
        
        if ([users count] > 1) {
            
            NSDateFormatter *dateFormatter = [NSDateFormatter defaultDateManager];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";
            NSTimeZone *gmtZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmtZone];
            NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
            NSDate *dateFromString = [dateFormatter dateFromString:timeStamp];
            
            NSTimeInterval timeInMiliseconds = [dateFromString timeIntervalSince1970]*1000;
            NSString *intervalString = [NSString stringWithFormat:@"%.0f", timeInMiliseconds];
            
            NSString *usersDic = [@{@"users":users}jsonString];
            NSString *hostID = [RapporrManager sharedManager].vcModel.hostID;
            NSString *organizationID = [RapporrManager sharedManager].vcModel.orgId;
            NSString *teamName = _txtFieldTeamTitle.text;
            NSString *userID = [RapporrManager sharedManager].vcModel.userId;
            NSString *fullid = @"";
            NSString *callBackId = @"";
            
            if(self.team != nil){
                fullid = self.team.callBackId;
                callBackId = self.team.callBackId;
            }else{
                callBackId = [NSString stringWithFormat:@"%@-group-%@-%@",hostID,userID,intervalString];
                fullid = callBackId;
            }
            
            NSDictionary *paramsToBeSent = @{
                                             @"hostid" : hostID,
                                             @"orgid" :  organizationID,
                                             @"name" :  teamName,
                                             @"userid" : userID,
                                             @"callbackid" : callBackId,
                                             @"status" : @"active",
                                             @"type" :   @"shared",
                                             @"fullid" : fullid,
                                             @"publicid":@"",
                                             @"active" : @"true",
                                             @"objects" : usersDic
                                             };
            
            __weak typeof(self) weakSelf = self;
            
            
            [NetworkManager createNewTeam:URI_CREATE_TEAM parameters:paramsToBeSent success:^(id data, NSString *timestamp) {
                
                NSString *response = (NSString*)data;
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    if (self.team) {
                        
                        self.team.usersIdArray = users;
                        [self.team.members removeAllObjects];
                        
                        for (NSString *userId in users) {
                            [self.team.members addObject:[[CoreDataController sharedManager] getUserWithID:userId]];
                        }
                        
                        
                        self.team.usersString = [self.team getTeamUsers:users team:self.team];
                        self.team.name = teamName;
                        [[CoreDataController sharedManager] updateTeam:self.team];
                        [strongSelf.delegate didTeamUpdatedSuccessfully:self.team];
                        
                    }else{
                    
                        [strongSelf.delegate didTeamCreatedSuccessfully];
                    }
                }
                
                NSString *action = @"created";
                
                if (self.team.callBackId) {
                    action = @"updated";
                }
                
                NSString *message = [NSString stringWithFormat:@"%@ has been successfully %@. All the team members will be able to access the team soon",teamName,action];
                
                [self setUpAlertView];
                _customAlert.alertTag = 10001;
                _customAlert.alertType = kAlertTypeDetail;
                UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
                [self.customAlert showPopUpInView:top.view withMessage:NSLocalizedString(@"New Team", nil) andDescription:NSLocalizedString(message, nil)];
                

            }failure:^(NSError *error) {
                NSLog(@"Error");
            }];
        }
        else{
            [self setUpAlertView];
            _customAlert.alertTag = 10000;
            _customAlert.alertType = kAlertTypeDetail;
            UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
            [self.customAlert showPopUpInView:top.view withMessage:NSLocalizedString(@"Error", nil) andDescription:NSLocalizedString(@"Please select at least one more member.", nil)];
        }
    }
    else{
        
        [self setUpAlertView];
        _customAlert.alertTag = 10000;
        _customAlert.alertType = kAlertTypeDetail;
        UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
        [self.customAlert showPopUpInView:top.view withMessage:NSLocalizedString(@"Error", nil) andDescription:NSLocalizedString(@"Team title should be great than 5 chars", nil)];
    }}
     else{
     
         [appDelegate showUnavailablityAlert];
     }
}


- (NSString*)GetCurrentTimeStamp
{
    NSDateFormatter *dateFormatter = [NSDateFormatter defaultDateManager];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString    *strTime = [dateFormatter stringFromDate:[NSDate date]];
    NSString    *strUTCTime = [self GetUTCDateTimeFromLocalTime:strTime];//You can pass your date but be carefull about your date format of NSDateFormatter.
    NSDate *objUTCDate  = [dateFormatter dateFromString:strUTCTime];
    long long milliseconds = (long long)([objUTCDate timeIntervalSince1970]);
    
    NSString *strTimeStamp = [NSString stringWithFormat:@"%lld",milliseconds];
    return strTimeStamp;
}


- (NSString *) GetUTCDateTimeFromLocalTime:(NSString *)IN_strLocalTime
{
    NSDateFormatter *dateFormatter = [NSDateFormatter defaultDateManager];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate  *objDate    = [dateFormatter dateFromString:IN_strLocalTime];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *strDateTime   = [dateFormatter stringFromDate:objDate];
    return strDateTime;
}


#pragma mark -
#pragma mark UITextFieldDelegate


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.txtFieldTeamTitle resignFirstResponder];
    return YES;
}

- (IBAction)btnEditTeam:(id)sender {
    
    self.isEditingTeam = !self.isEditingTeam;
    
    if(self.isEditingTeam){
        
        self.btnDoneMakingTeam.enabled = YES;
        [self.btnDoneMakingTeam setTitleColor:[UIColor colorFromHexCode:@"#FF5721"] forState:UIControlStateNormal];
        
        self.detailsView.hidden = YES;
        [self.innerCollectionView reloadData];
        [self.teamDetailsCollectionView reloadData];
    }else{
        self.detailsView.hidden = NO;
        [self.innerCollectionView reloadData];
        [self.teamDetailsCollectionView reloadData];
    }
}

-(void)textFieldLimit:(UITextFieldLimit *)textFieldLimit didWentOverLimitWithDisallowedText:(NSString *)text inDisallowedRange:(NSRange)range;{
    
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.05];
    [shake setRepeatCount:2];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(self.lblCounter.center.x - 5,self.lblCounter.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(self.lblCounter.center.x + 5, self.lblCounter.center.y)]];
    [self.lblCounter.layer addAnimation:shake forKey:@"position"];
}

-(void)textFieldLimit:(UITextFieldLimit *)textFieldLimit didReachLimitWithLastEnteredText:(NSString *)text inRange:(NSRange)range;{
    
}

-(void)textFieldLimit:(UITextFieldLimit *)textFieldLimit currentLength:(NSInteger)currentLength;{
    
    if (currentLength >= 5)
    {
        [self.btnDoneMakingTeam setTitleColor:[UIColor colorFromHexCode:@"#FF5721"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnDoneMakingTeam setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    self.lblCounter.text = [NSString stringWithFormat:@"%ld/25",(long)currentLength];
}

-(void)keyboardWillShow:(NSNotification *)notification {
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float height = MIN(keyboardSize.height,keyboardSize.width);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect tableViewRect = self.scrollView.frame;
    tableViewRect.size.height = self.view.frame.size.height - 20 - height;
    self.scrollView.frame = tableViewRect;
    
    //    [self.scrollView setContentOffset:CGPointMake(0, 132) animated:NO];
    
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    //    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGRect tableViewRect = self.scrollView.frame;
    tableViewRect.size.height = self.view.frame.size.height - 70;
    self.scrollView.frame = tableViewRect;
    
    [UIView commitAnimations];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    self.tabBarController.tabBar.hidden = NO;
    [self.view endEditing:YES];
    
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGPoint targetPoint = *targetContentOffset;
    CGPoint currentPoint = scrollView.contentOffset;
}

-(void)setupSegmentsWithTabs:(NSArray *)tabs andTag:(int)tag inView:(UIView *)view{
    
    CGFloat viewWidth = CGRectGetWidth(view.frame);
    self.contactSegment = [[HMSegmentedControl alloc] initWithSectionTitles:tabs];
    self.contactSegment.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorFromHexCode:@"#BEC3C7"],NSFontAttributeName : ROBOTO_REGULAR(17)};
    self.contactSegment.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName : ROBOTO_REGULAR(17)};
    
    self.contactSegment.selectionIndicatorColor = [UIColor blackColor];
    self.contactSegment.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.contactSegment.frame = CGRectMake(0, 0, viewWidth, 35);
    self.contactSegment.segmentEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.contactSegment.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.contactSegment.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.contactSegment.selectionIndicatorHeight = 2.0f;
    self.contactSegment.verticalDividerEnabled = NO;
    [self.contactSegment addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    self.contactSegment.tag = tag;
    __weak typeof(self) weakSelf = self;
    
    [self.contactSegment setIndexChangeBlock:^(NSInteger index) {
        
    }];
    [view addSubview:self.contactSegment];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    
    if (segmentedControl.tag == 201) {
        
        _isSearching = NO;
        
        [self.searchBar performSelector:@selector(resignFirstResponder)
                             withObject:nil
                             afterDelay:0];
        
        
        
        [self.searchBar setText:@""];
        
        
        if (segmentedControl.selectedSegmentIndex == 0) {
            
            listType = kContacts;
            [self populateData:self.userList];
        }
        else
        {
            listType = kExternal;
            [self populateData:self.userList];
        }
    }
}

#pragma Rapporr AlertView

- (void) setUpAlertView {
    
    _customAlert = [[RapporrAlertView alloc] init];
    [_customAlert setDelegate:(id)self];
    
}

-(void)RapporrAlertOK:(id)sender{
    
    if (_customAlert.alertTag == 10001) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [_customAlert removeCustomAlertFromViewInstantly];
}

-(void)RapporrAlertCancel;{
    [_customAlert removeCustomAlertFromViewInstantly];
}

-(void)RapporrAlertCancel:(id)sender;{
    
    [_customAlert removeCustomAlertFromViewInstantly];
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
