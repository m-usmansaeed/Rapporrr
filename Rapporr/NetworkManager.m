//
//  NetworkManager.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 20/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "Constants.h"
#import "DataManager.h"
#import "SVProgressHUD.h"
#import "NetworkManager.h"
#import <AFNetworking/AFNetworking.h>

@implementation NetworkManager

+ (NSError *)createErrorMessageForObject:(id)responseObject
{
    
    NSString * responseStr = @"";
    
    if (responseObject[@"message"])
        responseStr = [NSString stringWithFormat:@"%@",responseObject[@"message"]];
    else
        responseStr = [NSString stringWithFormat:@"API Response Error!\n%@", responseObject];
    
    
    NSError *error = [NSError errorWithDomain:@"Failed!"
                                         code:100
                                     userInfo:@{
                                                // NSLocalizedDescriptionKey:responseObject[@"message"]
                                                
                                                NSLocalizedDescriptionKey:responseStr
                                                
                                                }];
//    NSLog(@"Failed with Response: %@", responseObject);
    return error;
}


+ (AFSecurityPolicy*) siteSecurityPolicy
{
    /**** SSL Pinning ****/
    
    //    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"rapporrappcom" ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    //    NSString *cerPath1 = [[NSBundle mainBundle] pathForResource:@"imagesrapporrappcom" ofType:@"cer"];
    //    NSData *certData1 = [NSData dataWithContentsOfFile:cerPath1];
    
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    
    
    [policy setAllowInvalidCertificates:YES];
    [policy setValidatesDomainName:NO];
    [policy setPinnedCertificates:@[certData]];
    /**** SSL Pinning ****/
    
    return policy;
}


+(void)  getCompaniesForMobileNumber:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure {
    
    [SVProgressHUD show];
    
    uri = [NSString stringWithFormat:@"%@%@",BASE_URL,uri];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:
           NSUTF8StringEncoding];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:uri];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    
    [manager POST:uri parameters:params success:^(NSURLSessionDataTask *task, id responseObject)
     {
         [SVProgressHUD dismiss];
         
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         success(responseObject,nil);
         
         
     }
          failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [SVProgressHUD dismiss];
         NSLog(@"Failure: %@", error.localizedDescription);
         failure(error);
     }];
}

+(void)  generateVerificationCode:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure {
    
    [SVProgressHUD show];
    
    uri = [NSString stringWithFormat:@"%@%@",BASE_URL,uri];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:
           NSUTF8StringEncoding];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:uri];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    
    [manager POST:uri parameters:params success:^(NSURLSessionDataTask *task, id responseObject)
     {
         [SVProgressHUD dismiss];
         
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         success(responseObject,nil);
         
     }failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [SVProgressHUD dismiss];
         NSLog(@"Failure: %@", error.localizedDescription);
         failure(error);
     }];
}

+(void)  validatePinCode:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure {
    
    
    NSString *hostId = [params objectForKey:@"hostId"];
    [SVProgressHUD show];
    
    uri = [NSString stringWithFormat:@"%@%@",BASE_URL,uri];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    
    [manager POST:uri parameters:params success:^(NSURLSessionDataTask *task, id responseObject)
     {
         [SVProgressHUD dismiss];
         
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         success(responseObject,nil);
         
         
     }
          failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [SVProgressHUD dismiss];
         NSLog(@"Failure: %@", error.localizedDescription);
         failure(error);
     }];
}

+(void) createNewRapporr:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure {
    
    
    NSString *hostId = [params objectForKey:@"hostId"];
    [SVProgressHUD show];
    
    uri = [NSString stringWithFormat:@"%@%@",BASE_URL,uri];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    
    [manager POST:uri parameters:params success:^(NSURLSessionDataTask *task, id responseObject)
     {
         [SVProgressHUD dismiss];
         
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         
         success(responseObject,nil);
         
     }
          failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [SVProgressHUD dismiss];
         NSLog(@"Failure: %@", error.localizedDescription);
         failure(error);
     }];
}



+(void) fetchConversationAPI:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure {
    
    
    NSString *hostId = [params objectForKey:@"hostId"];
    NSString *userId = [params objectForKey:@"userID"];
    
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    uri = [NSString stringWithFormat:@"%@%@",BASE_URL,uri];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"imagesrapporrappcom" ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    
    manager.securityPolicy.pinnedCertificates = @[localCertificate];
    [manager.requestSerializer setTimeoutInterval:10];
    
    [manager GET:uri parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
     {
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         success(responseObject,dictionary[@"timestamp"]);
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"Failure: %@", error.localizedDescription);
         [SVProgressHUD dismiss];
         failure(error);
     }];
}

