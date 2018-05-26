//
//  MessageVC.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 06/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//
@import FirebaseMessaging;
@import Firebase;
#import "MessageVC.h"
#import "MessageCell.h"
#import "NetworkManager.h"
#import "DataManager.h"
#import "Constants.h"
#import "RapporrManager.h"
#import "VCFloatingActionButton.h"
#import "CoreDataController.h"
#import "ConversationUser.h"
#import "UIImageView+Letters.h"
#import <QuartzCore/QuartzCore.h>
#import "RKDropdownAlert.h"
#import "CreateConversationVC.h"



@interface MessageVC ()

@end

@implementation MessageVC
@synthesize addMenuButton;

- (void)loadView{
    
    [super loadView];
    
    [self addFloatingButton];
    [self setUpAlertView];
    [self addScrollToTop];
    
}

- (void) refreshViewforNotification {
    [self updateData];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewforNotification) name:@"refreshViewForNotification" object:nil];
    self.reachabilityStatus = appDelegate.seachabilityStatus;

    
    currentPage = 1;
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(receiveTestNotification:) name:@"NewConversation" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(receiveTestNotification:) name:@"NewMessage" object:nil];
   
    searchResults = [[NSMutableArray alloc]init];
    
    [Utils prepareSearchBarUI:self.searchBar];    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [self updateNavigationBar:[RapporrManager sharedManager].vcModel];
    [self setupRefreshControl];
    
    CGRect frame = self.mainTblView.bounds;
    frame.origin.y = -frame.size.height;
    UIView* bgView = [[UIView alloc] initWithFrame:frame];
    bgView.backgroundColor = [UIColor colorFromHexCode:@"#EFEFF4"];
    [self.mainTblView insertSubview:bgView atIndex:0];
    
    [self adjustTabBarImageOffset];
    
    UITapGestureRecognizer *hideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:hideKeyboard];
    
    //register device for push notification
    [self subscribePushNotifications];
}

- (void) subscribePushNotifications {
    
    NSString *deviceToken = [FIRInstanceID instanceID].token;
    
    NSDictionary *paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:[RapporrManager sharedManager].vcModel.hostID,@"host",[RapporrManager sharedManager].vcModel.userId,@"userid",[RapporrManager sharedManager].vcModel.orgId,@"orgId",deviceToken,@"deviceId",@"iOSv3",@"platform",nil];
    
    NSString *uri = @"/user/subscribe";
    
    [NetworkManager subscribeToPushNotification:uri andDeviceToken:deviceToken parameters:paramsToBeSent success:^(id data, NSString *timestamp) {
        
        
    }failure:^(NSError *error) {
        NSLog(@"Error");
    }];
}

- (void)hideKeyboard:(UITapGestureRecognizer*)sender {
    
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    appDelegate.delegate = (id)self;
    self.reachabilityStatus = appDelegate.seachabilityStatus;

    self.navigationController.tabBarController.tabBar.hidden = NO;
    
    self.navigationController.swipeBackEnabled = NO;


    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.mainTblView reloadData];
    
}


-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

-(void)setupRefreshControl{
    
    _refresh = [[UIRefreshControl alloc] init];
    _refresh.backgroundColor = [UIColor clearColor];
    [_refresh setTintColor:[UIColor clearColor]];
    [_refresh addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.mainTblView addSubview:self.refresh];
    
}

- (void)stopRefresh
{
    [self.refresh endRefreshing];
}

- (void)updateNavigationBar:(VerifiedCompanyModel *) company {
    
    self.vcModel = company;
    
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    NSAttributedString *aString = [[NSAttributedString alloc] initWithString:self.vcModel.companyName];
    UITextField *lblTitleView = [[UITextField alloc] init];
    [lblTitleView setAttributedText:aString];
    
    CGRect textRect = [lblTitleView.text boundingRectWithSize:self.view.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:lblTitleView.font} context:ctx];
    
    float width = 0;
    
    if( textRect.size.width < 260)
    {
        width = textRect.size.width + 15;
    }else{
        width = 260;
    }
    
    CGRect rect = self.lblTitle.frame;
    rect.size.width = width;
    rect.origin.y = 25;
    [self.lblTitle setFrame:rect];
    self.lblTitle.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), rect.origin.y);
    
    CGRect downArrowRect = self.downArrowImageView.frame;
    downArrowRect.origin.x = self.lblTitle.frame.origin.x - 25;
    downArrowRect.origin.y = self.lblTitle.frame.origin.y;
    
    self.downArrowImageView.frame = downArrowRect;
    self.lblTitle.text = [NSString stringWithFormat:@"%@",self.vcModel.companyName];
    
    users = [[NSMutableArray alloc] init];
    
    [self updateData];
    
    if ([users count]<=0) {
        [SVProgressHUD show];
        [self getUserList];
    }
}


- (void) setUpAlertView {
    _customAlert = [[RapporrAlertView alloc] init];
    [_customAlert setDelegate:self];
}

