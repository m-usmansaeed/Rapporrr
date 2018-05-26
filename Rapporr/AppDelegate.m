//
//  AppDelegate.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 15/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

@import Firebase;


#import "Constants.h"
#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import "RapporrManager.h"
#import "VerifiedCompanyModel.h"
#import <Crashlytics/Crashlytics.h>
#import "UIFont+Resizing.h"

#include <sys/time.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize notificationMsg;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [MPNotificationView registerNibNameOrClass:@"CustomNotificationView"
                        forNotificationsOfType:@"Custom"];
    
    
    NSString * yourJSONString = @"09-03-2015";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];;
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    NSDate *dateFromString = [dateFormatter dateFromString:yourJSONString];
    [dateFormatter setDateFormat:@"EEE,LLLL dd, yyyy"];
    NSString *output = [dateFormatter stringFromDate:dateFromString];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NetworkStatus"];
    
    [self setupNetworkReachability];
    application.applicationIconBadgeNumber = 0;
    if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) )
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    else
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error )
             {
                 [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
             }
         }];
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [FIRApp configure];
    [self initiateThirdParties];
    [self addColoredStatusPlayer];
    
    if([[CoreDataController sharedManager] ifAnyVerifiedCompant]) {
        
        NSMutableArray *fetchedCompanies = [[CoreDataController sharedManager] getVerifiedCompanies];
        
        for (NSManagedObject * companyObj in fetchedCompanies) {
            VerifiedCompanyModel *tempVcModel = [[VerifiedCompanyModel alloc] initWithManagedObject:companyObj];
            if (tempVcModel.isActive) {
                [RapporrManager sharedManager].vcModel = tempVcModel;
            }
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabBarController"];
        
        self.window.rootViewController = rootViewController;
        [self.window makeKeyAndVisible];
    }
    return YES;
}

- (void)messaging:(nonnull FIRMessaging *)messaging didRefreshRegistrationToken:(nonnull NSString *)fcmToken {
}

- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)registerForRemoteNotifications {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
#endif
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    [self parseNotification:notification.request.content.userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler
{
    [self parseNotificationForBackground:response.notification.request.content.userInfo];
    
}

-(NSMutableArray*) getMessagesForConversationFromDB : (MessageModel*) mModelTemp  {
    NSMutableArray *arrayOfMessages = [[CoreDataController sharedManager] fetchConversationMessagesFromDBForConversation:mModelTemp WithCompletion:^(RPConverstionMessage * _Nullable unSentMessage) {
        
    }];
    
    return arrayOfMessages;
}

- (void) parseNotificationForBackground :(NSDictionary*)notificationDict  {
    if([RapporrManager sharedManager].vcModel.userId.length > 0) {
        NSString *notificationType = [notificationDict objectForKey:@"click_action"];
        NSString *body = [notificationDict objectForKey:@"body"];
        
        
        if([notificationType isEqualToString:@"OPEN_MESSAGE"]) {
            
            RPConverstionMessage *convMsg = [[RPConverstionMessage alloc]initWithNotificationDictionary:notificationDict];
            
            notificationMsg = convMsg;
            bodyOfNotification = body;
            
            mModel = [[CoreDataController sharedManager] getMessageModel:convMsg.conversationId];
            
            if(!mModel) {
                [SVProgressHUD show];
                cameFromBackground = true;
                [self getUserList];
            }
            else {
                if(![[CoreDataController sharedManager] searchForMessage:convMsg]){
                    [[CoreDataController sharedManager] saveConversationMessage:convMsg];
                }else{
                    [[CoreDataController sharedManager] updateConversationMessage:convMsg];
                }
                [[CoreDataController sharedManager] UpdateMessageModelForNotificationWithoutCount:body andTimeStamp:convMsg.timeStamp andConversationID:convMsg.conversationId];
                
                UIViewController *topViewController = [self topViewController];
                
                if ([topViewController isKindOfClass:[ConversationDetailVC class]]) {
                    // code
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshViewForNotification" object:nil];
                }
                else {
                    
                    NSMutableArray *messagesInConversation = [self getMessagesForConversationFromDB:mModel];
                    mModel.messages = messagesInConversation;
                    
                    ConversationDetailVC *vc = [topViewController.storyboard instantiateViewControllerWithIdentifier:@"ConversationDetailVC"];
                    vc.conversation = mModel;
                    vc.hidesBottomBarWhenPushed = YES;
                    [topViewController.navigationController pushViewController:vc animated:YES];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshViewForNotification" object:nil];
                }
                
                
            }
            
            
        }
    }
}

- (void) parseNotification :(NSDictionary*)notificationDict  {
    if([RapporrManager sharedManager].vcModel.userId.length > 0) {
        NSString *notificationType = [notificationDict objectForKey:@"click_action"];
        NSString *body = [notificationDict objectForKey:@"body"];
        
        if([notificationType isEqualToString:@"OPEN_MESSAGE"]) {
            RPConverstionMessage *convMsg = [[RPConverstionMessage alloc]initWithNotificationDictionary:notificationDict];
            
            notificationMsg = convMsg;
            bodyOfNotification = body;
            
            mModel = [[CoreDataController sharedManager] getMessageModel:convMsg.conversationId];
            
            if(!mModel) {
                [self getUserList];
            }
            else {
                
                if(![[CoreDataController sharedManager] searchForMessage:convMsg]){
                    [[CoreDataController sharedManager] saveConversationMessage:convMsg];
                }else{
                    [[CoreDataController sharedManager] updateConversationMessage:convMsg];
                }
                UIViewController *topViewController = [self topViewController];
                
                if ([topViewController isKindOfClass:[ConversationDetailVC class]]) {
                    //Make sure if it is of same cobersation or not
                    ConversationDetailVC *conVC = (ConversationDetailVC*)[self topViewController];
                    if([conVC.conversation.conversationId isEqualToString:mModel.conversationId]) {
                        
                        [[CoreDataController sharedManager] UpdateMessageModelForNotificationWithoutCount:body andTimeStamp:convMsg.timeStamp andConversationID:convMsg.conversationId];
                    }
                    else{
                        [self showTopBarMessage:body :convMsg];
                    }
                }
                else {
                    [self showTopBarMessage:body :convMsg];
                }
                
                //Update screens by local notification
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshViewForNotification" object:nil];
            }
            
            
            
        }
    }
}

- (void) showTopBarMessage : (NSString *) body : (RPConverstionMessage*)convMsg {
    
    UIViewController *topViewController = [self topViewController];
    
    [[CoreDataController sharedManager] UpdateMessageModelForNotification:body andTimeStamp:convMsg.timeStamp andConversationID:convMsg.conversationId];
    
    [MPNotificationView notifyWithText:@"New Message" detail:body image:[UIImage imageNamed:@"NotificationIcon"] duration:4.0 type:@"Custom" andTouchBlock:^(MPNotificationView *notificationView)
     {
         mModel = [[CoreDataController sharedManager] getMessageModel:convMsg.conversationId];
         NSMutableArray *messagesInConversation = [self getMessagesForConversationFromDB:mModel];
         mModel.messages = messagesInConversation;
         
         ConversationDetailVC *vc = [topViewController.storyboard instantiateViewControllerWithIdentifier:@"ConversationDetailVC"];
         vc.conversation = mModel;
         [vc updateMessageCounter];
         vc.hidesBottomBarWhenPushed = YES;
         [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshViewForNotification" object:nil];
         [topViewController.navigationController pushViewController:vc animated:YES];
     }];
}

-(void) playSound {
    SystemSoundID soundID;
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef ref = CFBundleCopyResourceURL(mainBundle, (CFStringRef)@"gets-in-the-way.m4r", NULL, NULL);
    AudioServicesCreateSystemSoundID(ref, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark - Navigate to specific View Controller

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

#pragma mark - Third Party Invocation

- (void) initiateThirdParties {
    [Fabric with:@[[Crashlytics class]]];
}

#pragma mark - UINavigation Methods

- (void) addColoredStatusPlayer {
    
    UIView* statusBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 20)];
    statusBg.backgroundColor = statusBarColor;
    statusBg.tag = 1012;
    //Add the view behind the status bar
    [self.window.rootViewController.view addSubview:statusBg];
}


- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil] ;
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator

{
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self  applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"Rapporr.sqlite"]];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator      addPersistentStoreWithType:NSSQLiteStoreType configuration:nil   URL:storeUrl options:nil error:&error])
    {
        /*Error for store creation should be handled in here*/
    }
    
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