+(void)validateMobileNumber:(NSString *) uri parameters:(NSString *) number success:(loadSuccess) success failure:(loadFailure) failure {
    
    [SVProgressHUD show];
    
    uri = [NSString stringWithFormat:@"%@%@%@",BASE_URL,URI_VALIDATE_NUMBER,number];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:
           NSUTF8StringEncoding];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:uri parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
     {
         [SVProgressHUD dismiss];
         
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         
         NSError* error;
         success(responseObject,nil);
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [SVProgressHUD dismiss];
         NSLog(@"Failure: %@", error.localizedDescription);
         failure(error);
     }];
}

- (void) getUserListWithCompletion:(void(^)(BOOL isCompleted))completed;
{
    
    NSString *userTimeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:kfetchWithUserTimestamp];
    if(userTimeStamp == nil){
        userTimeStamp = @"all";
    }
    
    NSDictionary *paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:[RapporrManager sharedManager].vcModel.hostID,@"hostId",[RapporrManager sharedManager].vcModel.userId,@"userID",nil];
    
    NSString *uri = [NSString stringWithFormat:@"%@%@/users?last=%@",URI_GET_USERS,[RapporrManager sharedManager].vcModel.orgId,userTimeStamp];
    
    [NetworkManager fetchConversationAPI:uri parameters:paramsToBeSent success:^(id data,NSString *timestamp) {
        
        [SVProgressHUD dismiss];
        
        NSError* error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
        
        [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:kfetchWithUserTimestamp];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        for(int i=0; i<jsonArray.count; i++) {
            
            ConversationUser *conversationUserModel = [[ConversationUser alloc] initWithDictionary:(NSDictionary*)[jsonArray objectAtIndex:i]];
            
            if(!conversationUserModel.disabled){
                [self saveConversationUser:conversationUserModel];
            }
        }
        
        completed(YES);
        
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
        //        [[CoreDataController sharedManager] updateUser:ConversationUser];
    }
}

+(void) fetchTeamAPI:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure {
    
    
    NSString *hostId = [params objectForKey:@"hostId"];
    NSString *userId = [params objectForKey:@"userID"];
    
    [SVProgressHUD show];
    
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    uri = [NSString stringWithFormat:@"%@%@",BASE_URL,uri];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setTimeoutInterval:10];

    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"imagesrapporrappcom" ofType:@"crt"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    
    manager.securityPolicy.pinnedCertificates = @[localCertificate];
    
    [manager GET:uri parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
     {
         [SVProgressHUD dismiss];
         
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         success(responseObject,dictionary[@"timestamp"]);
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [SVProgressHUD dismiss];
         NSLog(@"Failure: %@", error.localizedDescription);
         failure(error);
     }];
}

- (void)getTeamsWithCompletion:(void (^)(BOOL success))completion;
{
    
    NSString *TimeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:kfetchWithTeamAPITimestamp];
    if(TimeStamp == nil){
        TimeStamp = @"all";
    }
    
    NSDictionary *paramsToBeSent = [NSDictionary dictionaryWithObjectsAndKeys:[RapporrManager sharedManager].vcModel.hostID,@"hostId",[RapporrManager sharedManager].vcModel.userId,@"userID",nil];
    
    NSString *uri = [NSString stringWithFormat:@"%@%@?last=%@",URI_GET_COMMANDATA,[RapporrManager sharedManager].vcModel.orgId,@"all"];
    
    [NetworkManager fetchTeamAPI:uri parameters:paramsToBeSent success:^(id data,NSString *timestamp) {
        
        [SVProgressHUD dismiss];
        
        [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:kfetchWithTeamAPITimestamp];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSError* error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
        
//        NSLog(@"%@",jsonArray);
        
        for(NSDictionary *dict in jsonArray) {
            if ([dict[@"RecType"] isEqualToString:@"Group"]) {
                TeamModel *team = [[TeamModel alloc] initWithDictionary:dict];
                if(team.teamStatus == kTeamActive){
                    [self saveTeam:team];
                }
            }
            if([dict[@"RecType"] isEqualToString:@"RapporrRec"]){
                NSString *intranet = dict[@"Intranet"];
                NSString *nameString = [NSString validStringForObject:[[NSDictionary dictionaryFromString:intranet] valueForKey:@"name"]];
                NSString *urlString = [NSString validStringForObject:[[NSDictionary dictionaryFromString:intranet] valueForKey:@"address"]];
                [Utils saveUrlAndHubName:urlString hubname:nameString];
            }
        }

        completion(YES);
        
    }failure:^(NSError *error) {
        NSLog(@"Error");
        [SVProgressHUD dismiss];
    }];
}

