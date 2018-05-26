//
//  NetworkManager.m
//  KSReachability-Examples
//
//  Created by txlabz on 20/04/2017.
//
//

#import "NetworkReachabilityManager.h"

static NetworkReachabilityManager* sharedInstance = nil;

@interface NetworkReachabilityManager()

@end

@implementation NetworkReachabilityManager

+ (NetworkReachabilityManager*)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[NetworkReachabilityManager alloc] init];
        }
    }
    return sharedInstance;
}

- (id)init
{
    if (self) {
        self = [super init];
    }
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [@"apple.com" UTF8String]);
    SCNetworkReachabilitySetCallback(reachability, NetworkReachabilityCallback, NULL);
    SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    return self;
}

static void NetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    @autoreleasepool {
        NetworkReachabilityManager* noteObject = (NetworkReachabilityManager*) CFBridgingRelease(info);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];});
    }
    
    NSLog(@"Hit %d",flags);
}

@end
