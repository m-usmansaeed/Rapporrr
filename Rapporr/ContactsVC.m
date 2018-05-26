//
//  ContactsVC.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 17/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "ContactsVC.h"
#import "ConversationUser.h"



@interface ContactsVC ()

@end

@implementation ContactsVC {
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;
    
    self.vcModel = appDelegate.vcModel;
    
    if ([[RapporrManager sharedManager].vcModel.uType isEqualToString:kUSER_TYPE_ADMIN]) {
        [self addFloatingButtonOnContact];

    }
    
    [self addFloatingButtonOnTeam];
    [self setupRefreshControl];
    [self setupRefreshControlForTeams];
    [self adjustTabBarImageOffset];
    [Utils prepareSearchBarUI:self.searchBar];
    [Utils prepareSearchBarUI:self.teamSearchBar];
    
    CGRect frame = self.segmentControl.frame;
    [self.segmentControl setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 35)];
    
    _isMyTeamSelected = YES;
    [self setUpAlertView];
    
    [self setupSegmentsWithTabs:@[@"My Teams", @"All Teams"] andTag:200 inView:self.teamSegmentContainer];
    
    [self setupSegmentsWithTabs:@[@"Company", @"External"] andTag:201 inView:self.contactSegmentContainer];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.users = [[NSMutableArray alloc]init];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        self.users = [[CoreDataController sharedManager] fetchUserFromDBUnblockedUsers];
        if ([self.users count]<=0)
        {
            [self getUserList];
        }
        else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self prepareViewInitialData:self.users];
            });
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            isDataLoaded =true;

            //            [self.tableView reloadData];
//            [self.teamTableView reloadData];
        });
    });
    
    
    self.searchResults = [[NSMutableArray alloc]init];
    self.teamSearchResults = [[NSMutableArray alloc]init];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.teamTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    [self setUpUISegmentControl:self.segmentControl];
    self.cellHeighs = [[NSMutableDictionary alloc]init];
    
    UITapGestureRecognizer *hideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    
    hideKeyboard.cancelsTouchesInView = NO;
    hideKeyboard.delegate = (id)self;
    self.view.tag = 1000;
    [self.view addGestureRecognizer:hideKeyboard];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [RKDropdownAlert dismissAllAlert];

    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    [self segmentControl:_segmentControl];
}


- (void)hideKeyboard:(UITapGestureRecognizer*)sender {
    
    [self.view endEditing:YES];
}



-(void)prepareViewInitialData:(NSMutableArray *)dataList{
    
    if ([dataList count]) {
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
            
            _searchResults = [sections mutableCopy];
            
        }else{
            
            NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                                    ascending:YES
                                                                     selector:@selector(caseInsensitiveCompare:)];
            
            dataList = [[dataList sortedArrayUsingDescriptors:@[sort]] mutableCopy];

            
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
            _sectionizedUsers = [sections mutableCopy];
        }
    }
    else if(listType == kExternal){
        
        NSMutableArray *sections = [NSMutableArray array];
        UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
        
        if(self.isSearching){
            for (NSArray *userArray in dataList) {
                for (ConversationUser *user in userArray) {
                    NSInteger section = [collation sectionForObject:user collationStringSelector:@selector(fName)];
                    [sections addObject:user toSubarrayAtIndex:section];
                }
                
                NSInteger section = 0;
                for (section = 0; section < [sections count]; section++) {
                    NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]  collationStringSelector:@selector(fName)];
                    [sections replaceObjectAtIndex:section withObject:sortedSubarray];
                }
                
                _searchResults = [sections mutableCopy];
                
            }
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
    else if(listType == kMyTeams){
        
        NSMutableArray *sections = [NSMutableArray array];
        UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
        
        if(self.isSearching){
            for (TeamModel *team in dataList) {
                if ([[RapporrManager sharedManager].vcModel.userId isEqualToString:team.userId]) {
                    
                    NSInteger section = [collation sectionForObject:team collationStringSelector:@selector(name)];
                    [sections addObject:team toSubarrayAtIndex:section];
                }
            }
            
            NSInteger section = 0;
            for (section = 0; section < [sections count]; section++) {
                NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]
                                                  collationStringSelector:@selector(name)];
                [sections replaceObjectAtIndex:section withObject:sortedSubarray];
            }
            
            _teamSearchResults = [sections mutableCopy];
            
        }
        else{
            
            for (TeamModel *team in dataList) {
                if ([[RapporrManager sharedManager].vcModel.userId isEqualToString:team.userId]) {
                    
                    NSInteger section = [collation sectionForObject:team collationStringSelector:@selector(name)];
                    [sections addObject:team toSubarrayAtIndex:section];
                }
            }
            
            NSInteger section = 0;
            for (section = 0; section < [sections count]; section++) {
                NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]
                                                  collationStringSelector:@selector(name)];
                [sections replaceObjectAtIndex:section withObject:sortedSubarray];
            }
            _teamSectionized = [sections mutableCopy];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            VCFloatingActionButton *btn = (VCFloatingActionButton *)[self.contactsTeamSegView viewWithTag:300];
            
            if ([_teamSectionized count]) {
                btn.hidden = NO;
                self.createNewTeamView.hidden = YES;
                self.teamTableView.hidden = NO;
            }else{
                self.teamTableView.hidden = YES;
                self.createNewTeamView.hidden = NO;
                btn.hidden = YES;
            }
        });
    }
    else if(listType == kAllTeams){
        
        NSMutableArray *sections = [NSMutableArray array];
        UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
        
        if(self.isSearching){
            for (TeamModel *team in dataList) {
                if (![[RapporrManager sharedManager].vcModel.userId isEqualToString:team.userId]) {
                    NSInteger section = [collation sectionForObject:team collationStringSelector:@selector(name)];
                    [sections addObject:team toSubarrayAtIndex:section];
                }
            }
            
            NSInteger section = 0;
            for (section = 0; section < [sections count]; section++) {
                NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]
                                                  collationStringSelector:@selector(name)];
                [sections replaceObjectAtIndex:section withObject:sortedSubarray];
            }
            
            _teamSearchResults = [sections mutableCopy];
            
        }
        else{
            
            for (TeamModel *team in dataList) {
                if (![[RapporrManager sharedManager].vcModel.userId isEqualToString:team.userId]) {
                    
                    NSInteger section = [collation sectionForObject:team collationStringSelector:@selector(name)];
                    [sections addObject:team toSubarrayAtIndex:section];
                }
            }
            
            NSInteger section = 0;
            for (section = 0; section < [sections count]; section++) {
                NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]
                                                  collationStringSelector:@selector(name)];
                [sections replaceObjectAtIndex:section withObject:sortedSubarray];
            }
            _teamSectionized = [sections mutableCopy];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            VCFloatingActionButton *btn = (VCFloatingActionButton *)[self.contactsTeamSegView viewWithTag:300];
            
            if ([_teamSectionized count]) {
                btn.hidden = NO;
                self.createNewTeamView.hidden = YES;
                self.teamTableView.hidden = NO;
                
            }else{
                self.teamTableView.hidden = YES;
                self.createNewTeamView.hidden = NO;
                btn.hidden = YES;
            }
        });
    }
    }

    [self.tableView reloadData];
    [self.teamTableView reloadData];
    
}