- (void) saveTeam : (TeamModel *) team {
    
    BOOL isNewConv = [[CoreDataController sharedManager] checkIfTeamExist:team];
    
    if (!isNewConv){
        [[CoreDataController sharedManager] saveTeam:team];
    }else{
        [[CoreDataController sharedManager] updateTeam:team];
    }
}


+(void) createNewTeam:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure  {
    
    NSString *hostId = [params objectForKey:@"hostid"];
    NSString *userId = [params objectForKey:@"userid"];
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    [SVProgressHUD show];
    
    uri = [NSString stringWithFormat:@"%@%@",BASE_URL,uri];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSString *signature = [DataManager generateSignature:signatureStr];
    //    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    manager.securityPolicy = policy;
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    // optional
    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"rapporrappcom" ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    manager.securityPolicy.pinnedCertificates = @[localCertificate];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setTimeoutInterval:10];

    [manager POST:uri parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [SVProgressHUD dismiss];
         
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)operation.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         success(responseObject,nil);
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [SVProgressHUD dismiss];
         NSLog(@"Failure: %@", error.localizedDescription);
         failure(error);
     }];
    
    
}


+(void)promoteUser:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;
{
    NSString *userId = [params objectForKey:@"user"];
    NSString *hostId = [NSString validStringForObject:[RapporrManager sharedManager].vcModel.hostID];
    
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    [SVProgressHUD show];
    
    NSString *uri = [NSString stringWithFormat:@"%@%@",BASE_URL,URI_PROMOTE_USER];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager setSecurityPolicy:[NetworkManager siteSecurityPolicy]];
    [manager.requestSerializer setTimeoutInterval:10];

    
    [manager POST:uri parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [SVProgressHUD dismiss];
        
        NSDictionary *dictionary = nil;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
            dictionary = [httpResponse allHeaderFields];
        }
        success(@YES,nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Failure: %@", error.localizedDescription);
        failure(error);
    }];
    
    
}


+(void)deactivateUser:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;
{
    
    NSString *userId = [params objectForKey:@"user"];
    NSString *hostId = [NSString validStringForObject:[RapporrManager sharedManager].vcModel.hostID];
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    [SVProgressHUD show];
    
    NSString *uri = [NSString stringWithFormat:@"%@%@",BASE_URL,URI_DEACTIVE_USER];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager setSecurityPolicy:[NetworkManager siteSecurityPolicy]];
    [manager.requestSerializer setTimeoutInterval:10];

    [manager POST:uri parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [SVProgressHUD dismiss];
        
        NSDictionary *dictionary = nil;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
            dictionary = [httpResponse allHeaderFields];
        }
        success(@YES,nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Failure: %@", error.localizedDescription);
        failure(error);
    }];
    
}


+(void)resendUser:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;
{
    
    NSString *userId = [params objectForKey:@"user"];
    NSString *hostId = [NSString validStringForObject:[RapporrManager sharedManager].vcModel.hostID];
    
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    [SVProgressHUD show];
    
    NSString *uri = [NSString stringWithFormat:@"%@%@",BASE_URL,URI_RESEND_INVITE];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager setSecurityPolicy:[NetworkManager siteSecurityPolicy]];
    [manager.requestSerializer setTimeoutInterval:10];

    [manager POST:uri parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [SVProgressHUD dismiss];
        
        NSDictionary *dictionary = nil;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
            dictionary = [httpResponse allHeaderFields];
        }
        success(@YES,nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Failure: %@", error.localizedDescription);
        failure(error);
    }];
    
    
}

