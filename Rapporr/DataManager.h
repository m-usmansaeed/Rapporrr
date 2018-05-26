//
//  DataManager.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 20/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (strong, nonatomic) NSString *authToken;
@property (strong, nonatomic) NSString *deviceToken;
@property (strong, nonatomic) NSString *signature;

+ (DataManager *) sharedManager;
+ (NSString*)     generateSignature : (NSString*) urlStr;
+ (NSString*)     createNewHostFor : (NSString*) organisationName;
+ (NSString*)     createAuthHeader : (NSString*) userId andHostId : (NSString*) hostId;

@end