-(void)updateData
{
    headersArray = [Utils getTableViewSectionByDates];
    [self fetchMessagesFromDB];
    [self fetchUserFromDB];
    [self sortMessagesDictionary];
    [self sortMessagesDictionaryForSearchedItems];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0.0];
    [self.mainTblView reloadData];

}

- (void) fetchUserFromDB {
    
    NSMutableArray *tempUsers = [[CoreDataController sharedManager] fetchUserFromDB];
    users = [[NSMutableArray alloc] init];
    
    for(int i=0; i<tempUsers.count; i++) {
        NSManagedObject *conversationUserObj = [tempUsers objectAtIndex:i];
        ConversationUser *cUserModel = [[ConversationUser alloc] initWithManagedObject:conversationUserObj];
        [users addObject:cUserModel];
    }
}


- (void) fetchMessagesFromDB {
    
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    NSMutableArray *tempMessages = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    conversations = [[NSMutableArray alloc] init];
    
    
    for (NSManagedObject *messageObj in tempMessages) {
        MessageModel *mModel = [[MessageModel alloc] initWithManagedObject:messageObj];
        [conversations addObject:mModel];
    }
    
    
    float roundedup = ceil(tempMessages.count/20);
    totalPages = roundedup;
    
    
    NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"timeStamp"
                                                            ascending:NO
                                                             selector:@selector(caseInsensitiveCompare:)];
    
    conversations = [[conversations sortedArrayUsingDescriptors:@[sort]] mutableCopy];

}

-(void)refreshData{

    [SVProgressHUD show];
    [self getUserList];
}

- (void) getUserList {
    isSearching = NO;
    [self.searchBar performSelector:@selector(resignFirstResponder)
                         withObject:nil
                         afterDelay:0];
    
    [self.searchBar setText:@""];
    
    
    userTimeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:kfetchWithUserTimestamp];
    if(userTimeStamp == nil){
        userTimeStamp = @"all";
    }
    
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:0];
    NSDictionary *paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:[RapporrManager sharedManager].vcModel.hostID,@"hostId",[RapporrManager sharedManager].vcModel.userId,@"userID",nil];
    
    NSString *uri = [NSString stringWithFormat:@"%@%@/users?last=%@",URI_GET_USERS,[RapporrManager sharedManager].vcModel.orgId,@"all"];
    
    [NetworkManager fetchConversationAPI:uri parameters:paramsToBeSent success:^(id data, NSString *timestamp) {
        
        [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:kfetchWithUserTimestamp];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSError* error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
        
        for(int i=0; i<jsonArray.count; i++) {
            ConversationUser *conversationUserModel = [[ConversationUser alloc] initWithDictionary:(NSDictionary*)[jsonArray objectAtIndex:i]];
            [users addObject:conversationUserModel];
            [self saveConversationUser:conversationUserModel];
        }
        
        [self getConversationList];
        
        
    }failure:^(NSError *error) {
        NSLog(@"Error");
        [SVProgressHUD dismiss];
        
    }];
}

- (void) saveConversationUser : (ConversationUser *) ConversationUser {
    
    BOOL isNewConv = [[CoreDataController sharedManager] checkIfConversationUserExist:ConversationUser];
    
    if (!isNewConv){
        [[CoreDataController sharedManager] saveConversationUser:ConversationUser];
    }else{
    }
}

- (void) getConversationList {
    
    NSString *timeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:kfetchWithConversationTimestamp];
    if(timeStamp == nil){
        timeStamp = @"all";
    }
    
    NSDictionary *paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:[RapporrManager sharedManager].vcModel.hostID,@"hostId",[RapporrManager sharedManager].vcModel.userId,@"userID",nil];
    
    NSString *uri = [NSString stringWithFormat:@"%@%@?last=%@",URI_GET_CONVERSATION,[RapporrManager sharedManager].vcModel.userId,timeStamp];
    [NetworkManager fetchConversationAPI:uri parameters:paramsToBeSent success:^(id data ,NSString *timestamp) {
        
        NSError* error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
        
        [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:kfetchWithConversationTimestamp];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if(jsonArray.count > 0) {
            
//            NSLog(@"%@",jsonArray);
            
            for(int i=0; i<jsonArray.count; i++) {
                MessageModel *mModel = [[MessageModel alloc] initWithDictionary:(NSDictionary*)[jsonArray objectAtIndex:i]];
                [self saveMessageModel:mModel];
            }
        }
        
        [self getMessageList];
        
    }failure:^(NSError *error) {
        NSLog(@"Error");
        [SVProgressHUD dismiss];

    }];
}


