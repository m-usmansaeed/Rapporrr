//
//  AppDelegate.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 15/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//
@import Firebase;
@import FirebaseMessaging;
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CoreDataController.h"
#import "RKDropdownAlert.h"
#import "InternetAvailability.h"
#import "ContactsVC.h"
#import "MPNotificationView.h"
#import <UserNotifications/UserNotifications.h>
#import <AFNetworking/AFNetworking.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MessageVC.h"

@protocol AppDelegate <NSObject>

-(void)didNetworkConnected:(AFNetworkReachabilityStatus)status;
-(void)didNetworkDisconnected:(AFNetworkReachabilityStatus)status;

@end


@interface AppDelegate : UIResponder <UIApplicationDelegate,NSObject,UNUserNotificationCenterDelegate,FIRMessagingDelegate,MPNotificationViewDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    id cleanupObj;
    NSString *bodyOfNotification;
    MessageModel *mModel;
    NSMutableArray *conversations;
    BOOL cameFromBackground;
    
}

@property (weak, nonatomic) id<AppDelegate>delegate;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) RPConverstionMessage *notificationMsg;

@property (nonatomic) BOOL appJustStartedStatus;


- (NSString *)applicationDocumentsDirectory;
- (void)showAlertView;
- (void)showUnavailablityAlert;

@property (nonatomic, strong) RapporrAlertView *customAlert;
@property (nonatomic, strong) RapporrAlertView *unavailablityAlert;

@property (strong, nonatomic) VerifiedCompanyModel *vcModel;
@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;

@end

