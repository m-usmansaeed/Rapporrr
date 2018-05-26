//
//  UserProfileViewController.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 24/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "UserProfileViewController.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController
{
    NSArray *cells;
    BOOL isAdminMenuActive;
    BOOL isAdminOptionActive;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    self.userValues = [[NSMutableDictionary alloc]init];
    
    isAdminMenuActive = NO;
    isAdminOptionActive = NO;
    _isDoneEditing = NO;
    [self setUpAlertView];
    
    cells = [[NSArray alloc]initWithObjects:@"name",@"title",@"role",@"mobileNumber",@"adminOpt",@"adminOpt1",@"adminOpt2",@"adminOpt3",@"buttons", nil];
    
    UITapGestureRecognizer *hideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    hideKeyboard.delegate = (id)self;
    [self.view addGestureRecognizer:hideKeyboard];
    
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

    nameStr = self.user.name;
}


- (void)hideKeyboard:(UITapGestureRecognizer*)sender {
    
    [self.view endEditing:YES];
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.tableView] ) {
        return NO;
    }
    
    return YES;
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];

    if ([[RapporrManager sharedManager].vcModel.uType isEqualToString:kUSER_TYPE_ADMIN]) {
        self.btnEdit.hidden = NO;
    }else{
        self.btnEdit.hidden = YES;
    }

    if(self.user.avatarUrl.length > 1) {
        NSURL *imageUrl = [NSURL URLWithString:self.user.avatarUrl];
        [self.imgView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    }
    else {
        [self.imgView setImageWithString:self.user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
    }
    
    [self updateData];
}


-(void) updateData
{
    NSArray *namesArray = [self.user.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    if ([namesArray count]) {
        self.user.fName = [NSString validStringForObject:[namesArray objectAtIndex:0]];
        
        if ([namesArray count]> 1) {
            self.user.lName = [NSString validStringForObject:[namesArray objectAtIndex:0]];
        }
    }
    
    _lblTitle.text = [NSString stringWithFormat:@"%@",_user.name];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)btnSendMessage:(id)sender {
    
    [self checkIfUserExistInConversations:self.user];
}


- (void) fetchMessagesFromDB {
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    NSMutableArray *tempMessages = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    self.conversations = [[NSMutableArray alloc] init];
    
    for (NSManagedObject *messageObj in tempMessages) {
        MessageModel *mModel = [[MessageModel alloc] initWithManagedObject:messageObj];
        [self.conversations addObject:mModel];
    }
}


- (void) checkIfUserExistInConversations:(ConversationUser *)user {
    
    ConversationDetailVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationDetailVC"];
    vc.isSegueUserProfile = YES;
    MessageModel *conversation = [[MessageModel alloc] init];

    [self fetchMessagesFromDB];
    
    ConversationUser *selfUser = [[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"SELF.members.fullId CONTAINS[cd] %@ AND SELF.members.fullId CONTAINS[cd] %@ AND SELF.members.@count == 2", user.fullId, selfUser.fullId];
    
    NSArray *arrFiltered = [self.conversations filteredArrayUsingPredicate:predicate];
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
        
    }
    
    conversation.about = [NSString stringWithFormat:@"%@ and %@",selfUser.fName,user.fName];
    
    vc.conversation = conversation;
    vc.hidesBottomBarWhenPushed = YES;
    vc.isDirectMessage = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (IBAction)btnMakeCall:(id)sender {
    
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:self.user.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)btnEditProfile:(id)sender {
    
    isAdminMenuActive = !isAdminMenuActive;
    
    if (isAdminMenuActive) {
        _isDoneEditing = NO;
        [self.btnEdit setTitle:@"Save" forState:UIControlStateNormal];
                [self.tableView reloadData];

        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:
                                 [NSIndexPath indexPathForRow:0 inSection:0]];
        UITextField *textField = (UITextField *)[cell.contentView viewWithTag:200];
        [textField becomeFirstResponder];

        
        isAdminOptionActive = NO;
        
    }else{
        
        _isDoneEditing = YES;
        [self.btnEdit setTitle:@"Edit" forState:UIControlStateNormal];
        
        isAdminOptionActive = NO;
        //[self.tableView reloadData];
        
        nameStr = [self returnStringForTextFieldAtIndex:0];
        titleStr = [self returnStringForTextFieldAtIndex:1];
        roleStr = [self returnStringForTextFieldAtIndex:2];
        phoneNumStr = [self returnStringForTextFieldAtIndex:3];
        
        [self updateUser];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (!isAdminMenuActive) {
        return 5;
    }
    else{
        if(isAdminOptionActive){
            return 9;
        }
        else{
            return 6;
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;{
    
    NSString *CellIdentifier = @"";
    if (!isAdminMenuActive) {
        if (indexPath.row<=3) {
            CellIdentifier = [cells objectAtIndex:[indexPath row]];
        }else{
            CellIdentifier = @"buttons";
        }
    }else{
        if(isAdminOptionActive){
            CellIdentifier = [cells objectAtIndex:[indexPath row]];
        }
        else{
            if (indexPath.row <=3) {
                CellIdentifier = [cells objectAtIndex:[indexPath row]];
            }else if (indexPath.row == 4) {
                CellIdentifier = @"adminOpt";
            }
            else{
                CellIdentifier = @"buttons";
            }
        }
    }
    
    UserProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UserProfileCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

   
    cell.txtField = (UITextField *)[cell.contentView viewWithTag:200];
    cell.txtField.delegate = self;

    UILabel *label = (UILabel *)[cell viewWithTag:300];
    
    if([cell.reuseIdentifier isEqualToString:@"name"]){
        cell.txtField.text = [NSString validStringForObject:nameStr];
        cell.txtField.delegate = self;

    }
    else if([cell.reuseIdentifier isEqualToString:@"title"]){
        cell.txtField.text = [NSString validStringForObject:_user.jobTitle];

    }
    else if([cell.reuseIdentifier isEqualToString:@"role"]){
        
        if ([[NSString validStringForObject:_user.uType] isEqualToString:kUSER_TYPE_STD] || [[NSString validStringForObject:_user.uType] isEqualToString:kUSER_TYPE_STD_STRING]) {
            cell.txtField.text = kUSER_TYPE_STD_STRING;
            
        }else if ([[NSString validStringForObject:_user.uType] isEqualToString:kUSER_TYPE_ADMIN] || [[NSString validStringForObject:_user.uType] isEqualToString:kUSER_TYPE_ADMIN_STRING]) {
            cell.txtField.text = kUSER_TYPE_ADMIN_STRING;
        }else{
            cell.txtField.text = kUSER_TYPE_EXT;
        }        
    }
    else if([cell.reuseIdentifier isEqualToString:@"mobileNumber"]){
        cell.txtField.text = [NSString validStringForObject:_user.phone];
    }
    else if([cell.reuseIdentifier isEqualToString:@"adminOpt1"]){
        if (_user.isAdmin) {
            label.text = @"Demote to Standard User";
        }else{
            label.text = @"Promote to Administrator";
        }
    }
    else if([cell.reuseIdentifier isEqualToString:@"adminOpt2"]){
        if (_user.disabled) {
            label.text = @"Activate";
        }else{
            label.text = @"Deactivate";
        }
    }
    
    else if([cell.reuseIdentifier isEqualToString:@"adminOpt3"]){}
    
    if(![cell.reuseIdentifier isEqualToString:@"buttons"]){
        cell.userInteractionEnabled = isAdminMenuActive;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    if (indexPath.row == 4) {
        if (isAdminMenuActive) {
            isAdminOptionActive = !isAdminOptionActive;
        }
    }else if(indexPath.row == 5){
        [self promoteUser:_user];
    }else if(indexPath.row == 6){
        
        if ([self.user.phone containsString:@"3126042881"] || [self.user.phone containsString:@"3214220983"] || [self.user.phone containsString:@"6173863675"]) {
            
            [_customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Thanks!",nil) andDescription:NSLocalizedString(@"I really appreciate your efforts. Try not to deactivate developers working on Rapporr, Save developers save nature. 😊😜😊",nil)];
            
        }else{
            
            _customAlert.alertTag = 10000;
            _customAlert.isButtonSwitch = YES;
            [_customAlert showCustomAlertInView:self.view withMessage:NSLocalizedString(@"Deactivate User",nil) andDescription:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to deactivate %@?",nil),self.user.fName] setOkTitle:@"CANCEL" setCancelTitle:@"YES"];
        }
        
    }else if(indexPath.row == 7){
        [self resendInvite:_user];
    }
    
    nameStr = [self returnStringForTextFieldAtIndex:0];

    [self.tableView reloadData];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat hight = 0.0;
    
    if (!isAdminMenuActive) {
        if (indexPath.row<=3) {
            hight = 44;
        }else{
            hight = 88;
        }
    }else{
        if (indexPath.row <= 4) {
            hight = 44;
        }
        else{
            hight = 88;
        }
        if(isAdminOptionActive){
            if (indexPath.row < 8) {
                hight = 44;
            }
            else{
                hight = 88;
            }
        }else{
            if (indexPath.row <= 4) {
                hight = 44;
            }
            else{
                hight = 88;
            }
        }
    }
    return hight;
}

-(void)promoteUser:(ConversationUser *)user
{
    NSString *userType = @"";
    
    if ([[NSString validStringForObject:user.uType] isEqualToString:kUSER_TYPE_STD] || [[NSString validStringForObject:user.uType] isEqualToString:kUSER_TYPE_STD_STRING]) {
        userType = kUSER_TYPE_ADMIN;
    }else if ([[NSString validStringForObject:user.uType] isEqualToString:kUSER_TYPE_ADMIN]) {
        userType = kUSER_TYPE_STD;
    }
    
    NSDictionary *paramsToBeSent = @{
                                     @"user" : [NSString validStringForObject:user.fullId],
                                     @"utype": [NSString validStringForObject:userType],
                                     @"organisationId" : [NSString validStringForObject:[RapporrManager sharedManager].vcModel.orgId]
                                     };
    
    
    __weak __block typeof(self) weakself = self;
    
     if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
    
    [NetworkManager promoteUser:paramsToBeSent success:^(id data,NSString *timestamp) {
        
        
        if ([[NSString validStringForObject:user.uType] isEqualToString:kUSER_TYPE_STD] || [[NSString validStringForObject:user.uType] isEqualToString:kUSER_TYPE_STD_STRING]) {
            user.uType = kUSER_TYPE_ADMIN;
        }else if ([[NSString validStringForObject:user.uType] isEqualToString:kUSER_TYPE_ADMIN] || [[NSString validStringForObject:user.uType] isEqualToString:kUSER_TYPE_ADMIN_STRING]) {
            user.uType = kUSER_TYPE_STD;
        }
        
        if ([[RapporrManager sharedManager].vcModel.userId isEqualToString:user.fullId]) {
            [RapporrManager sharedManager].vcModel.uType = user.uType;
            [[CoreDataController sharedManager] saveVerifiedCompany:[RapporrManager sharedManager].vcModel];
        }
        
        user.isAdmin = !user.isAdmin;
        [[CoreDataController sharedManager] updateUser:user];
        
        _customAlert.alertTag = 10001;
        _customAlert.alertType = kAlertTypePopup;
        
        NSString *editState = @"";
        NSString *userType = @"";
        NSString *stringJoin = @"";
        
        if (user.isAdmin) {
            editState = @"promoted";
            userType = kUSER_TYPE_ADMIN_STRING;
            stringJoin = @"an";
        }else{
            editState = @"demoted";
            userType = [NSString stringWithFormat:@"%@ User",kUSER_TYPE_STD_STRING];
            stringJoin = @"a";
        }

        
        NSString *message = [NSString stringWithFormat:@"%@ has been successfully %@ to %@ %@.",user.fName,editState,stringJoin,userType];
        
        [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Change User Status",nil) andDescription:NSLocalizedString(message,nil)];
        
        
        [[weakself delegate] didUpdatedUserSuccess:user];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"%@",[error description]);
    }];
     }else{
         [appDelegate showUnavailablityAlert];
     }
}

-(void)deactivateUser:(ConversationUser *)user{
    
    NSDictionary *paramsToBeSent = @{
                                     @"user" : [NSString validStringForObject:user.fullId],
                                     @"organisationId" : [NSString validStringForObject:[RapporrManager sharedManager].vcModel.orgId]
                                     };
    
    
    __weak __block typeof(self) weakself = self;
    if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
    [NetworkManager deactivateUser:paramsToBeSent success:^(id data, NSString* timestamp) {
        user.disabled = YES;
        [[CoreDataController sharedManager] updateUser:user];
        [self.tableView reloadData];
        [[weakself delegate] didDeactivateUserSuccess:user];
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        NSLog(@"%@",[error description]);
    }];
    }else{
        [appDelegate showUnavailablityAlert];
    }
}

-(void)resendInvite:(ConversationUser *)user{
    
    NSDictionary *paramsToBeSent = @{
                                     @"user" : [NSString validStringForObject:user.fullId],
                                     @"organisationId" : [NSString validStringForObject:[RapporrManager sharedManager].vcModel.orgId]
                                     };
     if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
    [NetworkManager resendUser:paramsToBeSent success:^(id data, NSString *timestamp) {
        NSLog(@"%@",data);
        
        
        _customAlert.alertTag = 10002;
        _customAlert.alertType = kAlertTypePopup;
        NSString *message = [NSString stringWithFormat:@"We have successfully resent the invitation to %@",user.fName];
        [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Resend Invitation",nil) andDescription:NSLocalizedString(message,nil)];
        
    } failure:^(NSError *error) {
        NSLog(@"%@",[error description]);
    }];
     }else{
         [appDelegate showUnavailablityAlert];
     }
}

- (void) setUpAlertView {
    _customAlert = [[RapporrAlertView alloc] init];
    [_customAlert setDelegate:(id)self];
}

-(void)RapporrAlertOK:(id)sender{
    
    
    if (self.customAlert.alertTag == 10000) {
        [self deactivateUser:_user];
    }
    
    [_customAlert removeCustomAlertFromViewInstantly];
}

-(void)RapporrAlertCancel{
    [_customAlert removeCustomAlertFromViewInstantly];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField;{
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;{
    textField.delegate = self;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;{
    
    textField.delegate = self;
}


- (NSString *)returnStringForTextFieldAtIndex:(int) index {
    
    UITableViewCell *theCell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    UITextField *cellTextField = [theCell viewWithTag:200];
    return cellTextField.text;
}


-(void)updateUser{
    
    if (![nameStr isEqualToString:self.user.name] || ![titleStr isEqualToString:self.user.jobTitle]) {
        
        self.user.name = nameStr;
        self.user.fName = @"";
        self.user.lName = @"";
        self.user.jobTitle = titleStr;

        NSArray *namesArray = [self.user.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        
        if ([namesArray count]) {
            if ([namesArray count]) {
                self.user.fName = [namesArray objectAtIndex:0];
            }
            
            if ([namesArray count]> 1) {
                self.user.lName = [namesArray objectAtIndex:1];
            }
        }

        
        self.user.phone = phoneNumStr;
        
        NSString *object = [@{@"jobTitle":self.user.jobTitle}jsonString];
        self.user.objects = object;
        
        NSDictionary *paramsToBeSent = @{
                                         @"fullname" : [NSString validStringForObject:self.user.name],
                                         @"phone"    : [NSString validStringForObject:self.user.phone],
                                         @"email"    : [NSString validStringForObject:self.user.email],
                                         @"objects"  : [NSString validStringForObject:self.user.objects],
                                         @"type"     : [NSString validStringForObject:self.user.uType],
                                         @"deleted"  : [NSString stringWithFormat:@"%d",self.user.deleted],
                                         @"disabled" : [NSString stringWithFormat:@"%d",self.user.disabled],
                                         @"user"     : [NSString validStringForObject:self.user.fullId],
                                         @"Objects"  : [NSString validStringForObject:object]
                                         };
        
        
        
        
        __weak __block typeof(self) weakself = self;
        
         if (self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi || self.seachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        
        [NetworkManager updateUser:paramsToBeSent success:^(id data, NSString *timestamp) {
            [[CoreDataController sharedManager] updateUser:self.user];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateData];
                
                _customAlert.alertTag = 10002;
                _customAlert.alertType = kAlertTypePopup;
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Profile updated successfully.",nil)];
                [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Profile Updated",nil) andDescription:NSLocalizedString(message,nil)];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[weakself delegate] didUpdatedUserSuccess:self.user];

                [self.navigationController popViewControllerAnimated:YES];
                });
            });
            
        } failure:^(NSError *error) {
            NSLog(@"%@",[error description]);
        }];
         }else{
             [appDelegate showUnavailablityAlert];
         }
    }else{
        [self.tableView reloadData];
    }
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

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    phoneNumStr = nil;
    nameStr = nil;
    roleStr = nil;
    titleStr = nil;
}


@end