-(void) populateData : (NSMutableArray *)dataList :(UITableView*) tableViewToUpdate {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
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
                
                _searchResults = [sections mutableCopy];
                
            }else{
                
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
                _sectionizedUsers = [sections mutableCopy];
            }
        }
        else if(listType == kExternal){
            
            NSMutableArray *sections = [NSMutableArray array];
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            if(self.isSearching){
                for (NSArray *userArray in dataList) {
                    for (ConversationUser *user in userArray) {
                        NSInteger section = [collation sectionForObject:user collationStringSelector:@selector(fName)];
                        [sections addObject:user toSubarrayAtIndex:section];
                    }
                    
                    NSInteger section = 0;
                    for (section = 0; section < [sections count]; section++) {
                        NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]  collationStringSelector:@selector(fName)];
                        [sections replaceObjectAtIndex:section withObject:sortedSubarray];
                    }
                    _searchResults = [sections mutableCopy];
                    
                }
            }else{
                
                NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                                        ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                
                
                NSMutableArray *tempDataList = [[dataList sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.uType contains[c] %@",kUSER_TYPE_EXT];
                NSArray *filteredList = [tempDataList filteredArrayUsingPredicate:predicate];
                
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
        else if(listType == kMyTeams){
            
            NSMutableArray *sections = [NSMutableArray array];
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            if(self.isSearching){
                for (TeamModel *team in dataList) {
                    if ([[RapporrManager sharedManager].vcModel.userId isEqualToString:team.userId]) {
                        
                        NSInteger section = [collation sectionForObject:team collationStringSelector:@selector(name)];
                        [sections addObject:team toSubarrayAtIndex:section];
                    }
                }
                
                NSInteger section = 0;
                for (section = 0; section < [sections count]; section++) {
                    NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]
                                                      collationStringSelector:@selector(name)];
                    [sections replaceObjectAtIndex:section withObject:sortedSubarray];
                }
                
                _teamSearchResults = [sections mutableCopy];
                
            }
            else{
                
                for (TeamModel *team in dataList) {
                    if ([[RapporrManager sharedManager].vcModel.userId isEqualToString:team.userId]) {
                        
                        NSInteger section = [collation sectionForObject:team collationStringSelector:@selector(name)];
                        [sections addObject:team toSubarrayAtIndex:section];
                    }
                }
                
                NSInteger section = 0;
                for (section = 0; section < [sections count]; section++) {
                    NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]
                                                      collationStringSelector:@selector(name)];
                    [sections replaceObjectAtIndex:section withObject:sortedSubarray];
                }
                _teamSectionized = [sections mutableCopy];
            }
        }
        else if(listType == kAllTeams){
            
            NSMutableArray *sections = [NSMutableArray array];
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            if(self.isSearching){
                for (TeamModel *team in dataList) {
                    if (![[RapporrManager sharedManager].vcModel.userId isEqualToString:team.userId]) {
                        NSInteger section = [collation sectionForObject:team collationStringSelector:@selector(name)];
                        [sections addObject:team toSubarrayAtIndex:section];
                    }
                }
                
                NSInteger section = 0;
                for (section = 0; section < [sections count]; section++) {
                    NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]
                                                      collationStringSelector:@selector(name)];
                    [sections replaceObjectAtIndex:section withObject:sortedSubarray];
                }
                
                _teamSearchResults = [sections mutableCopy];
                
            }
            else{
                
                for (TeamModel *team in dataList) {
                    if (![[RapporrManager sharedManager].vcModel.userId isEqualToString:team.userId]) {
                        
                        NSInteger section = [collation sectionForObject:team collationStringSelector:@selector(name)];
                        [sections addObject:team toSubarrayAtIndex:section];
                    }
                }
                
                NSInteger section = 0;
                for (section = 0; section < [sections count]; section++) {
                    NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]
                                                      collationStringSelector:@selector(name)];
                    [sections replaceObjectAtIndex:section withObject:sortedSubarray];
                }
                _teamSectionized = [sections mutableCopy];
                
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [tableViewToUpdate reloadData];
            
        });
    });
    
}

- (IBAction)segmentControl:(UISegmentedControl *)sender {
    
    UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
    if (segmentControl.selectedSegmentIndex == 0) {
        _contactsTeamSegView.hidden = YES;
        _contactsFirstSegView.hidden = NO;
    }
    else {
        _contactsTeamSegView.hidden = NO;
        _contactsFirstSegView.hidden = YES;
    }
    
    [self.searchBar setText:@""];
    [self.teamSearchBar setText:@""];
    
    
    [self setUpUISegmentControl:sender];
    
    self.isSearching = NO;
    
    [self.searchBar performSelector:@selector(resignFirstResponder)
                         withObject:nil
                         afterDelay:0];
    
    [self.teamSearchBar performSelector:@selector(resignFirstResponder)
                             withObject:nil
                             afterDelay:0];
    
    
    if (segmentControl.selectedSegmentIndex == 0) {
        listType = kContacts;
        
    }else{
        if(_isMyTeamSelected){
            listType = kMyTeams;
        }else{
            listType = kAllTeams;
        }
        
        if ([self.teams count] <= 0) {
            [self getTeamDataFromDb];
        }
        if ([self.teams count] <= 0) {
            [self getTeams];
        }
        [self.teamTableView reloadData];
        
    }
    
}


- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    
    if (segmentedControl.tag == 200) {
        [self.searchBar setText:@""];
        [self.teamSearchBar setText:@""];
        _contactsTeamSegView.hidden = NO;
        _contactsFirstSegView.hidden = YES;
        
        self.isSearching = NO;
        
        [self.searchBar performSelector:@selector(resignFirstResponder)
                             withObject:nil
                             afterDelay:0];
        
        [self.teamSearchBar performSelector:@selector(resignFirstResponder)
                                 withObject:nil
                                 afterDelay:0];
        if (segmentedControl.selectedSegmentIndex == 0) {
            listType = kMyTeams;
            _isMyTeamSelected = YES;
            
            
        }else{
            listType = kAllTeams;
            _isMyTeamSelected = NO;
        }
        
//        [self populateData:self.teams :self.teamTableView];
        [self prepareViewInitialData:self.teams];
        
        
    }
    else if (segmentedControl.tag == 201) {
        
        [self.searchBar setText:@""];
        [self.teamSearchBar setText:@""];
        _contactsTeamSegView.hidden = YES;
        _contactsFirstSegView.hidden = NO;
        
        self.isSearching = NO;
        [self.searchBar performSelector:@selector(resignFirstResponder)
                             withObject:nil
                             afterDelay:0];
        
        [self.teamSearchBar performSelector:@selector(resignFirstResponder)
                                 withObject:nil
                                 afterDelay:0];
        
        if (segmentedControl.selectedSegmentIndex == 0) {
            
            listType = kContacts;
            _isCompanySelected = YES;
            
        }else{
            listType = kExternal;
            _isCompanySelected = NO;
        }
        
//        [self populateData:self.users :self.tableView];
        [self prepareViewInitialData:self.users];

    }
    
}