/*!
 * Called by Reachability whenever status changes.
 */

-(void)setupNetworkReachability {
    
    [AFNetworkReachabilityManager.sharedManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        self.seachabilityStatus = status;
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [self.delegate didNetworkConnected:status];
        }else{
            [self.delegate didNetworkDisconnected:status];
        }
    }];
    [AFNetworkReachabilityManager.sharedManager startMonitoring];
    
}


- (void)reachabilityChanged:(NSNotification *)note
{
    InternetAvailability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[InternetAvailability class]]);
}


- (void)showAlertView
{
    _customAlert = [[RapporrAlertView alloc] init];
    [_customAlert setDelegate:(id)self];
    _customAlert.alertTag = 1000;
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Experiencing internet connection issues. Please try again later",nil)];
    [self.customAlert showPopUpInView:self.window.rootViewController.view withMessage:NSLocalizedString(@"Error",nil) andDescription:NSLocalizedString(message,nil)];
    
}

- (void)showUnavailablityAlert
{
    _unavailablityAlert = [[RapporrAlertView alloc] init];
    [_unavailablityAlert setDelegate:(id)self];
    _unavailablityAlert.alertTag = 1001;
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Unable to process request at the moment. Try again Later",nil)];
    [self.unavailablityAlert showPopUpInView:self.window.rootViewController.view withMessage:NSLocalizedString(@"Error",nil) andDescription:NSLocalizedString(message,nil)];
}

-(void)RapporrAlertOK:(id)sender
{
    if (_customAlert.alertTag == 1000) {
        [_customAlert removeCustomAlertFromViewInstantly];
    }else if (_unavailablityAlert.alertTag == 1001) {
        [self.unavailablityAlert removeCustomAlertFromViewInstantly];
    }
}

-(void)RapporrAlertCancel
{
    [_customAlert removeCustomAlertFromViewInstantly];
    [self.unavailablityAlert removeCustomAlertFromViewInstantly];
    
}

- (void) getUserList {
    
    NSString *userTimeStamp;
    
    userTimeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:kfetchWithUserTimestamp];
    if(userTimeStamp == nil){
        userTimeStamp = @"all";
    }
    NSDictionary *paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:[RapporrManager sharedManager].vcModel.hostID,@"hostId",[RapporrManager sharedManager].vcModel.userId,@"userID",nil];
    
    NSString *uri = [NSString stringWithFormat:@"%@%@/users?last=%@",URI_GET_USERS,[RapporrManager sharedManager].vcModel.orgId,@"all"];
    
    [NetworkManager fetchConversationAPI:uri parameters:paramsToBeSent success:^(id data, NSString *timestamp) {
        
        [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:kfetchWithUserTimestamp];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSError* error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
        
        for(int i=0; i<jsonArray.count; i++) {
            ConversationUser *conversationUserModel = [[ConversationUser alloc] initWithDictionary:(NSDictionary*)[jsonArray objectAtIndex:i]];
            [self saveConversationUser:conversationUserModel];
        }
        
        [self getConversationList];
        
        
    }failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error");
        
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
            
            for(int i=0; i<jsonArray.count; i++) {
                MessageModel *mModelTemp = [[MessageModel alloc] initWithDictionary:(NSDictionary*)[jsonArray objectAtIndex:i]];
                [self saveMessageModel:mModelTemp];
            }
        }
        
        [self getMessageList];
        
    }failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error");
    }];
}

