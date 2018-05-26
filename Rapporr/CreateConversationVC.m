//
//  CreateConversationVC.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 14/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "CreateConversationVC.h"

static NSString *cellIdentifier = @"CreateTeamCell";

@interface CreateConversationVC ()

@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@end

@implementation CreateConversationVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setUpAlertView];
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    [self.txtFieldTitle setLimit:25];
    self.txtFieldTitle.delegate = (id)self;
    
    [Utils prepareSearchBarUI:self.tableSearchBar];
    [Utils prepareSearchBarUI:self.collectionSearchBar];
    
    self.isKeyboardActive = NO;
    listType = kContacts;
    contentType = kCONTENTTypeCollection;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CreateTeamCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"CreateTeamCollectionCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CreateTeamCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    [self setupSegmentsWithTabs:@[@"Company", @"External", @"Teams"] andTag:200 inView:self.SegmentContainer];
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.users = [[NSMutableArray alloc]init];
    self.sectionizedUsers = [[NSMutableArray alloc]init];
    self.tableResults = [[NSMutableArray alloc]init];
    
    self.teamSectionized = [[NSMutableArray alloc]init];
    self.collectionResults = [[NSMutableArray alloc]init];
    self.teams = [[NSMutableArray alloc] init];
    
    self.dataArray = [[NSMutableArray alloc]init];
    
    self.users = [[CoreDataController sharedManager] fetchUserFromDBUnblockedUsers];
    
    if ([self.users count]<=0) {
        [self getUserFromDB];
    }else{
        [self prepareViewInitialData:self.users];
    }
    
    if (![self.teams count]) {
        NetworkManager *nManager = [[NetworkManager alloc]init];
        [nManager getTeamsWithCompletion:^(BOOL success) {
        }];
        [SVProgressHUD dismiss];
    }
    
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    UITapGestureRecognizer *hideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    
    hideKeyboard.cancelsTouchesInView = NO;
    hideKeyboard.delegate = (id)self;
    self.view.tag = 1000;
    [self.view addGestureRecognizer:hideKeyboard];
    
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)btnCancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:NO];
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

- (IBAction)listPressed:(id)sender {
    
    contentType = kCONTENTTypeTable;
    
    [_listBtn setBackgroundImage:[UIImage imageNamed:@"list_sel"] forState:UIControlStateNormal];
    [_gridBtn setBackgroundImage:[UIImage imageNamed:@"grid_normal"] forState:UIControlStateNormal];
    
    _tableContainerView.hidden = NO;
    _collectionContainerView.hidden = YES;
    
    _isSearching = NO;
    [self.tableSearchBar performSelector:@selector(resignFirstResponder)
                              withObject:nil
                              afterDelay:0];
    
    [self.collectionSearchBar performSelector:@selector(resignFirstResponder)
                                   withObject:nil
                                   afterDelay:0];
    
    [self.tableSearchBar setText:@""];
    [self.collectionSearchBar setText:@""];
    
    listType = kContacts;
    
    self.contactSegment.selectedSegmentIndex = 0;
    
    if (![self.users count]) {
        [self getUserFromDB];
    }else{
        [self prepareViewInitialData:self.users];
    }
}

- (IBAction)gridPressed:(id)sender {
    
    contentType = kCONTENTTypeCollection;
    
    [_listBtn setBackgroundImage:[UIImage imageNamed:@"list_normal"] forState:UIControlStateNormal];
    [_gridBtn setBackgroundImage:[UIImage imageNamed:@"grid_sel"] forState:UIControlStateNormal];
    _isSearching = NO;
    
    _tableContainerView.hidden = YES;
    _collectionContainerView.hidden = NO;
    
    [self.tableSearchBar performSelector:@selector(resignFirstResponder)
                              withObject:nil
                              afterDelay:0];
    
    [self.collectionSearchBar performSelector:@selector(resignFirstResponder)
                                   withObject:nil
                                   afterDelay:0];
    
    [self.tableSearchBar setText:@""];
    [self.collectionSearchBar setText:@""];
    listType = kContacts;
    
    self.contactSegment.selectedSegmentIndex = 0;
    
    if (![self.users count]) {
        [self getUserFromDB];
    }else{
        [self prepareViewInitialData:self.users];
    }
}