- (void) getMessageList {
    
    NSString *TimeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:kfetchWithAllMessagesTimestamp];
    if(TimeStamp == nil){
        TimeStamp = @"all";
    }
    
    NSDictionary *paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:[RapporrManager sharedManager].vcModel.hostID,@"hostId",[RapporrManager sharedManager].vcModel.userId,@"userID",nil];
    
    NSString *orgId  = [RapporrManager sharedManager].vcModel.orgId;
    NSString *userId = [RapporrManager sharedManager].vcModel.userId;
    
    NSString *uri = [NSString stringWithFormat:URI_GET_ALL_MESSAGES,orgId,userId,TimeStamp];
    [NetworkManager fetchAllMessages:uri parameters:paramsToBeSent success:^(id data ,NSString *timestamp) {
        
        
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray *)data;
            
            if ([array count]) {
                
//                NSLog(@"%@",array);
                
                NSMutableArray *messages = [RPConverstionMessage parseConversationMessages:array];
                for (MessageModel *conv in conversations) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.conversationId == %@", conv.conversationId];
                    NSArray *filteredList = [messages filteredArrayUsingPredicate:predicate];
                    conv.messages = [filteredList mutableCopy];
                }
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:kfetchWithAllMessagesTimestamp];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [SVProgressHUD dismiss];
        [self updateData];

    }failure:^(NSError *error) {
        NSLog(@"Error");
        [SVProgressHUD dismiss];
    }];
}



- (void) saveMessageModel : (MessageModel*) mModel {
    
    BOOL isNewConv = [self checkIfConversationExist:mModel];
    
    if (!isNewConv){
        [[CoreDataController sharedManager] saveMessageModel:mModel];
    }else{
        [[CoreDataController sharedManager] UpdateMessageModelWithoutUnReadCount:mModel];
    }
}

-(BOOL)checkIfConversationExist:(MessageModel *)model{
    
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"conversationId = %@", model.conversationId]];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    if (count == NSNotFound){}
    else if (count == 0){
        return NO;
    }else{
        return YES;
    }
    return NO;
}


- (void) adjustTabBarImageOffset {
    
    UITabBar *tabBar = self.navigationController.tabBarController.tabBar;
    [[tabBar.items objectAtIndex:0] setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [[tabBar.items objectAtIndex:1] setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [[tabBar.items objectAtIndex:2] setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [[tabBar.items objectAtIndex:3] setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    
    self.title = nil;
}

- (void)addFloatingButton {
    
    CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60 - 20, [UIScreen mainScreen].bounds.size.height - 60 - 80, 60, 60);
    
    addMenuButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"edit"] andPressedImage:[UIImage imageNamed:@"edit"] withScrollview:_mainTblView];
    
    addMenuButton.layer.shadowColor = [UIColor blackColor].CGColor;
    addMenuButton.layer.shadowOffset = CGSizeMake(1, 1);
    addMenuButton.layer.shadowOpacity = 0.3;
    addMenuButton.layer.shadowRadius = 2.0;
    addMenuButton.hideWhileScrolling = NO;
    addMenuButton.delegate = self;
    
    [self.view addSubview:addMenuButton];
}

- (void)addScrollToTop {
    
    self.btnScrollToTop = [[MEVFloatingButton alloc] init];
    
    
    self.btnScrollToTop.animationType = MEVFloatingButtonAnimationFromBottom;
    self.btnScrollToTop.displayMode = MEVFloatingButtonDisplayModeWhenScrolling;
    self.btnScrollToTop.position = MEVFloatingButtonPositionTopCenter;
    [self.btnScrollToTop setImage:SET_IMAGE(@"btnMoveTop")];
    self.btnScrollToTop.backgroundColor = [UIColor colorFromHexCode:@"#FF5721"];
    self.btnScrollToTop.outlineWidth = 0.0f;
    self.btnScrollToTop.imagePadding = 0.0f;
    self.btnScrollToTop.horizontalOffset = 0.0f;
    self.btnScrollToTop.verticalOffset = 0.0f;
    self.btnScrollToTop.rounded = YES;
    
    self.btnScrollToTop.title = NSLocalizedString(@"TOP", nil);
    self.btnScrollToTop.shadowColor = [UIColor blackColor];
    self.btnScrollToTop.shadowOffset = CGSizeMake(1, 1);
    self.btnScrollToTop.shadowOpacity = 0.3;
    self.btnScrollToTop.shadowRadius = 2.0;
    
    self.btnScrollToTop.hideWhenScrollToTop = YES;
    
    [self.mainTblView setFloatingButtonView:self.btnScrollToTop];
    [self.mainTblView setFloatingButtonDelegate:self];
    
}

#pragma mark - MEScrollToTopDelegate Methods

- (void)floatingButton:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    
    NSLog(@"didTapButton");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainTblView setContentOffset:CGPointMake(0, -self.mainTblView.contentInset.top) animated:YES];
    });
}

- (void)floatingButtonWillAppear:(UIScrollView *)scrollView {
    NSLog(@"floatingButtonWillAppear");
}

- (void)floatingButtonDidAppear:(UIScrollView *)scrollView {
    NSLog(@"floatingButtonDidAppear");
}

- (void)floatingButtonWillDisappear:(UIScrollView *)scrollView {
    NSLog(@"floatingButtonWillDisappear");
}

