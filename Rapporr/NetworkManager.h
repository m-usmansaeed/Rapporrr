//
//  NetworkManager.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 20/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RapporrManager.h"


@interface NetworkManager : NSObject
typedef void (^loadSuccess)(id data,NSString *timestamp);
typedef void (^loadFailure)(NSError *error);

+(void)  validateMobileNumber:(NSString *) uri parameters:(NSString *) number success:(loadSuccess) success failure:(loadFailure) failure;
+(void)  getCompaniesForMobileNumber:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;
+(void)  generateVerificationCode:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;
+(void)  validatePinCode:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;
+(void)  createNewRapporr:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;
+(void) fetchConversationAPI:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;

+(void) fetchTeamAPI:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;


- (void) getUserListWithCompletion:(void(^)(BOOL isCompleted))completed;
- (void)getTeamsWithCompletion:(void (^)(BOOL  success))completion;
 

+(void)promoteUser:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;
+(void)deactivateUser:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;
+(void)resendUser:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;  
+(void)updateUser:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;



+(void) createNewTeam:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;


+(void)inviteUser:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;


+(void) fetchAllMessages:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;

+(void)sendMessage:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;



+(void)makeGETCall:(NSString *) uri parameters:(NSDictionary *) params success:(void (^)(id data,NSString *timeStamp))success failure:(loadFailure) failure;
+(void)GETCall:(NSString *) uri parameters:(NSDictionary *) params success:(void (^)(id data,NSString *timeStamp))success failure:(loadFailure) failure;

+(void)makePOSTCall:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;


+(void) postImageOnAmazonServer:(NSData *) imageToPost parameters:(NSString *) params  andphotoID:(NSString*) photoID success:(loadSuccess) success failure:(loadFailure) failure;

+(void) subscribeToPushNotification:(NSString *) uri andDeviceToken:(NSString *) deviceToken parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;

+(void)downloadFileWithUrl:(NSString *)url completionBlock:(void(^)(NSString *filePath,BOOL isFinished))completion;



@end