- (IBAction)btnDone:(id)sender {
    
    NSMutableArray *users = [[NSMutableArray alloc]init];
    
    for (ConversationUser *user in self.users) {
        if (user.isSelected && ![user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]) {
            [users addObject:user.fullId];
        }
    }
    
    NSString *title = self.txtFieldTitle.text;
    
    if (title.length <5) {
        _customAlert.alertTag = 10002;
        _customAlert.alertType = kAlertTypePopup;
        NSString *message = [NSString stringWithFormat:@"Conversation title should be great than 5 chars"];
        [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Error",nil) andDescription:NSLocalizedString(message,nil)];
        
    }else if([users count] == 0){
        
        _customAlert.alertTag = 10002;
        _customAlert.alertType = kAlertTypePopup;
        NSString *message = [NSString stringWithFormat:@"Select users to start conversation"];
        [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Error",nil) andDescription:NSLocalizedString(message,nil)];
        
    }else{
        
        [users addObject:[RapporrManager sharedManager].vcModel.userId];
        
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
        
        for (NSString *ids in users) {
            [usersDict setObject:@"" forKey:ids];
        }
        
        NSString *usersDic = [usersDict jsonString];
        NSString *objects = [@{@"permittedToAddUsers":@1} jsonString];
        
        
        NSDictionary *dict = @{
                               @"organisation" : [NSString stringWithFormat:@"%@",organizationID],
                               @"user"         : [NSString stringWithFormat:@"%@",userID],
                               @"about"        : [NSString stringWithFormat:@"%@",title],
                               @"tags"         : @"",
                               @"users"        : usersDic,
                               @"template"     : @"",
                               @"callBackId"   : [NSString stringWithFormat:@"%@",callBackId],
                               @"objects"      : objects,
                               @"userList"     : users
                               };
        
        
        ConversationDetailVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationDetailVC"];
        vc.conversationDictData = dict;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    
    
    
    [self.tableSearchBar performSelector:@selector(resignFirstResponder)
                              withObject:nil
                              afterDelay:0];
    
    [self.collectionSearchBar performSelector:@selector(resignFirstResponder)
                                   withObject:nil
                                   afterDelay:0];
    
    [self.tableSearchBar setText:@""];
    [self.collectionSearchBar setText:@""];
    
    
    if (segmentedControl.tag == 200) {
        
        self.isSearching = NO;
        
        [self.teamSectionized removeAllObjects];
        [self.sectionizedUsers removeAllObjects];
        [self.dataArray removeAllObjects];
        [self.collectionResults removeAllObjects];
        
        [self.tableView reloadData];
        [self.collectionView reloadData];
        
        if (segmentedControl.selectedSegmentIndex == 0) {
            listType = kContacts;
            
            if (![self.users count]) {
                [self getUserFromDB];
            }else{
                [self prepareViewInitialData:self.users];
            }
            
        }else if (segmentedControl.selectedSegmentIndex == 1) {
            
            listType = kExternal;
            if (![self.users count]) {
                [self getUserFromDB];
            }else{
                [self prepareViewInitialData:self.users];
            }
            
        }else if (segmentedControl.selectedSegmentIndex == 2) {
            listType = kAllTeams;
            if (![self.teams count]) {
                [self getTeamsFromDB];
            }else{
                [self prepareViewInitialData:self.teams];
            }
        }
    }
}


- (void)uisegmentedControlChangedValue:(UISegmentedControl *)segmentedControl
{
    
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
        else if(listType == kAllTeams)
        {
            
            NSMutableArray *sections = [NSMutableArray array];
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            if(self.isSearching){
                for (TeamModel *team in dataList) {
                    //                if (![[RapporrManager sharedManager].vcModel.userId isEqualToString:team.userId]) {
                    NSInteger section = [collation sectionForObject:team collationStringSelector:@selector(name)];
                    [sections addObject:team toSubarrayAtIndex:section];
                    //                }
                }
                
                NSInteger section = 0;
                for (section = 0; section < [sections count]; section++) {
                    NSArray *sortedSubarray = [collation sortedArrayFromArray:[sections objectAtIndex:section]
                                                      collationStringSelector:@selector(name)];
                    [sections replaceObjectAtIndex:section withObject:sortedSubarray];
                }
                
                _tableResults = [sections mutableCopy];
                
            }
            else{
                
                NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                        ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                dataList = [[dataList sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                
                
                for (TeamModel *team in dataList) {
                    //                if (![[RapporrManager sharedManager].vcModel.userId isEqualToString:team.userId]) {
                    
                    NSInteger section = [collation sectionForObject:team collationStringSelector:@selector(name)];
                    [sections addObject:team toSubarrayAtIndex:section];
                    //                }
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
            else if(listType == kAllTeams){
                
                NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                        ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                
                dataList = [[dataList sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                self.collectionResults = [dataList mutableCopy];
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
            else if(listType == kAllTeams)
            {
                NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                        ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                
                dataList = [[dataList sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                self.dataArray = [dataList mutableCopy];
                
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
    
    [self.tableSearchBar performSelector:@selector(resignFirstResponder)
                              withObject:nil
                              afterDelay:0];
    
    [self.collectionSearchBar performSelector:@selector(resignFirstResponder)
                                   withObject:nil
                                   afterDelay:0];
    
    [self.tableSearchBar setText:@""];
    [self.collectionSearchBar setText:@""];
    
    if (![self.users count]) {
        self.users = [[CoreDataController sharedManager] fetchUserFromDBUnblockedUsers];
        if ([self.users count]) {
            [self prepareViewInitialData:self.users];
        }
    }
}


-(void)getTeamsFromDB
{
    
    [self.tableSearchBar performSelector:@selector(resignFirstResponder)
                              withObject:nil
                              afterDelay:0];
    
    [self.collectionSearchBar performSelector:@selector(resignFirstResponder)
                                   withObject:nil
                                   afterDelay:0];
    
    [self.tableSearchBar setText:@""];
    [self.collectionSearchBar setText:@""];
    
    if (![self.teams count]) {
        
        [[CoreDataController sharedManager] fetchTeamsFromDBWithCompletion:^(BOOL isFinished, NSMutableArray *array) {
            if (isFinished) {
                self.teams = array;
                [self prepareViewInitialData:self.teams];
            }
        }];
        
    }
}

-(void)keyboardWillShow:(NSNotification *)notification {
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float height = MIN(keyboardSize.height,keyboardSize.width);
    CGRect tableViewRect = self.tableContainerView.frame;
    CGRect collectionViewRect = self.collectionContainerView.frame;
    
    
    if (self.isKeyboardActive == NO) {
        
        tableViewRect.size.height = self.tableContainerView.frame.size.height - height;
        collectionViewRect.size.height = self.collectionContainerView.frame.size.height - height;
        self.isKeyboardActive = YES;
    }
    self.tableContainerView.frame = tableViewRect;
    self.collectionContainerView.frame = collectionViewRect;
    [UIView commitAnimations];
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float height = MIN(keyboardSize.height,keyboardSize.width);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect tableViewRect = self.tableContainerView.frame;
    tableViewRect.size.height = self.view.frame.size.height - self.tableContainerView.frame.origin.y - self.tableSearchBar.frame.size.height - 22;
    self.tableContainerView.frame = tableViewRect;
    
    CGRect collectionViewRect = self.collectionContainerView.frame;
    collectionViewRect.size.height = self.view.frame.size.height - self.collectionContainerView.frame.origin.y - self.tableSearchBar.frame.size.height - 22;
    self.collectionContainerView.frame = collectionViewRect;
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
    
    //    static NSString *CellIdentifier = @"cell";
    //    UserContactTVCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //
    //    self.tableView.sectionIndexBackgroundColor = [UIColor whiteColor];
    //
    //    if (cell == nil) {
    //        cell = [[UserContactTVCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //    }
    //
    //    TeamModel *team = nil;
    //
    //    if([tableView isEqual:self.tableView]){
    //
    //        if (self.isSearching)
    //        {
    //            NSArray *array = [self.teamSearchResults objectAtIndex:indexPath.section];
    //            team = [array objectAtIndex:indexPath.row];
    //        }
    //        else
    //        {
    //            NSArray *array = [self.teamSectionized objectAtIndex:indexPath.section];
    //            team = [array objectAtIndex:indexPath.row];
    //        }
    //    }
    //
    //
    //    [cell.lblUserJobDesc setText:team.membersListString];
    //    CGSize newSize = [cell.lblUserJobDesc sizeOfMultiLineLabel];
    
    
    return 66;
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
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            user.isSelected = YES;
        }
    }else if (listType == kAllTeams) {
        if (_isSearching)
        {
            NSArray *array = [self.tableResults objectAtIndex:indexPath.section];
            team = [array objectAtIndex:indexPath.row];
            
            if (team.isSelected) {
                team.isSelected = NO;
            }
            else {
                team.isSelected = YES;
            }
            
            
            for (ConversationUser *user in team.members) {
                if (team.isSelected) {
                    user.isSelected = YES;
                }else{
                    user.isSelected = NO;
                }
            }
        }
        else
        {
            NSArray *array = [self.teamSectionized objectAtIndex:indexPath.section];
            team = [array objectAtIndex:indexPath.row];
            
            if (team.isSelected) {
                team.isSelected = NO;
            }
            else {
                team.isSelected = YES;
            }
            
            
            for (ConversationUser *teamMember in team.members) {
                for (ConversationUser *user in self.users) {
                    if ([teamMember.fullId isEqualToString:user.fullId]) {
                        if (team.isSelected) {
                            user.isSelected = YES;
                        }else{
                            user.isSelected = NO;
                        }
                    }
                }
            }
            
            
            
        }
        
        
        
        
        
        //        if(![user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]){
        NSArray *indexPaths = @[indexPath];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        team.isSelected = YES;
    }
    //    }
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
        }else if (listType == kAllTeams) {
            
            if (self.isSearching)
            {
                return [self.tableResults count];
            }else{
                return [self.teamSectionized count];
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
        }else if (listType == kAllTeams) {
            if (self.isSearching) {
                return nil;
            } else {
                return [[self.teamSectionized objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
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
        else if (listType == kAllTeams) {
            if (self.isSearching) {
                sectionTitle = @"";
            } else {
                sectionTitle = [[self.teamSectionized objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
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
        else if (listType == kAllTeams) {
            
            if (self.isSearching)
            {
                return [[self.tableResults objectAtIndex:section] count];
            }
            else
            {
                return [[self.teamSectionized objectAtIndex:section] count];
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
    TeamModel *team = nil;
    
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
                
                UIImage *placeholder = [UIImage imageNamed:@"placeholder_user"];
                if([Utils hasCachedImage]){
                    placeholder = [Utils loadImage];
                }
                
                [cell.mainImg setImageWithURL:imageUrl placeholderImage:placeholder options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];


            }
            else {
                
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
        }else if (listType == kAllTeams) {
            
            if (self.isSearching)
            {
                NSArray *array = [self.tableResults objectAtIndex:indexPath.section];
                team = [array objectAtIndex:indexPath.row];
            }
            else
            {
                NSArray *array = [self.teamSectionized objectAtIndex:indexPath.section];
                team = [array objectAtIndex:indexPath.row];
            }
            
            cell.titleLbl.text = team.name;
            cell.jobTitleLbl.text = @"";
            
            if(user.avatarUrl.length > 1) {
                
                NSURL *imageUrl = [NSURL URLWithString:team.avatarUrl];
                [cell.mainImg setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

            }
            else {
                [cell.mainImg setImageWithString:team.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
            }
            
            if(team.isSelected ){
                cell.tickImg.hidden = false;
                team.isSelected = YES;
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
                [tableView scrollRectToVisible:self.tableSearchBar.frame animated:NO];
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
            else if(listType == kAllTeams){
                
                [self.tableResults removeAllObjects];
                
                
                NSPredicate *predicate = [NSPredicate
                                          predicateWithFormat:@"SELF.name contains[c] %@",
                                          searchText];
                
                for(NSArray *subAry in self.teamSectionized)
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
            else if(listType == kAllTeams){
                
                [self.collectionResults removeAllObjects];
                
                NSPredicate *predicate = [NSPredicate
                                          predicateWithFormat:@"SELF.name contains[c] %@",
                                          searchText];
                
                NSArray *result = [self.teams filteredArrayUsingPredicate:predicate];
                
                
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
        else if (listType == kAllTeams) {
            
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
                
                UIImage *placeholder = [UIImage imageNamed:@"placeholder_user"];
                if([Utils hasCachedImage]){
                    placeholder = [Utils loadImage];
                }
                
                [cell.mainImg setImageWithURL:imageUrl placeholderImage:placeholder options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

                
            }
            else {
                
                cell.contactTxtLbl.text = [Utils getInitialsFromString:user.name];
                cell.contactTxtLbl.hidden = false;
                cell.contactTxtLbl.backgroundColor = [UIColor colorFromHexCode:@"#FF9433"];
                
//                [cell.mainImg setImageWithString:user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
            }
            
            if(user.isSelected){
                cell.tickImg.hidden = NO;
            }
            else {
                cell.tickImg.hidden = YES;
            }
            
        }else if (listType == kAllTeams) {
            
            TeamModel *team = nil;
            
            if (self.isSearching)
            {
                team = [self.collectionResults objectAtIndex:indexPath.row];
            }
            else
            {
                team = [self.dataArray objectAtIndex:indexPath.row];
            }
            
            cell.titleLbl.text = team.name;
            
            if(team.avatarUrl.length > 1) {
                
                NSURL *imageUrl = [NSURL URLWithString:team.avatarUrl];
                [cell.mainImg setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            }
            else {
                [cell.mainImg setImageWithString:team.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
            }
            
            if(team.isSelected){
                cell.tickImg.hidden = NO;
            }
            else {
                cell.tickImg.hidden = YES;
            }
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ConversationUser *user = nil;
    TeamModel *team = nil;
    
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
        
    }else if (listType == kAllTeams) {
        
        if (_isSearching)
        {
            team = [self.collectionResults objectAtIndex:indexPath.row];
            
            if (team.isSelected) {
                team.isSelected = NO;
            }
            else {
                team.isSelected = YES;
            }
            
            
            for (ConversationUser *user in team.members) {
                if (team.isSelected) {
                    user.isSelected = YES;
                }else{
                    user.isSelected = NO;
                }
            }
        }
        else
        {
            team = [self.dataArray objectAtIndex:indexPath.row];
            
            if (team.isSelected) {
                team.isSelected = NO;
            }
            else {
                team.isSelected = YES;
            }
            
            
            for (ConversationUser *teamMember in team.members) {
                for (ConversationUser *user in self.users) {
                    if ([teamMember.fullId isEqualToString:user.fullId]) {
                        if (team.isSelected) {
                            user.isSelected = YES;
                        }else{
                            user.isSelected = NO;
                        }
                    }
                }
            }
        }
        [self.collectionView reloadData];
    }
    else {
        team.isSelected = YES;
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
        [self.btnDone setTitleColor:[UIColor colorFromHexCode:@"#FF5721"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    self.lblCounter.text = [NSString stringWithFormat:@"%ld/25",(long)currentLength];
}

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