- (void)floatingButtonDidDisappear:(UIScrollView *)scrollView; {
    NSLog(@"floatingButtonDidDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isSearching) {
        return messagesDictArrayforSearch.count;
        
    } else {
        
        return messagesDictArray.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (isSearching) {
        NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArrayforSearch objectAtIndex:section];
        return [tempDict objectForKey:@"day"];
        
    } else {
        
        NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:section];
        return [tempDict objectForKey:@"day"];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, tableView.frame.size.width, 19)];
    if (IS_IPHONE_4) {
        [label setFont:ROBOTO_REGULAR(13)];
    }
    [label setFont:ROBOTO_LIGHT(15)];
    NSString *string = @"";
    
    if (isSearching) {
        NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArrayforSearch objectAtIndex:section];
        string = [tempDict objectForKey:@"day"];
        
    } else {
        
        NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:section];
        string = [tempDict objectForKey:@"day"];
    }
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:App_GrayColor];
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (isSearching) {
        NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArrayforSearch objectAtIndex:section];
        NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
        return arrayOfSection.count;
        
    } else {
        
        NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:section];
        NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
        return arrayOfSection.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageCell * cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"MessageCell" owner:self options:nil];
        cell=[nib objectAtIndex:0];
    }
    
    cell.imgView.layer.cornerRadius = 5;
    cell.imgView.clipsToBounds = YES;
    MessageModel *mModel;
    
    cell.layoutMargins = UIEdgeInsetsZero;

    if (isSearching) {
        
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        tableView.frame = _mainTblView.frame;
        isSearching = true;
        NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArrayforSearch objectAtIndex:indexPath.section];
        
        NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
        mModel = (MessageModel*)[arrayOfSection objectAtIndex:indexPath.row];
        
    } else {
        
        isSearching = false;
        NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:indexPath.section];
        NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
        mModel = (MessageModel*)[arrayOfSection objectAtIndex:indexPath.row];
    }
    
    RPConverstionMessage *lastMessage = (RPConverstionMessage *)[mModel.messages lastObject];

    NSLog(@"%@",[RapporrManager sharedManager].vcModel.userId);
    NSLog(@"%@",lastMessage.user.fullId);

    if ([lastMessage.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement] && ![lastMessage.user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId] && !lastMessage.isRead) {
        cell.rightBar.backgroundColor = App_DarkYellowColor;
        cell.containerView.backgroundColor = App_LightYellowColor;
    }else if ([mModel.lastMsg isEqualToString:@"made a new announcement."]){
        cell.rightBar.backgroundColor = App_DarkYellowColor;
        cell.containerView.backgroundColor = App_LightYellowColor;
    }
    
    ConversationUser *cAdminUser = [self getConversationAdmin:mModel];
    if ([lastMessage.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
        [cell.imgView setImage:SET_IMAGE(@"announcement_org")];
    }else{
    if(cAdminUser.avatarUrl.length > 1) {
        NSURL *imageUrl = [NSURL URLWithString:cAdminUser.avatarUrl];
        
        UIImage *placeholder = [UIImage imageNamed:@"placeholder_user"];
        if([Utils hasCachedImage]){
            placeholder = [Utils loadImage];
        }
        
        [cell.imgView setImageWithURL:imageUrl placeholderImage:placeholder options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    }
    else {
        [cell.imgView setImageWithString:cAdminUser.name color:[UIColor colorFromHexCode:@"#FD9527"] circular:NO];
    }
    }
    cell.tag = indexPath.section;
    cell.accessibilityHint = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    cell.delegate = self;
    if([ mModel.unReadMsgsCount intValue] > 0) {
        cell.lblNumberUsers.hidden = false;
        cell.lblNumberUsers.text = mModel.unReadMsgsCount;
    }
    else {
        cell.lblNumberUsers.hidden = true;
    }
    
    cell.titleLbl.text = [mModel.about uppercaseString];
    cell.subTitle1Lbl.text = [self getSubTitleLbl:mModel.members];
    cell.subTitle2Lbl.text = [self messageWithSender:mModel];
    cell.dateLbl.text = [self dateTimeForConversation:mModel];
    self.mainTblView.separatorColor = [UIColor clearColor];
    
    if (mModel.isPinned) {
        [cell.imgViewPinConv setImage:SET_IMAGE(@"pinSelectedIcon")];
    }else{
        
    }
    [cell setRightUtilityButtons:[self leftButtonsWithMessageModel:mModel] WithButtonWidth:70.0f requirePaddingForSectionIndexer:NO];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 98;    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
//    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
//    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
//    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
//        if(currentPage < totalPages) {
//            currentPage++;
//            [self updateData];
//        }
//    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageModel *mModel;
    
    if (isSearching) {
        tableView.frame = _mainTblView.frame;
        isSearching = true;
        NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArrayforSearch objectAtIndex:indexPath.section];
        
        NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
        mModel = (MessageModel*)[arrayOfSection objectAtIndex:indexPath.row];
        
    } else {
        
        NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:indexPath.section];
        NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
        mModel = (MessageModel*)[arrayOfSection objectAtIndex:indexPath.row];
    }
    
    NSMutableArray *messagesInConversation = [self getMessagesForConversationFromDB:mModel];
    mModel.messages = messagesInConversation;
    
    ConversationDetailVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationDetailVC"];
    vc.conversation = mModel;
    vc.delegate = (id)self;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    [self.view endEditing:YES];
    
}