+(void)updateUser:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;
{
    
    NSString *userId = [params objectForKey:@"user"];
    NSString *hostId = [NSString validStringForObject:[RapporrManager sharedManager].vcModel.hostID];
    
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    [SVProgressHUD show];
    
    NSString *uri = [NSString stringWithFormat:@"%@%@",BASE_URL,URI_UPDATEUSER];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager setSecurityPolicy:[NetworkManager siteSecurityPolicy]];
    [manager.requestSerializer setTimeoutInterval:10];

    [manager POST:uri parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [SVProgressHUD dismiss];
        
        NSDictionary *dictionary = nil;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
            dictionary = [httpResponse allHeaderFields];
        }
        success(@YES,nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Failure: %@", error.localizedDescription);
        failure(error);
    }];
    
    
}

+(void)inviteUser:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;
{
    
    NSString *userId = [params objectForKey:@"user"];
    NSString *hostId = [NSString validStringForObject:[RapporrManager sharedManager].vcModel.hostID];
    
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    [SVProgressHUD show];
    
    NSString *uri = [NSString stringWithFormat:@"%@%@",BASE_URL,URI_INVITE_USER];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager setSecurityPolicy:[NetworkManager siteSecurityPolicy]];
    [manager.requestSerializer setTimeoutInterval:10];

    [manager POST:uri parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [SVProgressHUD dismiss];
        
        NSDictionary *dictionary = nil;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
            dictionary = [httpResponse allHeaderFields];
        }
        
        NSError* error;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData: responseObject options: NSJSONReadingMutableContainers error: &error];
        
        success(data,nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Failure: %@", error.localizedDescription);
        failure(error);
    }];
}

+(void) fetchAllMessages:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure {
    
    
    NSString *hostId = [RapporrManager sharedManager].vcModel.hostID;
    NSString *userId = [RapporrManager sharedManager].vcModel.userId;
    
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    uri = [NSString stringWithFormat:@"%@%@",BASE_URL,uri];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setTimeoutInterval:10];

    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"imagesrapporrappcom" ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    
    manager.securityPolicy.pinnedCertificates = @[localCertificate];
    
    [manager GET:uri parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
     {
         [SVProgressHUD dismiss];
         
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         NSError* error;
         NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: responseObject options: NSJSONReadingMutableContainers error: &error];
         
//         NSLog(@"%@",jsonArray);
         
         success(jsonArray,dictionary[@"timestamp"]);
         
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"Failure: %@", error.localizedDescription);
         failure(error);
         [SVProgressHUD dismiss];
         
     }];
}

+(void)sendMessage:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure;
{
    
    NSString *hostId = [RapporrManager sharedManager].vcModel.hostID;
    NSString *userId = [RapporrManager sharedManager].vcModel.userId;
    
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    NSString *uri = [NSString stringWithFormat:@"%@%@",BASE_URL,URI_POST_SEND_MESSAGES];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager setSecurityPolicy:[NetworkManager siteSecurityPolicy]];
    [manager.requestSerializer setTimeoutInterval:10];

    
    [manager POST:uri parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        [SVProgressHUD dismiss];
        NSDictionary *dictionary = nil;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
            dictionary = [httpResponse allHeaderFields];
        }
        NSError* error;
        NSDictionary *obj = [NSJSONSerialization JSONObjectWithData: responseObject options: NSJSONReadingMutableContainers error: &error];
        
        success(obj,nil);
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Failure: %@", error.localizedDescription);
        failure(error);
    }];
}


+(void)makeGETCall:(NSString *) uri parameters:(NSDictionary *) params success:(void (^)(id data,NSString *timeStamp))success failure:(loadFailure) failure {
    
    NSString *hostId = [RapporrManager sharedManager].vcModel.hostID;
    NSString *userId = [RapporrManager sharedManager].vcModel.userId;
    
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    uri = [NSString stringWithFormat:@"%@%@",BASE_URL,uri];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setTimeoutInterval:10];

    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"imagesrapporrappcom" ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    
    manager.securityPolicy.pinnedCertificates = @[localCertificate];
    
    
    [manager GET:uri parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
     {
      
         
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         NSError* error;
         NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: responseObject options: NSJSONReadingMutableContainers error: &error];
        
         if (success) {
             success(jsonArray,dictionary[@"timestamp"]);
         }
     
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"Failure: %@", error.localizedDescription);
        
         if (failure) {
             failure(error);
         }
         
         [SVProgressHUD dismiss];
     }];
}

