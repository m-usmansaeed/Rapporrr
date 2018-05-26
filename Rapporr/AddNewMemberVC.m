//
//  AddNewMemberVC.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/1/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "AddNewMemberVC.h"

static NSString *cellIdentifier = @"CreateTeamCell";

@interface AddNewMemberVC ()

@end

@implementation AddNewMemberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setUpAlertView];
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    [Utils prepareSearchBarUI:self.searchBar];
    
    self.isKeyboardActive = NO;
    listType = kContacts;
    contentType = kCONTENTTypeCollection;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CreateTeamCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"CreateTeamCollectionCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CreateTeamCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.users = [[NSMutableArray alloc]init];
    self.sectionizedUsers = [[NSMutableArray alloc]init];
    self.tableResults = [[NSMutableArray alloc]init];
    self.collectionResults = [[NSMutableArray alloc]init];
    self.dataArray = [[NSMutableArray alloc]init];
    
    self.users = [[CoreDataController sharedManager] fetchUserFromDBUnblockedUsers];
    
    
    for (ConversationUser *member in self.conversation.members) {
        [self.users enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ConversationUser *user, NSUInteger index, BOOL *stop) {
            if ([user.fullId isEqualToString:member.fullId]) {
                [self.users removeObjectAtIndex:index];
            }
        }];
    }
    
    [self prepareViewInitialData:self.users];
    
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    UITapGestureRecognizer *hideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    
    hideKeyboard.cancelsTouchesInView = NO;
    hideKeyboard.delegate = (id)self;
    self.view.tag = 1000;
    [self.view addGestureRecognizer:hideKeyboard];
    
    
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


- (IBAction)btnShowList:(id)sender {
    
    contentType = kCONTENTTypeTable;
    
    [_btnShowList setBackgroundImage:[UIImage imageNamed:@"list_sel"] forState:UIControlStateNormal];
    [_btnShowCollection setBackgroundImage:[UIImage imageNamed:@"grid_normal"] forState:UIControlStateNormal];
    
    _tableContainer.hidden = NO;
    _collectionContainer.hidden = YES;
    
    _isSearching = NO;
    [self.tableView performSelector:@selector(resignFirstResponder)
                         withObject:nil
                         afterDelay:0];
    
    [self.searchBar setText:@""];
    
    listType = kContacts;
    
    if (![self.users count]) {
        [self getUserFromDB];
    }else{
        [self prepareViewInitialData:self.users];
    }
    
}

- (IBAction)btnShowCollection:(id)sender {
    
    contentType = kCONTENTTypeCollection;
    
    [_btnShowList setBackgroundImage:[UIImage imageNamed:@"list_normal"] forState:UIControlStateNormal];
    [_btnShowCollection setBackgroundImage:[UIImage imageNamed:@"grid_sel"] forState:UIControlStateNormal];
    _isSearching = NO;
    
    _tableContainer.hidden = YES;
    _collectionContainer.hidden = NO;
    
    
    
    [self.searchBar performSelector:@selector(resignFirstResponder)
                         withObject:nil
                         afterDelay:0];
    
    [self.searchBar setText:@""];
    listType = kContacts;
    
    if (![self.users count]) {
        [self getUserFromDB];
    }else{
        [self prepareViewInitialData:self.users];
    }
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}


- (void)hideKeyboard:(UITapGestureRecognizer*)sender {
    
    [self.view endEditing:YES];
}


- (IBAction)btnCancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}


- (IBAction)btnDone:(id)sender {
    
    
    
    
    NSMutableArray *users = [[NSMutableArray alloc]init];
    
    for (ConversationUser *user in self.users) {
        if (user.isSelected && ![user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]) {
            [users addObject:user];
            
        }
    }
    
    [self.delegate didNewMembersSelected:users];
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}