-(NSMutableArray*) getMessagesForConversationFromDB : (MessageModel*) mModel  {
    NSMutableArray *arrayOfMessages = [[CoreDataController sharedManager] fetchConversationMessagesFromDBForConversation:mModel WithCompletion:^(RPConverstionMessage * _Nullable unSentMessage) {
        
    }];
    
    return arrayOfMessages;
}

- (NSString*) getTitleLbl : (NSMutableArray*)usersInMessage {
    NSString *titlelbl = @"";
    if(usersInMessage.count>0){
        ConversationUser *cUser = [usersInMessage objectAtIndex:0];
        titlelbl = cUser.fName;
    }
    
    for(int i=1; i<usersInMessage.count; i++){
        ConversationUser *cUser = [usersInMessage objectAtIndex:i];
        titlelbl = [NSString stringWithFormat:@"%@ and %@",titlelbl,cUser.fName];
    }
    return titlelbl;
}

- (NSString*) getSubTitleLbl : (NSMutableArray*)usersInMessage {
    NSString *titlelbl = @"";
    if(usersInMessage.count>0){
        ConversationUser *cUser = [usersInMessage objectAtIndex:0];
        titlelbl = cUser.fName;
    }
    
    int count = 0;
    for (ConversationUser *cUser in usersInMessage) {
        if (count >=1) {
            if([usersInMessage count] == 2){
                titlelbl = [NSString stringWithFormat:@"%@ and %@",titlelbl,cUser.fName];
            }else if(count < [usersInMessage count]-1)
            {
                titlelbl = [NSString stringWithFormat:@"%@, %@",titlelbl,cUser.fName];
            }
            else{
                titlelbl = [NSString stringWithFormat:@"%@ and %@",titlelbl,cUser.fName];
            }
        }
        count++;
    }
    
    
    NSLog(@"%@",titlelbl);
    
    return titlelbl;
}

- (NSString*)messageWithSender:(MessageModel*)message {
    NSString *titlelbl = [NSString stringWithFormat:@"%@",message.lastMsg];
    NSLog(@"%@",titlelbl);

    return titlelbl;
}

- (NSString *)dateTimeForConversation:(MessageModel*)message
{
    NSString *dateString = message.lastMsgRecieved;
    NSDateFormatter *formatter = [NSDateFormatter defaultDateManager];
    
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *dateFromMessage = [formatter dateFromString:dateString];
    NSTimeZone *localTimeZone = [NSTimeZone systemTimeZone];
    [formatter setTimeZone:localTimeZone];
    NSString *timeStamp = [formatter stringFromDate:dateFromMessage];
    NSDate *dateFromString = [formatter dateFromString:timeStamp];

    
    NSString *dateTimeString = @"";
    
    NSDate *currentDate = [NSDate getDateInCurrentSystemTimeZone];
    NSInteger isSameDay = [NSDate daysBetweenDate:currentDate andDate:dateFromString];
    if(isSameDay >= -6) {
        [formatter setDateFormat:@"hh:mma"];
        dateTimeString = [formatter stringFromDate:dateFromString];
    }else{
        [formatter setDateFormat:@"MMM d"];
        dateTimeString = [formatter stringFromDate:dateFromString];
    }
    return dateTimeString;
}

- (ConversationUser*) getConversationAdmin:(MessageModel*)mModel{
    for (ConversationUser* user in mModel.members) {
        if([user.fullId isEqualToString:mModel.startingUser]){
            return user;
        }
    }
    return nil;
}

- (NSArray *)leftButtonsWithMessageModel:(MessageModel*)msgModel
{
    
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    if(msgModel.isPinned){
        [leftUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.113 green:0.443f blue:0.639f alpha:1.0] icon:
         [UIImage imageNamed:@"unpin"] andTitle:@"Unpin"];
        
    }else{
        [leftUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.113 green:0.443f blue:0.639f alpha:1.0] icon:
         [UIImage imageNamed:@"pin"] andTitle:@"Pin"];
    }
    
    
    [leftUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:0.113f green:0.443f blue:0.639f alpha:1.0] icon:[UIImage imageNamed:@"archive"] andTitle:@"Archive"];
    
    return leftUtilityButtons;
}




- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    searchResults = [[NSMutableArray alloc]init];
    
    //    Title Search
    NSArray *messagesArrayWithTitle = [conversations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.about contains[cd] %@ OR ANY SELF.members.name CONTAINS[cd] %@", searchText,searchText]];
    
    [searchResults removeAllObjects];
    
    if ([messagesArrayWithTitle count]) {
        searchResults = [NSMutableArray arrayWithArray:messagesArrayWithTitle];
    }else{
    }
    headersArray = [Utils getTableViewSectionByDates];
    [self sortMessagesDictionaryForSearchedItems];
    
}


