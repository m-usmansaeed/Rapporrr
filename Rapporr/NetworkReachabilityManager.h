//
//  NetworkManager.h
//  KSReachability-Examples
//
//  Created by txlabz on 20/04/2017.
//
//

#import <Foundation/Foundation.h>
@import SystemConfiguration;

#define kNetworkStatusChangedNotification @"kNetworkStatusChangedNotification"

@interface NetworkReachabilityManager : NSObject

+ (NetworkReachabilityManager*)sharedInstance;

@property NSMutableArray *notifications;
@property NSThread *notificationThread;
@property NSLock *notificationLock;
@property NSMachPort *notificationPort;

@end