- (void)uisegmentedControlChangedValue:(UISegmentedControl *)segmentedControl {
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) adjustTabBarImageOffset {
    
    UITabBar *tabBar = self.navigationController.tabBarController.tabBar;
    [[tabBar.items objectAtIndex:0] setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [[tabBar.items objectAtIndex:1] setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [[tabBar.items objectAtIndex:2] setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [[tabBar.items objectAtIndex:3] setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    self.title = nil;
}

-(void)setupSegmentsWithTabs:(NSArray *)tabs andTag:(int)tag inView:(UIView *)view{
    
    CGFloat viewWidth = CGRectGetWidth(view.frame);
    HMSegmentedControl *contactSegment = [[HMSegmentedControl alloc] initWithSectionTitles:tabs];
    contactSegment.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorFromHexCode:@"#BEC3C7"],NSFontAttributeName : ROBOTO_REGULAR(17)};
    contactSegment.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName : ROBOTO_REGULAR(17)};
    
    contactSegment.selectionIndicatorColor = [UIColor blackColor];
    contactSegment.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    contactSegment.frame = CGRectMake(0, 0, viewWidth, 35);
    contactSegment.segmentEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0);
    contactSegment.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    contactSegment.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    contactSegment.selectionIndicatorHeight = 2.0f;
    contactSegment.verticalDividerEnabled = NO;
    [contactSegment addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    contactSegment.tag = tag;
    __weak typeof(self) weakSelf = self;
    
    [contactSegment setIndexChangeBlock:^(NSInteger index) {
        
    }];
    [view addSubview:contactSegment];
}


- (void) fetchMessagesFromDB {
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    NSMutableArray *tempMessages = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    conversations = [[NSMutableArray alloc] init];
    
    for (NSManagedObject *messageObj in tempMessages) {
        MessageModel *mModel = [[MessageModel alloc] initWithManagedObject:messageObj];
        [conversations addObject:mModel];
    }
    
}

- (void) checkIfUserExistInConversations:(ConversationUser *)user {
    
    ConversationDetailVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationDetailVC"];
    vc.isSegueUserProfile = YES;
    MessageModel *conversation = [[MessageModel alloc] init];
    NSMutableArray *usersArray = [[NSMutableArray alloc] init];
    [self fetchMessagesFromDB];
    
    ConversationUser *selfUser = [[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"SELF.members.fullId CONTAINS[cd] %@ AND SELF.members.fullId CONTAINS[cd] %@ AND SELF.members.@count == 2", user.fullId, selfUser.fullId];
    
    NSArray *arrFiltered = [conversations filteredArrayUsingPredicate:predicate];
    if ([arrFiltered count]) {
        conversation = [arrFiltered objectAtIndex:0];
    }else{
        
        NSDateFormatter *dateFormatter = [NSDateFormatter defaultDateManager];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";
        NSTimeZone *gmtZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmtZone];
        NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
        
        NSDate *dateFromString = [dateFormatter dateFromString:timeStamp];
        NSTimeInterval timeInMiliseconds = [dateFromString timeIntervalSince1970]*1000;
        
        NSString *intervalString = [NSString stringWithFormat:@"%.0f", timeInMiliseconds];
        
        NSString *hostID = [RapporrManager sharedManager].vcModel.hostID;
        NSString *organizationID = [RapporrManager sharedManager].vcModel.orgId;
        NSString *userID = [RapporrManager sharedManager].vcModel.userId;
        NSString *callBackId = [NSString stringWithFormat:@"%@-%@-%@",hostID,userID,intervalString];
        
        NSMutableDictionary *usersDict = [NSMutableDictionary new];
        NSMutableArray *users = [[NSMutableArray alloc]init];
        
        [users addObject:user.fullId];
        [users addObject:selfUser.fullId];
        
        [usersDict setObject:@"" forKey:user.fullId];
        [usersDict setObject:@"" forKey:selfUser.fullId];
        
        NSString *usersDic = [usersDict jsonString];
        NSString *objects = [@{@"permittedToAddUsers":@0} jsonString];
        
        NSDictionary *dict = @{
                               @"organisation" : organizationID,
                               @"user"         : userID,
                               @"about"        : [NSString stringWithFormat:@"%@ and %@",selfUser.fName,user.fName],
                               @"tags"         : @"",
                               @"users"        : usersDic,
                               @"template"     : @"",
                               @"callBackId"   : callBackId,
                               @"objects"      : objects,
                               @"userList"     : users
                               };
        vc.conversationDictData = dict;
        conversation.about = [NSString stringWithFormat:@"%@ and %@",selfUser.fName,user.fName];

    }
    
    
    vc.conversation = conversation;
    vc.hidesBottomBarWhenPushed = YES;
    vc.isDirectMessage = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (BOOL) checkifArrayHasUserIds :(NSMutableArray*)usersArray andUserId : (NSString*) selectedUserId {
    
    if(usersArray.count == 2) {
        if([self checkUserIDForString:usersArray andUserId:selectedUserId] &&  [self checkUserIDForString:usersArray andUserId:[RapporrManager sharedManager].vcModel.userId]) {
            return true;
        }
    }
    
    return false;
}


- (BOOL) checkUserIDForString : (NSMutableArray*)usersArray andUserId : (NSString *)idToCheck {
    for(int i=0; i<usersArray.count; i++) {
        NSString *userID = [usersArray objectAtIndex:i];
        if([userID isEqualToString:idToCheck]) {
            return true;
        }
    }
    return false;
}


# pragma mark - UserContactTVCell Delegate


-(void)didMessageButtonPressed:(ConversationUser *)user
{
    [self checkIfUserExistInConversations:user];
}

-(void)didCallButtonPressed:(ConversationUser *)user;{
    
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:user.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

-(void)didProfileButtonPressed:(ConversationUser *)user;{
    
    UserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.user = user;
    vc.delegate = (id)self;
    self.expandIndexPath = nil;
    [self.view endEditing:YES];
    if (self.isSearching) {
        self.isSearching = NO;
    }

    [self.tableView reloadData];
    [self.navigationController pushViewController:vc animated:YES];
    
}

# pragma mark - UITableView Delegate and Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath*)indexPath
{
    
    UserContactTVCell *cell = (UserContactTVCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];

    self.teamTableView.sectionIndexBackgroundColor = [UIColor whiteColor];
    
//    if (cell == nil) {
//        cell = [[UserContactTVCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
//    }
    
    cell.userContactTVCellDelegate = self;
    cell.delegate = (id)self;
    cell.tag = indexPath.section;
    
    TeamModel *team = nil;
    
    if([tableView isEqual:self.teamTableView]){
        
        if (self.isSearching)
        {
            NSArray *array = [self.teamSearchResults objectAtIndex:indexPath.section];
            team = [array objectAtIndex:indexPath.row];
        }
        else
        {
            NSArray *array = [self.teamSectionized objectAtIndex:indexPath.section];
            team = [array objectAtIndex:indexPath.row];
        }
    }
    
    
    [cell.lblUserJobDesc setText:team.membersListString];
    CGSize newSize = [cell.lblUserJobDesc sizeOfMultiLineLabel];
    
    
    if([tableView isEqual:self.teamTableView]){
        if (newSize.height > 50) {
            return (60 + 42 - 21);
        }else{
            return (60 + newSize.height - 20);
        }
    }else{
        if ([indexPath isEqual:_expandIndexPath])
            return 110;
    }
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    
    if([tableView isEqual:self.teamTableView]){
        
        TeamModel *team = nil;
        
        if (self.isSearching) {
            
            NSArray *array = [self.teamSearchResults objectAtIndex:indexPath.section];
            team = [array objectAtIndex:indexPath.row];
            
        }else{
            NSArray *array = [self.teamSectionized objectAtIndex:indexPath.section];
            team = [array objectAtIndex:indexPath.row];
        }
        
        CreateTeamVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateTeamVC"];
        vc.team = team;
        vc.delegate = (id)self;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        
        NSMutableArray *modifiedRows = [NSMutableArray array];
        
        if ([indexPath isEqual:self.expandIndexPath]) {
            
            [modifiedRows addObject:self.expandIndexPath];
            self.expandIndexPath = nil;
            
        } else {
            
            if (self.expandIndexPath){
                [modifiedRows addObject:self.expandIndexPath];
            }
            
            self.expandIndexPath = indexPath;
            [modifiedRows addObject:indexPath];
            
        }
        
        if (indexPath == pathToLastRow) {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
//            [UIView performWithoutAnimation:^{
//                
//            }];
            
        }else{
            NSMutableArray *modifiedRows = [NSMutableArray array];
            [modifiedRows addObject:indexPath];
            [tableView reloadRowsAtIndexPaths:modifiedRows withRowAnimation:UITableViewRowAnimationFade];
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
//            [UIView performWithoutAnimation:^{
//                
//            }];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self.view endEditing:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.teamTableView]) {
        
        if (self.isSearching)
        {
            return [self.teamSearchResults count];
        }
        
        else
        {
            return [self.teamSectionized count];
        }
    }else{
        
        if (self.isSearching)
        {
            return [self.searchResults count];
        }
        
        else
        {
            return [self.sectionizedUsers count];
        }
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.teamTableView]) {
        
        if (self.isSearching) {
            return nil;
        } else {
            return [[self.teamSectionized objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
        }
    }else{
        
        if (self.isSearching) {
            return nil;
        } else {
            return [[self.sectionizedUsers objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
        }
    }
    return @"";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, tableView.frame.size.width, 20)];
    if (IS_IPHONE_4) {
        [label setFont:ROBOTO_REGULAR(13)];
    }
    [label setFont:ROBOTO_REGULAR(15)];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    NSString *sectionTitle = @"";
    
    if([tableView isEqual:self.teamTableView]){
        
        if (self.isSearching) {
            sectionTitle = @"";
        } else {
            sectionTitle = [[self.teamSectionized objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
        }
        
    }else{
        
        if (self.isSearching) {
            sectionTitle = @"";
        } else {
            sectionTitle = [[self.sectionizedUsers objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
        }
    }
    
    [label setText:sectionTitle];
    [view addSubview:label];
    [view setBackgroundColor:App_GrayColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:self.teamTableView]){
        
        if (self.isSearching)
        {
            return [[self.teamSearchResults objectAtIndex:section] count];
        }
        else
        {
            return [[self.teamSectionized objectAtIndex:section] count];
        }
        
    }else{
        
        if (self.isSearching)
        {
            return [[self.searchResults objectAtIndex:section] count];
        }
        else
        {
            return [[self.sectionizedUsers objectAtIndex:section] count];
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
    
    UserContactTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    self.teamTableView.sectionIndexBackgroundColor = [UIColor whiteColor];
    
    if (cell == nil) {
        cell = [[UserContactTVCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    cell.userContactTVCellDelegate = self;
    cell.delegate = (id)self;
    cell.tag = indexPath.section;
    
    ConversationUser *user = nil;
    TeamModel *team = nil;
    
    if([tableView isEqual:self.teamTableView]){
        
        if (self.isSearching)
        {
            NSArray *array = [self.teamSearchResults objectAtIndex:indexPath.section];
            team = [array objectAtIndex:indexPath.row];
        }
        else
        {
            NSArray *array = [self.teamSectionized objectAtIndex:indexPath.section];
            team = [array objectAtIndex:indexPath.row];
        }
        
        CGRect rect = cell.cellScrollView.frame;
        rect.size.width = [UIScreen mainScreen].bounds.size.width - 16;
        [cell.cellScrollView setFrame:rect];
        
        [cell setRightUtilityButtons:[self rightButtonsWithTeamModel:team] WithButtonWidth:85.0f requirePaddingForSectionIndexer:YES];
        [cell setLeftUtilityButtons:[self leftButtonsWithTeamModel:team] WithButtonWidth:70.0f];
        
        cell.indexPath = indexPath;
        cell.objc = team;
        cell.users = _users;
        [cell configureCell];
    }
    else{
        
        if (self.isSearching)
        {
            
            NSArray *array = [self.searchResults objectAtIndex:indexPath.section];
            user = [array objectAtIndex:indexPath.row];
        }
        else
        {
            NSArray *array = [self.sectionizedUsers objectAtIndex:indexPath.section];
            user = [array objectAtIndex:indexPath.row];
        }
        
        cell.indexPath = indexPath;
        cell.objc = user;
        [cell configureCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if([tableView isEqual:self.teamTableView]){
        
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
    else{
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


- (NSArray *)leftButtonsWithTeamModel:(TeamModel*)team
{
    
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorFromHexCode:@"#FF5531"] icon:
     SET_IMAGE(@"btnDeleteTeam") andTitle:@"Delete"];
    return leftUtilityButtons;
}


- (NSArray *)rightButtonsWithTeamModel:(TeamModel*)team
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorFromHexCode:@"#12729F"] icon:
     SET_IMAGE(@"btnEditTeam") andTitle:@"Edit"];
    return leftUtilityButtons;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    __block TeamModel *team = nil;
    
    if (self.isSearching) {
        
        NSIndexPath *indexPath = [self.teamTableView indexPathForCell:cell];
        NSArray *array = [self.teamSearchResults objectAtIndex:indexPath.section];
        team = [array objectAtIndex:indexPath.row];
        self.selectedTeam = team;
        
    }else{
        
        NSIndexPath *indexPath = [self.teamTableView indexPathForCell:cell];
        NSArray *array = [self.teamSectionized objectAtIndex:indexPath.section];
        team = [array objectAtIndex:indexPath.row];
        self.selectedTeam = team;
    }
    
    switch (index) {
        case 0:
        {
            _customAlert.alertTag = 10001;
            _customAlert.alertType = kAlertTypeMessage;
            [self.customAlert showCustomAlertInView:self.view withMessage:NSLocalizedString(@"Delete Team", nil) andDescription:[NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Are you sure you want to delete", nil),team.name]];
            
            break;
        }
        default:
            break;
    }
    
    [cell hideUtilityButtonsAnimated:YES];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    
    TeamModel *team = nil;
    
    if (self.isSearching) {
        
        NSIndexPath *indexPath = [self.teamTableView indexPathForCell:cell];
        NSArray *array = [self.teamSearchResults objectAtIndex:indexPath.section];
        team = [array objectAtIndex:indexPath.row];
        
    }else{
        
        NSIndexPath *indexPath = [self.teamTableView indexPathForCell:cell];
        NSArray *array = [self.teamSectionized objectAtIndex:indexPath.section];
        team = [array objectAtIndex:indexPath.row];
    }
    
    
    switch (index) {
        case 0:
        {
            CreateTeamVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateTeamVC"];
            vc.team = team;
            vc.delegate = (id)self;
            vc.isConfirmEdit = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
        default:
            break;
    }
    
    [cell hideUtilityButtonsAnimated:YES];
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    
    TeamModel *team = nil;
    
    if (self.isSearching)
    {
        NSIndexPath *indexPath = [self.teamTableView indexPathForCell:cell];
        NSArray *array = [self.teamSearchResults objectAtIndex:indexPath.section];
        if ([array count]) {
            team = [array objectAtIndex:indexPath.row];
        }
    }
    else
    {
        NSIndexPath *indexPath = [self.teamTableView indexPathForCell:cell];
        NSArray *array = [self.teamSectionized objectAtIndex:indexPath.section];
        if ([array count]) {
            team = [array objectAtIndex:indexPath.row];
        }
    }
    
    if ([team.userId isEqualToString:[RapporrManager sharedManager].vcModel.userId] || [[RapporrManager sharedManager].vcModel.uType  isEqual: kUSER_TYPE_ADMIN]) {
        switch (state) {
            case 1:
                return YES;
                break;
            case 2:
                if (listType != kContacts) {
                    return YES;
                }
                return NO;
                break;
            default:
                break;
        }
    }else{
        return NO;
    }
    
    return NO;
}

-(void)getTeams
{
    [SVProgressHUD show];
    [self.searchBar performSelector:@selector(resignFirstResponder)
                         withObject:nil
                         afterDelay:0];
    [self.teamSearchBar performSelector:@selector(resignFirstResponder)
                             withObject:nil
                             afterDelay:0];
    
    [self.searchBar setText:@""];
    [self.teamSearchBar setText:@""];
    self.teams = [[NSMutableArray alloc] init];
    NetworkManager *nManager = [[NetworkManager alloc]init];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0];
    
    if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        
        [nManager getTeamsWithCompletion:^(BOOL success) {
            [[CoreDataController sharedManager] fetchTeamsFromDBWithCompletion:^(BOOL isFinished, NSMutableArray *array) {
                [SVProgressHUD dismiss];
                if (isFinished) {
                    self.teams = array;
                    [self prepareViewInitialData:self.teams];
                    [self.teamTableView reloadData];
                }
            }];
        }];
    }else{
        [appDelegate showUnavailablityAlert];
    }
}


-(void)getUserList
{
    
    [self.searchBar performSelector:@selector(resignFirstResponder)
                         withObject:nil
                         afterDelay:0];
    
    [self.teamSearchBar performSelector:@selector(resignFirstResponder)
                             withObject:nil
                             afterDelay:0];
    
    [self.searchBar setText:@""];
    [self.teamSearchBar setText:@""];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0];
    
    if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        [SVProgressHUD show];
        NetworkManager *nManager = [[NetworkManager alloc]init];
        [nManager getUserListWithCompletion:^(BOOL isCompleted) {
            self.users = [[CoreDataController sharedManager] fetchUserFromDBUnblockedUsers];
            
            if ([self.users count]) {
                [self prepareViewInitialData:self.users];
            }
        }];}else{
            [appDelegate showUnavailablityAlert];
        }
}


-(void)getTeamDataFromDb
{
    [[CoreDataController sharedManager] fetchTeamsFromDBWithCompletion:^(BOOL isFinished, NSMutableArray *array) {
        if (isFinished) {
            self.teams = array;
            [self prepareViewInitialData:self.teams];
            
        }
    }];
}

-(void)getUsersFromDB{
    
    self.users = [[CoreDataController sharedManager] fetchUserFromDBUnblockedUsers];
    if ([self.users count]) {
        [self prepareViewInitialData:self.users];
    }
}

-(void)didTeamUpdatedSuccessfully:(TeamModel *)team;
{

}

-(void)didTeamCreatedSuccessfully;
{
    self.isSearching = NO;
    //    [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"teamInitialLoad"];
    
    [self getTeams];
}

#pragma mark - UISearchBar Delegates

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    _expandIndexPath = nil;
    if([searchText isEqualToString:@""] || searchText==nil) {
        self.isSearching = false;
        
        [self.tableView reloadData];
        [self.teamTableView reloadData];
        
    }else{
        
        self.isSearching = YES;
        
        if(listType == kContacts || listType == kExternal){
            
            [self.searchResults removeAllObjects];
            
            NSPredicate *predicate = [NSPredicate
                                      predicateWithFormat:@"SELF.name contains[c] %@",
                                      searchText];
            
            for(NSArray *subAry in self.sectionizedUsers)
            {
                NSArray *result = [subAry filteredArrayUsingPredicate:predicate];
                if(result && result.count > 0)
                {
                    [self.searchResults addObjectsFromArray:result];
                }
            }
            
            if([searchText length] != 0) {
                self.isSearching = YES;
                if ([self.searchResults count]) {
                    [self prepareViewInitialData:self.searchResults];
                }
                [self.tableView reloadData];
                [self.teamTableView reloadData];
            }
            else {
                self.isSearching = NO;
            }
            
        }else if(listType == kMyTeams || listType == kAllTeams){
            
            [self.teamSearchResults removeAllObjects];
            
            NSPredicate *predicate = [NSPredicate
                                      predicateWithFormat:@"SELF.name CONTAINS[cd] %@ OR ANY SELF.members.fName CONTAINS[cd] %@", searchText, searchText];
            
            NSArray *arrFiltered = [self.teams filteredArrayUsingPredicate:predicate];
            self.teamSearchResults = [arrFiltered mutableCopy];
            
            if([searchText length] != 0) {
                self.isSearching = YES;
                if([self.teamSearchResults count]){
                    [self prepareViewInitialData:self.teamSearchResults];
                }
                [self.tableView reloadData];
                [self.teamTableView reloadData];
            }
            else {
                self.isSearching = NO;
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

#pragma mark - UserProfileViewControllerDelegate

-(void)didDeactivateUserSuccess:(ConversationUser *)user;
{
    for(id item in self.users) {
        if([item isEqual:user]) {
            [self.users removeObject:item];
            break;
        }
    }
    [self prepareViewInitialData:self.users];
}

-(void)didUpdatedUserSuccess:(ConversationUser *)user;
{
   [self prepareViewInitialData:self.users];
}


#pragma mark - VCFloatingActionButton

- (void)addFloatingButtonOnContact
{
    
    CGRect floatFrame = CGRectMake(_contactsFirstSegView.bounds.size.width - 60 - 20, _contactsFirstSegView.bounds.size.height - 90 , 60, 60);
    
    VCFloatingActionButton *addMenuButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:SET_IMAGE(@"new_team_contact") andPressedImage:SET_IMAGE(@"new_team_contact") withScrollview:_tableView];
    addMenuButton.layer.shadowColor = [UIColor blackColor].CGColor;
    addMenuButton.layer.shadowOffset = CGSizeMake(1, 1);
    addMenuButton.layer.shadowOpacity = 0.3;
    addMenuButton.layer.shadowRadius = 2.0;
    addMenuButton.hideWhileScrolling = NO;
    addMenuButton.delegate = (id)self;
    addMenuButton.tag = 200;
    [self.contactsFirstSegView addSubview:addMenuButton];
}


- (void)addFloatingButtonOnTeam {
    
    CGRect floatFrame = CGRectMake(_contactsTeamSegView.bounds.size.width - 60 - 20, _contactsFirstSegView.bounds.size.height - 90 , 60, 60);
    
    VCFloatingActionButton *addMenuButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:SET_IMAGE(@"createTeam") andPressedImage:SET_IMAGE(@"createTeam") withScrollview:_tableView];
    addMenuButton.layer.shadowColor = [UIColor blackColor].CGColor;
    addMenuButton.layer.shadowOffset = CGSizeMake(1, 1);
    addMenuButton.layer.shadowOpacity = 0.3;
    addMenuButton.layer.shadowRadius = 2.0;
    addMenuButton.hideWhileScrolling = NO;
    addMenuButton.delegate = (id)self;
    addMenuButton.tag = 300;
    [self.contactsTeamSegView addSubview:addMenuButton];
}

-(void) didSelectMenuOptionAtIndex:(NSInteger)row
{
    NSLog(@"Floating action tapped index %tu",row);
}

-(void) didMenuButtonTapped:(id)button;
{
    VCFloatingActionButton *btn = (VCFloatingActionButton*)button;
    
    if (btn.tag == 200){
        [self.view endEditing:YES];
        self.tabBarController.tabBar.hidden = YES;
        [self.view bringSubviewToFront:self.actionBgView];
        [self.actionBgView setHidden:NO];
        [Utils moveViewPosition:self.view.bounds.size.height - self.actionSheetButtonView.bounds.size.height onView:self.actionSheetButtonView completion:^(BOOL finished) {
        }];
        
    }
    else if(btn.tag == 300){
        CreateTeamVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateTeamVC"];
        vc.delegate = (id)self;
        [self.view endEditing:YES];
        [self.navigationController pushViewController:vc animated:NO];
    }
}

-(void)setupRefreshControl
{
    _refresh = [[UIRefreshControl alloc] init];
    _refresh.backgroundColor = [UIColor clearColor];
    [_refresh setTintColor:[UIColor clearColor]];
    [_refresh addTarget:self action:@selector(getUserList) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
    
}

- (void)stopRefresh
{
    [self.refresh endRefreshing];
    [self.refreshTeams endRefreshing];
}

-(void)setupRefreshControlForTeams{
    
    self.refreshTeams = [[UIRefreshControl alloc] init];
    self.refreshTeams.backgroundColor = [UIColor clearColor];
    [self.refreshTeams setTintColor:[UIColor clearColor]];
    [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"teamInitialLoad"];
    [self.refreshTeams addTarget:self action:@selector(getTeams) forControlEvents:UIControlEventValueChanged];
    [self.teamTableView addSubview:self.refreshTeams];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CreateTeam"]) {
        
        CreateTeamVC *destSegue = [segue destinationViewController];
        destSegue.delegate = (id)self;
        destSegue.userList = self.users;
    }
}

- (void)actionSheetCancel:(FDActionSheet *)actionSheet;{}
- (void)actionSheet:(FDActionSheet *)sheet clickedButtonIndex:(NSInteger)buttonIndex;{
    
    if(buttonIndex == 0){
        
        self.peoplePicker.fieldMask = ZLContactFieldAll;
        self.peoplePicker.numberOfSelectedPeople = ZLNumSelectionNone;
        self.peoplePicker = [ZLPeoplePickerViewController presentPeoplePickerViewControllerForParentViewController:self];
        self.peoplePicker.numberOfSelectedPeople = 1;
        self.peoplePicker.delegate = self;
        
    }else if(buttonIndex == 1){
        InviteNewUserVC *inviteNewUserVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteNewUserVC"];
        inviteNewUserVC.delegate = (id)self;
        
        self.navigationController.tabBarController.tabBar.hidden = YES;
        [self.navigationController pushViewController:inviteNewUserVC  animated:YES];
    }
}

-(void)didNewUserAdded;
{
    [self getUserList];
}

#pragma mark - ZLPeoplePickerViewControllerDelegate
- (void)peoplePickerViewController:(ZLPeoplePickerViewController *)peoplePicker
                   didSelectPerson:(NSNumber *)recordId {
    
    [self getPersonContactInfo:recordId];
    
}


- (void)peoplePickerViewController:(ZLPeoplePickerViewController *)peoplePicker didReturnWithSelectedPeople:(NSSet *)people {
    if (!people || people.count == 0) {
        return;
    }else{
        
    }
}

- (void)newPersonViewControllerDidCompleteWithNewPerson:(nullable ABRecordRef)person {
    
}

#pragma mark Display and edit a person
- (void)showPersonViewController:(ABRecordID)recordId onNavigationController: (UINavigationController *)navigationController {
    
    ABRecordRef person = (ABRecordRef)(ABAddressBookGetPersonWithRecordID(self.addressBookRef, recordId));
    
    if (person != NULL) {
        
        ABPersonViewController *picker = [[ABPersonViewController alloc] init];
        picker.personViewDelegate = self;
        picker.displayedPerson = person;
        picker.allowsEditing = NO;
        picker.allowsActions = NO;
        picker.shouldShowLinkedPeople = YES;
        [navigationController pushViewController:picker animated:YES];
    } else {
        // Show an alert if "Appleseed" is not in Contacts
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Error"
                                   message:@"Could not find the person in " @"the Contacts application"
                                  delegate:nil
                         cancelButtonTitle:@"Cancel"
                         otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark ABPersonViewControllerDelegate methods
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier: (ABMultiValueIdentifier)identifierForValue {
    return NO;
}

- (id)getPersonContactInfo:(NSNumber *)recordId {
    
    APAddressBook *abook = [[APAddressBook alloc]init];
    
    [abook loadContactByRecordID:recordId completion:^(APContact * _Nullable contact) {
        
        APName *name = contact.name;
        
        NSArray <APPhone*> *phones = contact.phones;
        APPhone* phone = nil;
        if([phones count]){
            phone = [phones objectAtIndex:0];
        }
        __weak __typeof(self)weakSelf = self;
        
        weakSelf.selectedContact = contact;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self setUpAlertView];
            _customAlert.alertTag = 10000;
            _customAlert.alertType = kAlertTypeDetail;
            UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
            
            [weakSelf.customAlert showCustomAlertInView2:top.view
                                             withMessage:NSLocalizedString(@"Choose Contact", nil)
                                          andDescription:NSLocalizedString(@"Please check the details before proceeding", nil)
                                              detailHead:NSLocalizedString(@"Details -", nil)
                                                 andName:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Name : ", nil),name.firstName]
                                                andPhone:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Phone : ", nil),phone.number]];
            
            
        }];
    }];
    
    return nil;
}


- (ABRecordRef)recordRefFromRecordId:(NSNumber *)recordId {
    return ABAddressBookGetPersonWithRecordID(self.addressBookRef,
                                              [recordId intValue]);
}

- (void) setUpAlertView {
    _customAlert = [[RapporrAlertView alloc] init];
    [_customAlert setDelegate:(id)self];
}

-(void)RapporrAlertOK:(id)sender{
    
    RapporrAlertView *alertView = _customAlert;
    self.isSearching = NO;
    
    if (alertView.alertTag == 10000) {
        
        APName *name = self.selectedContact.name;
        NSArray <APPhone*> *phones = self.selectedContact.phones;
        APPhone* phone = nil;
        if([phones count]){
            phone = [phones objectAtIndex:0];
        }
        
        NSDictionary *param = @{
                                @"name": [NSString stringWithFormat:@"%@",name.firstName],
                                @"phone": [NSString stringWithFormat:@"%@",phone.number],
                                @"organisationId":[RapporrManager sharedManager].vcModel.orgId,
                                @"invitername":[RapporrManager sharedManager].vcModel.userName
                                };
        
        
        if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {

        [NetworkManager inviteUser:param success:^(id data ,NSString *timestamp) {
            
            [self.navigationController.view makeToast:[NSString stringWithFormat:@"%@ was successfully added as a contact.",name.firstName]];
            
            [self getUserList];
            
            
        } failure:^(NSError *error) {
            NSLog(@"%@",[error description]);
        }];
        }
        else{
            [appDelegate showUnavailablityAlert];
        }
    }
    else if (alertView.alertTag == 10001) {
        
        if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {

        NSMutableArray *users = [[NSMutableArray alloc]init];
        
        for (ConversationUser *user in self.selectedTeam.members) {
            [users addObject:user.fullId];
        }
        
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
        NSString *teamName = self.selectedTeam.name;
        NSString *userID = [RapporrManager sharedManager].vcModel.userId;
        NSString *fullid = [NSString stringWithFormat:@"%@",self.selectedTeam.callBackId];
        NSString *callBackId = [NSString stringWithFormat:@"%@",self.selectedTeam.callBackId];
        
        NSDictionary *paramsToBeSent = @{
                                         @"hostid" : hostID,
                                         @"orgid" :  organizationID,
                                         @"name" :  teamName,
                                         @"userid" : userID,
                                         @"callbackid" : callBackId,
                                         @"status" : @"inactive",
                                         @"type" :   @"shared",
                                         @"fullid" : fullid,
                                         @"publicid":@"",
                                         @"active" : @"false",
                                         @"objects" : usersDic
                                         };
        
        [NetworkManager createNewTeam:URI_CREATE_TEAM parameters:paramsToBeSent success:^(id data, NSString *timestamp) {
                        
            [[CoreDataController sharedManager] removeTeam:self.selectedTeam];
            
            [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"teamInitialLoad"];
            [self getTeams];
            
        }failure:^(NSError *error) {
            NSLog(@"Error");
        }];
        }
        else{
            [appDelegate showUnavailablityAlert];
        }
    }else if (_customAlert.alertTag == 10099 && _customAlert.alertType == kAlertTypePopup) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    [_customAlert removeCustomAlertFromViewInstantly];
}


-(void)RapporrAlertCancel{
    [_customAlert removeCustomAlertFromViewInstantly];
}

-(void)setUpUISegmentControl:(UISegmentedControl *)seg{
    
    
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"STHeitiSC-Medium" size:13.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    for (int i=0; i<[seg.subviews count]; i++)
    {
        if ([[seg.subviews objectAtIndex:i] respondsToSelector:@selector(isSelected)] && [[seg.subviews objectAtIndex:i]isSelected])
        {
            [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : ROBOTO_REGULAR(17)} forState:UIControlStateSelected];
        }
        if ([[seg.subviews objectAtIndex:i] respondsToSelector:@selector(isSelected)] && ![[seg.subviews objectAtIndex:i] isSelected])
        {
            [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName : ROBOTO_REGULAR(17)} forState:UIControlStateNormal];
        }
    }
}

- (IBAction)actionSheetButtons:(UIButton *)sender {
    
    [Utils moveViewPosition:1000 onView:self.actionSheetButtonView completion:^(BOOL finished) {
        [self.actionBgView setHidden:YES];
        self.tabBarController.tabBar.hidden = NO;
    }];
    
    if (sender.tag == 350) {
        [self initializeContactPicker];
    }else if (sender.tag == 351){
        InviteNewUserVC *inviteNewUserVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteNewUserVC"];
        inviteNewUserVC.delegate = (id)self;
        self.navigationController.tabBarController.tabBar.hidden = YES;
        [self.navigationController pushViewController:inviteNewUserVC  animated:YES];
    }
}


-(void)initializeContactPicker{
    
    _addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    APAddressBookAccessRoutine *addressBookAccessRoutine = [[APAddressBookAccessRoutine alloc] init];
    [addressBookAccessRoutine requestAccessWithCompletion:^(BOOL granted, NSError *error) {
        if (granted) {
            [self showContacts];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showContactsAlert];
            });
        }
    }];
}

-(void)showContactsAlert {
    
    [self setUpAlertView];
    _customAlert.alertTag = 10099;
    _customAlert.alertType = kAlertTypePopup;
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self.customAlert showPopUpInView:top.view withMessage:NSLocalizedString(@"Alert!", nil) andDescription:NSLocalizedString(@"This app requires contacts access to function properly.", nil)];
}

-(void)showContacts
{
    [ZLPeoplePickerViewController initializeAddressBook];
    [[UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setBarTintColor:[UIColor blackColor]];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setTintColor:[UIColor blackColor]];
    
    self.peoplePicker.fieldMask = ZLContactFieldAll;
    self.peoplePicker.numberOfSelectedPeople = ZLNumSelectionNone;
    self.peoplePicker = [ZLPeoplePickerViewController presentPeoplePickerViewControllerForParentViewController:self];
    self.peoplePicker.numberOfSelectedPeople = 1;
    self.peoplePicker.delegate = self;
    
}


- (IBAction)btnHideActionSheet:(id)sender {
    [Utils moveViewPosition:1000 onView:self.actionSheetButtonView completion:^(BOOL finished) {
        [self.actionBgView setHidden:YES];
        self.tabBarController.tabBar.hidden = NO;
    }];
}


-(void)keyboardWillShow:(NSNotification *)notification {
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float height = MIN(keyboardSize.height,keyboardSize.width);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    
    CGRect tableViewRect = self.tableView.frame;
    tableViewRect.size.height = self.view.frame.size.height - height - 150;
    self.tableView.frame = tableViewRect;
    self.teamTableView.frame = tableViewRect;
    
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float height = MIN(keyboardSize.height,keyboardSize.width);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGRect tableViewRect = self.tableView.frame;
    tableViewRect.size.height = self.view.frame.size.height - height + 15;
    self.tableView.frame = tableViewRect;
    self.teamTableView.frame = tableViewRect;
    
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
    
    [self.view endEditing:YES];
    
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