-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText isEqualToString:@""] || searchText==nil) {
        isSearching = NO;

        [self.mainTblView reloadData];
        
    }else{
        isSearching = YES;
        
        [searchResults removeAllObjects];
        
        NSArray *messagesArrayWithTitle = [conversations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.about contains[cd] %@ OR ANY SELF.members.name CONTAINS[cd] %@", searchText,searchText]];
        searchResults = [NSMutableArray arrayWithArray:messagesArrayWithTitle];
        
        headersArray = [Utils getTableViewSectionByDates];
        [self sortMessagesDictionaryForSearchedItems];
        [self.mainTblView reloadData];
        
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void) didSelectMenuOptionAtIndex:(NSInteger)row
{
    NSLog(@"Floating action tapped index %tu",row);
}

-(void) didMenuButtonTapped:(id)button;
{
    CreateConversationVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateConversationVC"];
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) didScrollToTopButtonTapped;
{
    [_mainTblView setScrollsToTop:YES];
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
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    MessageModel *mModel;
    if(isSearching) {
        
        NSMutableDictionary *tempDict = nil;
        
        if ([messagesDictArrayforSearch count]) {
            tempDict = (NSMutableDictionary*)[messagesDictArrayforSearch objectAtIndex:cell.tag];
        }
        NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
        int rowIndex = [cell.accessibilityHint intValue];
        if ([arrayOfSection count]) {
            mModel = (MessageModel*)[arrayOfSection objectAtIndex:rowIndex];
        }
    }
    else {
        NSMutableDictionary *tempDict = (NSMutableDictionary*)[messagesDictArray objectAtIndex:cell.tag];
        NSMutableArray *arrayOfSection = [tempDict objectForKey:@"array"];
        int rowIndex = [cell.accessibilityHint intValue];
        if ([arrayOfSection count]) {
            mModel = (MessageModel*)[arrayOfSection objectAtIndex:rowIndex];
        }
    }
    
    switch (index) {
        case 0:
        {
            if(mModel.isPinned) {
                mModel.isPinned = NO;
                [[CoreDataController sharedManager] UpdateMessageModel:mModel];
                [self updateData];
                
                [self.navigationController.view makeToast:@"Selected conversations has been successfully unpinned"];
                
            }
            else {
                mModel.isPinned = YES;
                alertViewTag = 0;
                
                [[CoreDataController sharedManager] UpdateMessageModel:mModel];
                [self updateData];
                
                [self.navigationController.view makeToast:@"The conversation was successfully pinned"];
                
            }            
            
            break;
        }
        case 1:
        {
            alertViewTag = 1;
            selectedMessageModel = mModel;
            
            _customAlert.isButtonSwitch = YES;
            [_customAlert showCustomAlertInView:self.view withMessage:@"Archive Conversation" andDescription:@"Are you sure you want to archive this message? Please note that the conversation will be un-archived if another user sends a message in this conversation" setOkTitle:@"NO" setCancelTitle:@"YES"];
            
            
            break;
        }
        default:
            break;
    }
    
    
    [cell hideUtilityButtonsAnimated:YES];
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

- (void) sortMessagesDictionary {
    messagesDictArray = [[NSMutableArray alloc] init];
    [self getPinnedMsgs];
    
    for(NSMutableDictionary *tempDict in headersArray) {
        NSMutableArray *messagesArrayForSpan = [self getMesagesForSpan:tempDict andArray:conversations];
        if(messagesArrayForSpan.count>0){
            NSMutableDictionary *dictForDate = [[NSMutableDictionary alloc] init];
            [dictForDate setObject:messagesArrayForSpan forKey:@"array"];
            [dictForDate setObject:[tempDict objectForKey:@"day"] forKey:@"day"];
            [messagesDictArray addObject:dictForDate];
        }
    }
}

- (void) sortMessagesDictionaryForSearchedItems {
    messagesDictArrayforSearch = [[NSMutableArray alloc] init];
    [self getPinnedMsgsForSearch];
    
    for(NSMutableDictionary *tempDict in headersArray) {
        NSMutableArray *messagesArrayForSpan = [self getMesagesForSpan:tempDict andArray:searchResults];
        if(messagesArrayForSpan.count>0){
            NSMutableDictionary *dictForDate = [[NSMutableDictionary alloc] init];
            [dictForDate setObject:messagesArrayForSpan forKey:@"array"];
            [dictForDate setObject:[tempDict objectForKey:@"day"] forKey:@"day"];
            [messagesDictArrayforSearch addObject:dictForDate];
        }
    }
}

- (BOOL) checkIfConversationHasAnnouncement : (MessageModel*)mModel  {
    
    mModel.messages = [[CoreDataController sharedManager] fetchConversationMessagesFromDBForConversation:mModel WithCompletion:^(RPConverstionMessage * _Nullable unSentMessage) {
        
    }];
    
    for(int i=0; i<mModel.messages.count; i++)
    {
        RPConverstionMessage *mMessage = [mModel.messages objectAtIndex:i];
        if([mMessage.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
            return true;
        }
    }
    
    
    
    return false;
}

- (void) getPinnedMsgs {
    
    NSMutableArray *conversationArray = [[NSMutableArray alloc] init];
    if ([conversations count]) {
        
        for(MessageModel *mModel in conversations){
            if(mModel.isPinned && !mModel.isArchieved) {
                [conversationArray addObject:mModel];
            }
//            else if ([self checkIfConversationHasAnnouncement:mModel]) {
//                [conversationArray addObject:mModel];
//            }
        }
    }
    
    NSMutableDictionary *dictForDate = [[NSMutableDictionary alloc] init];
    [dictForDate setObject:conversationArray forKey:@"array"];
    [dictForDate setObject:@"Important and Pinned" forKey:@"day"];
    
    if(conversationArray.count>0) {
        [messagesDictArray addObject:dictForDate];
    }
}
- (void) getPinnedMsgsForSearch {
    NSMutableArray *messagesArray = [[NSMutableArray alloc] init];
    if ([searchResults count]) {
        
        for(MessageModel *mModel in searchResults){
            if(mModel.isPinned && !mModel.isArchieved) {
                [messagesArray addObject:mModel];
            }
//            else if ([self checkIfConversationHasAnnouncement:mModel]) {
//                [messagesArray addObject:mModel];
//            }
        }
        
    }
    
    NSMutableDictionary *dictForDate = [[NSMutableDictionary alloc] init];
    
    [dictForDate setObject:messagesArray forKey:@"array"];
    [dictForDate setObject:@"Important and Pinned" forKey:@"day"];
    
    if(messagesArray.count>0) {
        [messagesDictArrayforSearch addObject:dictForDate];
    }
}

- (NSMutableArray*) getMesagesForSpan : (NSMutableDictionary*)tempDict andArray :(NSMutableArray*)scopeArray {
    
    NSMutableArray *messagesArray = [[NSMutableArray alloc] init];
    
    NSString *day = [tempDict objectForKey:@"day"];
    NSDate *date = [tempDict objectForKey:@"date"];
    
    
    
    NSDateFormatter *formatter = [NSDateFormatter defaultDateManager];
    NSLocale *enUSPosixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    
    if ([day isEqualToString:@"Today"] || [day isEqualToString:@"Yesterday"] || [day isEqualToString:@"Monday"] || [day isEqualToString:@"Tuesday"] || [day isEqualToString:@"Wednesday"] || [day isEqualToString:@"Thursday"] || [day isEqualToString:@"Friday"] || [day isEqualToString:@"Saturday"] || [day isEqualToString:@"Sunday"]){
        
        if ([scopeArray count]) {
            
            for(MessageModel *mModel in scopeArray){
                if(!mModel.isPinned && !mModel.isArchieved) {
                    NSString *dateString = mModel.timeStamp;
                    [formatter setLocale:enUSPosixLocale];
                    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
                    NSDate *dateForMessage = [formatter dateFromString:dateString];
                    
                    BOOL isSameDay = [[NSCalendar currentCalendar] isDate:dateForMessage inSameDayAsDate:date];
                    if(isSameDay) {
                        [messagesArray addObject:mModel];
                    }
                }
            }
        }
    }
    else if([day isEqualToString:@"Last Week"]) {
        
        NSDate *date1 = [[Utils getStartDateOfWeek] dateByAddingTimeInterval: -86400.0] ;
        NSDate *date2 = [Utils getStartOfLastWeek];
        
        if ([scopeArray count]) {
            for(MessageModel *mModel in scopeArray){
                if(!mModel.isPinned && !mModel.isArchieved) {
                    NSString *dateString = mModel.timeStamp;
                    
                    [formatter setLocale:enUSPosixLocale];
                    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
                    NSDate *dateForMessage = [formatter dateFromString:dateString];
                    
                    BOOL isSameDay = [self isDate:dateForMessage inRangeFirstDate:date2 lastDate:date1];
                    if(isSameDay) {
                        [messagesArray addObject:mModel];
                    }
                }
            }
        }
    }
    else if([day isEqualToString:@"Older Conversations"]) {
        // date is between this week and last week
        NSDate *date1 = [[Utils getStartOfLastWeek] dateByAddingTimeInterval: -86400.0] ;
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDate *older = [cal dateByAddingUnit:NSCalendarUnitDay
                                        value:-1
                                       toDate:date1
                                      options:0];
        
        if ([scopeArray count]) {
            
            for(MessageModel *mModel in scopeArray){
                if(!mModel.isPinned && !mModel.isArchieved) {
                    NSString *dateString = mModel.timeStamp;
                    
                    [formatter setLocale:enUSPosixLocale];
                    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
                    NSDate *dateForMessage = [formatter dateFromString:dateString];
                    
                    NSInteger isSameDate = [NSDate daysBetweenDate:older andDate:dateForMessage];
                    if(isSameDate<=0) {
                        [messagesArray addObject:mModel];
                    }
                }
            }
        }
    }
    
    return messagesArray;
}



- (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    return [date compare:firstDate] == NSOrderedDescending &&
    [date compare:lastDate]  == NSOrderedAscending;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewConversation" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewMessage" object:nil];
}

-(void)RapporrAlertOK:(id)sender{
    
    if(alertViewTag == 1) {
        if(selectedMessageModel.isArchieved) {
            selectedMessageModel.isArchieved = false;
        }
        else {
            selectedMessageModel.isArchieved = true;
        }
        [[CoreDataController sharedManager] UpdateMessageModel:selectedMessageModel];
        
        [self updateData];
    }
    
    [_customAlert removeCustomAlertFromViewInstantly];
}

-(void)RapporrAlertCancel;{
    [_customAlert removeCustomAlertFromViewInstantly];
}

-(void)RapporrAlertCancel:(id)sender;{
    
    [_customAlert removeCustomAlertFromViewInstantly];
}


- (IBAction)btnChangeCompany:(id)sender {
    
    isSearching = NO;
    
    [self.searchBar performSelector:@selector(resignFirstResponder)
                         withObject:nil
                         afterDelay:0];
    
    [self.searchBar setText:@""];
    [self.mainTblView reloadData];
    
    self.tabBarController.tabBar.hidden = YES;
    [self.actionBgView setHidden:NO];
    [self.view bringSubviewToFront:self.actionBgView];
    [Utils moveViewPosition:self.view.bounds.size.height - self.actionSheetButtonView.bounds.size.height + 50 onView:self.actionSheetButtonView completion:^(BOOL finished) {
        
    }];
    
}


- (IBAction)actionSheetButtons:(UIButton *)sender {
    
    
    [Utils moveViewPosition:1000 onView:self.actionSheetButtonView completion:^(BOOL finished) {
        [self.actionBgView setHidden:YES];
        self.tabBarController.tabBar.hidden = NO;
    }];
    
    if (sender.tag == 350) {
        
        JoinCompanyVC *joinCompanyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JoinCompanyVC"];
        joinCompanyVC.isPushedFromHome = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationController.tabBarController.tabBar.hidden = YES;
            [self.navigationController pushViewController:joinCompanyVC animated:YES];
        });
        
    }else if (sender.tag == 351){
        WelcomeRapporrVC *newRapporrVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeRapporrVC"];

        dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.tabBarController.tabBar.hidden = YES;
            [self.navigationController pushViewController:newRapporrVC  animated:YES];
        });
    }
}