-(void)prepareViewInitialData:(NSMutableArray *)dataList{
    
    
    if (contentType == kCONTENTTypeTable) {
        if(listType == kContacts){
            
            NSMutableArray *sections = [NSMutableArray array];
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            if(self.isSearching){
                for (ConversationUser *user in dataList) {
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
                
                _tableResults = [sections mutableCopy];
                
            }else{
                
                NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                                        ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                
                dataList = [[dataList sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                
                for (ConversationUser *user in dataList) {
                    
                    NSInteger section = [collation sectionForObject:user collationStringSelector:@selector(fName)];
                    
                    if (![user.uType isEqualToString:kUSER_TYPE_EXT]) {
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
        else if(listType == kExternal)
        {
            
            NSMutableArray *sections = [NSMutableArray array];
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            if(self.isSearching){
                for (ConversationUser *user in dataList) {
                    NSInteger section = [collation sectionForObject:user collationStringSelector:@selector(fName)];
                    [sections addObject:user toSubarrayAtIndex:section];
                }
                
                NSInteger section = 0;
                for (section = 0; section < [sections count]; section++) {
                    NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]  collationStringSelector:@selector(fName)];
                    [sections replaceObjectAtIndex:section withObject:sortedSubarray];
                }
                
                _tableResults = [sections mutableCopy];
                
            }else{
                
                NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                                        ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                
                dataList = [[dataList sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.uType contains[c] %@",kUSER_TYPE_EXT];
                NSArray *filteredList = [dataList filteredArrayUsingPredicate:predicate];
                
                for (ConversationUser *user in filteredList) {
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
    }
    
    if (contentType == kCONTENTTypeCollection) {
        if (self.isSearching) {
            if(listType == kContacts){
                
                NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                                        ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                dataList = [[dataList sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                
                NSMutableArray *collectionUsers = [[NSMutableArray alloc]init];
                for (ConversationUser *user in dataList) {
                    if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                        user.isSelected = YES;
                    }
                    if (![user.uType isEqualToString:kUSER_TYPE_EXT]) {
                        [collectionUsers addObject:user];
                    }
                }
                self.collectionResults = [collectionUsers mutableCopy];
            }
            else if(listType == kExternal){
                NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                                        ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                
                dataList = [[dataList sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                
                NSMutableArray *collectionUsers = [[NSMutableArray alloc]init];
                for (ConversationUser *user in dataList) {
                    if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                        user.isSelected = YES;
                    }
                    if ([user.uType isEqualToString:kUSER_TYPE_EXT]) {
                        [collectionUsers addObject:user];
                    }
                }
                self.collectionResults = [collectionUsers mutableCopy];
                
            }
        }else{
            if(listType == kContacts){
                
                
                NSMutableArray *collectionUsers = [[NSMutableArray alloc]init];
                for (ConversationUser *user in self.users) {
                    if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                        user.isSelected = YES;
                    }
                    if (![user.uType isEqualToString:kUSER_TYPE_EXT]) {
                        [collectionUsers addObject:user];
                    }
                }
                
                NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                                        ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                
                collectionUsers = [[collectionUsers sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                
                
                self.dataArray = [collectionUsers mutableCopy];
                
            }
            else if(listType == kExternal)
            {
                NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                                        ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                
                dataList = [[dataList sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                
                NSMutableArray *collectionUsers = [[NSMutableArray alloc]init];
                for (ConversationUser *user in self.users) {
                    if([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                        user.isSelected = YES;
                    }
                    if ([user.uType isEqualToString:kUSER_TYPE_EXT]) {
                        [collectionUsers addObject:user];
                    }
                }
                self.dataArray = [collectionUsers mutableCopy];
            }
        }
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.collectionView reloadData];
    });
    
}


-(void)getUserFromDB
{
    [self.sectionizedUsers removeAllObjects];
    
    [self.searchBar performSelector:@selector(resignFirstResponder)
                         withObject:nil
                         afterDelay:0];
    
    [self.searchBar setText:@""];
    
    if (![self.users count]) {
        self.users = [[CoreDataController sharedManager] fetchUserFromDBUnblockedUsers];
        if ([self.users count]) {
            [self prepareViewInitialData:self.users];
        }
    }
}


-(void)keyboardWillShow:(NSNotification *)notification {
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float height = MIN(keyboardSize.height,keyboardSize.width);
    CGRect tableViewRect = self.tableContainer.frame;
    CGRect collectionViewRect = self.collectionContainer.frame;
    
    
    if (self.isKeyboardActive == NO) {
        
        tableViewRect.size.height = self.tableContainer.frame.size.height - height;
        collectionViewRect.size.height = self.collectionContainer.frame.size.height - height;
        self.isKeyboardActive = YES;
    }
    self.tableContainer.frame = tableViewRect;
    self.collectionContainer.frame = collectionViewRect;
    [UIView commitAnimations];
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float height = MIN(keyboardSize.height,keyboardSize.width);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect tableViewRect = self.tableContainer.frame;
    tableViewRect.size.height = self.view.frame.size.height - self.tableContainer.frame.origin.y - self.searchBar.frame.size.height - 22;
    self.tableContainer.frame = tableViewRect;
    
    CGRect collectionViewRect = self.collectionContainer.frame;
    collectionViewRect.size.height = self.view.frame.size.height - self.collectionContainer.frame.origin.y - self.searchBar.frame.size.height - 22;
    self.collectionContainer.frame = collectionViewRect;
    [UIView commitAnimations];
    self.isKeyboardActive = NO;
    
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
    
    
}


#pragma mark - UITableView Delegate


# pragma mark - UITableView Delegate and Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath*)indexPath
{
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ConversationUser *user = nil;
    TeamModel *team = nil;
    
    if (listType == kContacts || listType == kExternal) {
        if (_isSearching)
        {
            NSArray *array = [self.tableResults objectAtIndex:indexPath.section];
            user = [array objectAtIndex:indexPath.row];
        }
        else
        {
            NSArray *array = [self.sectionizedUsers objectAtIndex:indexPath.section];
            user = [array objectAtIndex:indexPath.row];
        }
        
        if(![user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
            if (user.isSelected) {
                user.isSelected = NO;
            }
            else {
                user.isSelected = YES;
            }
            
            NSArray *indexPaths = @[indexPath];
            
            [UIView performWithoutAnimation:^{
                [tableView beginUpdates];
                [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
            }];
            
        }
        else {
            user.isSelected = YES;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.tableView]) {
        
        if (listType == kContacts || listType == kExternal) {
            
            if (self.isSearching)
            {
                return [self.tableResults count];
            }else{
                return [self.sectionizedUsers count];
            }
        }
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        
        if (listType == kContacts || listType == kExternal) {
            if (self.isSearching) {
                return nil;
            } else {
                return [[self.sectionizedUsers objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
            }
        }
    }
    return @"";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, tableView.frame.size.width, 20)];
    if (IS_IPHONE_4) {
        [label setFont:ROBOTO_REGULAR(13)];
    }
    [label setFont:ROBOTO_REGULAR(15)];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    NSString *sectionTitle = @"";
    
    if([tableView isEqual:self.tableView]){
        
        if (listType == kContacts || listType == kExternal) {
            
            if (self.isSearching) {
                sectionTitle = @"";
            } else {
                sectionTitle = [[self.sectionizedUsers objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
            }
        }
    }
    
    [label setText:sectionTitle];
    [view addSubview:label];
    [view setBackgroundColor:App_GrayColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:self.tableView]){
        
        if (listType == kContacts || listType == kExternal) {
            
            if (self.isSearching)
            {
                return [[self.tableResults objectAtIndex:section] count];
            }
            else
            {
                return [[self.sectionizedUsers objectAtIndex:section] count];
            }
        }
    }
    
    return 0;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.isSearching) {
        return nil;
    } else {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CreateTeamCell * cell = (CreateTeamCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    ConversationUser *user = nil;
    
    if([tableView isEqual:self.tableView]){
        
        
        if (listType == kContacts || listType == kExternal) {
            
            if (self.isSearching)
            {
                NSArray *array = [self.tableResults objectAtIndex:indexPath.section];
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
                [cell.mainImg setImageWithString:user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
            }
            
            if(user.isSelected || [user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
                cell.tickImg.hidden = false;
                user.isSelected = YES;
            }
            else {
                cell.tickImg.hidden = true;
                user.isSelected = NO;
            }
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if([tableView isEqual:self.tableView]){
        
        if (self.isSearching) {
            return 0;
        } else {
            if (title == UITableViewIndexSearch) {
                [tableView scrollRectToVisible:self.searchBar.frame animated:NO];
                return -1;
            } else {
                return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index-1];
            }
        }
    }
    return 0;
}

#pragma mark - UISearchBar Delegates

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    if([searchText isEqualToString:@""] || searchText==nil) {
        self.isSearching = false;
        
        [self.tableView reloadData];
        [self.collectionView reloadData];
        
    }else{
        
        self.isSearching = YES;
        
        if (contentType == kCONTENTTypeTable) {
            if(listType == kContacts || listType == kExternal){
                
                [self.tableResults removeAllObjects];
                
                NSPredicate *predicate = [NSPredicate
                                          predicateWithFormat:@"SELF.name contains[c] %@",
                                          searchText];
                
                for(NSArray *subAry in self.sectionizedUsers)
                {
                    NSArray *result = [subAry filteredArrayUsingPredicate:predicate];
                    if(result && result.count > 0)
                    {
                        [self.tableResults addObjectsFromArray:result];
                    }
                }
                
                if ([self.tableResults count]) {
                    [self prepareViewInitialData:self.tableResults];
                }else{
                    [self.tableView reloadData];
                }
            }
        }else if (contentType == kCONTENTTypeCollection) {
            
            if(listType == kContacts || listType == kExternal){
                
                [self.collectionResults removeAllObjects];
                
                NSPredicate *predicate = [NSPredicate
                                          predicateWithFormat:@"SELF.name contains[c] %@",
                                          searchText];
                
                NSArray *result = [self.users filteredArrayUsingPredicate:predicate];
                
                if ([result count]) {
                    [self prepareViewInitialData:[result mutableCopy]];
                }else{
                    [self.collectionView reloadData];
                    [self.tableView reloadData];
                    
                }
            }
        }
    }
}


-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
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
    
    if([collectionView isEqual:self.collectionView]){
        
        if (listType == kContacts || listType == kExternal) {
            
            if (self.isSearching)
            {
                return self.collectionResults.count;
            }
            else
            {
                return [self.dataArray count];
            }
        }
    }
    
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CreateTeamCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CreateTeamCollectionCell" forIndexPath:indexPath];
    
    ConversationUser *user = nil;
    
    if([collectionView isEqual:self.collectionView]){
        
        
        if (listType == kContacts || listType == kExternal) {
            
            if (self.isSearching)
            {
                user = [self.collectionResults objectAtIndex:indexPath.row];
            }
            else
            {
                user = [self.dataArray objectAtIndex:indexPath.row];
            }
            
            cell.titleLbl.text = user.name;
            
            if(user.avatarUrl.length > 1) {
                
                NSURL *imageUrl = [NSURL URLWithString:user.avatarUrl];
                [cell.mainImg setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                
                
            }
            else {
                
                [cell.mainImg setImageWithString:user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
            }
            
            if(user.isSelected){
                cell.tickImg.hidden = NO;
            }
            else {
                cell.tickImg.hidden = YES;
            }        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ConversationUser *user = nil;
    if (listType == kContacts || listType == kExternal) {
        
        if (_isSearching)
        {
            user = [self.collectionResults objectAtIndex:indexPath.row];
            
        }
        else
        {
            user = [self.dataArray objectAtIndex:indexPath.row];
            
        }
        
        if(![user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
            if (user.isSelected) {
                user.isSelected = NO;
            }
            else {
                user.isSelected = YES;
            }
            
            [self.collectionView reloadData];
        }
        else {
            user.isSelected = YES;
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
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger pages = ceil(itemCount / 16.0);
    return CGSizeMake(self.collectionView.frame.size.width ,320 * pages);
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField; {
    
    [self.view endEditing:YES];
    return YES;
}

-(void)textFieldDidChange :(UITextField *) textField{
    
}

- (void)setUpAlertView {
    _customAlert = [[RapporrAlertView alloc] init];
    [_customAlert setDelegate:(id)self];
}

-(void)RapporrAlertOK:(id)sender{
    
    [_customAlert removeCustomAlertFromViewInstantly];
}

-(void)RapporrAlertCancel{
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