- (void) saveMessageModel : (MessageModel*) mModelTemp {
    
    BOOL isNewConv = [self checkIfConversationExist:mModelTemp];
    
    if (!isNewConv){
        [[CoreDataController sharedManager] saveMessageModel:mModelTemp];
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

- (void) getMessageList {
    [self fetchMessagesFromDB];
    NSString *TimeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:kfetchWithAllMessagesTimestamp];
    if(TimeStamp == nil){
        TimeStamp = @"all";
    }
    
    NSDictionary *paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:[RapporrManager sharedManager].vcModel.hostID,@"hostId",[RapporrManager sharedManager].vcModel.userId,@"userID",nil];
    
    NSString *orgId  = [RapporrManager sharedManager].vcModel.orgId;
    NSString *userId = [RapporrManager sharedManager].vcModel.userId;
    
    NSString *uri = [NSString stringWithFormat:URI_GET_ALL_MESSAGES,orgId,userId,TimeStamp];
    [NetworkManager fetchAllMessages:uri parameters:paramsToBeSent success:^(id data ,NSString *timestamp) {
        
        [SVProgressHUD dismiss];
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray *)data;
            
            if ([array count]) {
                
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshViewForNotification" object:nil];
        
        if(notificationMsg) {
            UIViewController *topViewController = [self topViewController];
            
            if ([topViewController isKindOfClass:[ConversationDetailVC class]]) {
                //Make sure if it is of same cobersation or not
                ConversationDetailVC *conVC = (ConversationDetailVC*)[self topViewController];
                if([conVC.conversation.conversationId isEqualToString:mModel.conversationId]) {
                    
                    [[CoreDataController sharedManager] UpdateMessageModelForNotificationWithoutCount:bodyOfNotification andTimeStamp:notificationMsg.timeStamp andConversationID:notificationMsg.conversationId];
                }
                else{
                    if(cameFromBackground){
                        mModel = [[CoreDataController sharedManager] getMessageModel:notificationMsg.conversationId];
                        NSMutableArray *messagesInConversation = [self getMessagesForConversationFromDB:mModel];
                        mModel.messages = messagesInConversation;
                        
                        ConversationDetailVC *vc = [topViewController.storyboard instantiateViewControllerWithIdentifier:@"ConversationDetailVC"];
                        vc.conversation = mModel;
                        [vc updateMessageCounter];
                        cameFromBackground = false;
                        vc.hidesBottomBarWhenPushed = YES;
                        
                        [topViewController.navigationController pushViewController:vc animated:YES];
                        
                        
                    }
                    else {
                        [self showTopBarMessage:bodyOfNotification :notificationMsg];
                    }
                }
            }
            else {
                if(cameFromBackground){
                    mModel = [[CoreDataController sharedManager] getMessageModel:notificationMsg.conversationId];
                    NSMutableArray *messagesInConversation = [self getMessagesForConversationFromDB:mModel];
                    mModel.messages = messagesInConversation;
                    
                    ConversationDetailVC *vc = [topViewController.storyboard instantiateViewControllerWithIdentifier:@"ConversationDetailVC"];
                    vc.conversation = mModel;
                    [vc updateMessageCounter];
                    cameFromBackground = false;
                    vc.hidesBottomBarWhenPushed = YES;
                    [topViewController.navigationController pushViewController:vc animated:YES];
                }
                else {
                    [self showTopBarMessage:bodyOfNotification :notificationMsg];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshViewForNotification" object:nil];
            
        }
        
    }failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error");
    }];
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
    NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"timeStamp"
                                                            ascending:NO
                                                             selector:@selector(caseInsensitiveCompare:)];
    
    conversations = [[conversations sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    
}

@end