- (IBAction)btnHideActionSheet:(id)sender {
    [Utils moveViewPosition:1000 onView:self.actionSheetButtonView completion:^(BOOL finished) {
        [self.actionBgView setHidden:YES];
        self.tabBarController.tabBar.hidden = NO;
    }];
}


-(void)keyboardWillShow:(NSNotification *)notification {
    
//    overlay.hidden = false;
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float height = MIN(keyboardSize.height,keyboardSize.width);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGRect tableViewRect = self.mainTblView.frame;
    tableViewRect.size.height = self.view.frame.size.height - height - 70;
    self.mainTblView.frame = tableViewRect;
    
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)notification {
//    overlay.hidden = true;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGRect tableViewRect = self.mainTblView.frame;
    tableViewRect.size.height = self.view.frame.size.height - 115;
    self.mainTblView.frame = tableViewRect;
    [UIView commitAnimations];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [RKDropdownAlert dismissAllAlert];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [self.view endEditing:YES];

}

-(void) receiveTestNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"NewConversation"])
    {
        MessageModel * conversation = notification.userInfo[@"conversation"];
        if (conversation) {
            [conversations addObject:conversation];
            [self getUserList];
        }
    }else if ([notification.name isEqualToString:@"NewMessage"])
    {
        [self getConversationList];
    }
}


#pragma mark - Network Status
-(void)didNetworkConnected:(AFNetworkReachabilityStatus)status;{
    
    self.reachabilityStatus = status;
    [RKDropdownAlert dismissAllAlert];
    [RKDropdownAlert title:@"" message:@"Connected" backgroundColor:[UIColor colorFromHexCode:@"#00B36D"] textColor:[UIColor whiteColor] time:5 delegate:nil autoHide:YES yPosition:69];
}

-(void)didNetworkDisconnected:(AFNetworkReachabilityStatus)status;{
    
    self.reachabilityStatus = status;
    [RKDropdownAlert dismissAllAlert];
    [RKDropdownAlert title:@"" message:NSLocalizedString(@"No Internet Connection",@"") backgroundColor:[UIColor colorFromHexCode:@"#FF5721"] textColor:[UIColor whiteColor] time:5 delegate:nil autoHide:NO yPosition:69];
    
}



@end