+(void)GETCall:(NSString *) uri parameters:(NSDictionary *) params success:(void (^)(id data,NSString *timeStamp))success failure:(loadFailure) failure {
    
    NSString *hostId = [RapporrManager sharedManager].vcModel.hostID;
    NSString *userId = [RapporrManager sharedManager].vcModel.userId;
    
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    uri = [NSString stringWithFormat:@"%@%@",BASE_URL,uri];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setTimeoutInterval:10];
    
    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"imagesrapporrappcom" ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    
    manager.securityPolicy.pinnedCertificates = @[localCertificate];
    
    
    [manager GET:uri parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
     {
         
         
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         NSError* error;
         NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: responseObject options: NSJSONReadingMutableContainers error: &error];
         
         if (success) {
             NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             success(jsonArray,[NSString validStringForObject:str]);
         }
         
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"Failure: %@", error.localizedDescription);
         
         if (failure) {
             failure(error);
         }
         
         [SVProgressHUD dismiss];
     }];
}


+(void)makePOSTCall:(NSString *) uri parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure
{
    
    NSString *hostId = [RapporrManager sharedManager].vcModel.hostID;
    NSString *userId = [RapporrManager sharedManager].vcModel.userId;
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    uri = [NSString stringWithFormat:@"%@%@",BASE_URL,uri];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    [manager setSecurityPolicy:[NetworkManager siteSecurityPolicy]];
    [manager.requestSerializer setTimeoutInterval:10];
    [manager POST:uri parameters:params success:^(NSURLSessionDataTask *task, id responseObject)
     {
         [SVProgressHUD dismiss];
         
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         NSError* error;
         NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: responseObject options: NSJSONReadingMutableContainers error: &error];
         
         success(jsonArray,nil);
         
     }
          failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [SVProgressHUD dismiss];
         NSLog(@"Failure: %@", error.localizedDescription);
         failure(error);
     }];
}

+(void) postImageOnAmazonServer:(NSData *) imageToPost parameters:(NSString *) params  andphotoID:(NSString*) photoID success:(loadSuccess) success failure:(loadFailure) failure  {
    
    NSDictionary* parametersDictionary = @{@"X-FILE-NAME" : @"avatar",
                                           @"rapporr-key" : @"LcQPPR9baG7",
                                           @"acl" : @"public-read",
                                           @"key" : photoID,
                                           @"Content-type" : @"image/png"
                                           };
    
    NSString *uri = @"https://rapporrapp.s3.amazonaws.com/";
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securityPolicy setValidatesDomainName:NO];
    [securityPolicy setAllowInvalidCertificates:YES];
    manager.securityPolicy = securityPolicy;
    
    // optional
    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"imagesrapporrappcom" ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    manager.securityPolicy.pinnedCertificates = @[localCertificate];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:uri parameters:parametersDictionary constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageToPost name:@"file" fileName:@"profileImage" mimeType:@"image/png"];
        
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
    
}

+(void) subscribeToPushNotification:(NSString *) uri andDeviceToken:(NSString *) deviceToken parameters:(NSDictionary *) params success:(loadSuccess) success failure:(loadFailure) failure
{
    
    NSString *hostId = [params objectForKey:@"host"];
    NSString *userId = [params objectForKey:@"userid"];
    
    NSString *authorization = [DataManager createAuthHeader:userId andHostId:hostId];
    
    uri = [NSString stringWithFormat:@"%@%@",BASE_URL,uri];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@",uri,RAPPORR_API_KEY];
    
    NSURL *baseURL = [[NSURL alloc] initWithString:BASE_URL];
    NSString *signature = [DataManager generateSignature:signatureStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:COOKIE forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:RAPPORRVERSION forHTTPHeaderField:@"rapporrverison"];
    [manager.requestSerializer setValue:hostId forHTTPHeaderField:@"Rapporrhost"];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    [manager POST:uri parameters:params success:^(NSURLSessionDataTask *task, id responseObject)
     {
         NSDictionary *dictionary = nil;
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
         if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
             dictionary = [httpResponse allHeaderFields];
         }
         
         success(responseObject,dictionary[@"timestamp"]);
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"Failure: %@", error.localizedDescription);
         [SVProgressHUD dismiss];
         failure(error);
     }];
}

+(void)downloadFileWithUrl:(NSString *)url completionBlock:(void(^)(NSString *filePath,BOOL isFinished))completion{

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        completion(filePath.absoluteString,YES);
        
    }];
    [downloadTask resume];

}


@end
