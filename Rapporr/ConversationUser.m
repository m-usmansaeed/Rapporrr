//
//  ConversationUser.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 12/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "ConversationUser.h"

@implementation ConversationUser


- (id)initWithDictionary:(NSDictionary *) responseData
{
    NSLog(@"%@",responseData);
    
    self = [super init];
    if (self) {
        self.avatarUrl = [NSString validStringForObject:responseData[@"AvatarUrl"]];
        self.deleted = [responseData[@"Deleted"]integerValue];
        self.disabled = [responseData[@"Disabled"]integerValue];
        self.email = [NSString validStringForObject:responseData[@"Email"]];
        self.fullId = [NSString validStringForObject:responseData[@"FullId"]];
        self.isRegistered = [NSString validStringForObject:responseData[@"IsRegistered"]];
        self.lastSeen = [NSString validStringForObject:responseData[@"LastSeen"]];
        self.name = [NSString validStringForObject:responseData[@"Name"]];
        self.objects = [NSString validStringForObject:responseData[@"Objects"]];
        self.org = [NSString validStringForObject:responseData[@"Org"]];
        self.phone = [NSString validStringForObject:responseData[@"Phone"]];
        self.pin = [NSString validStringForObject:responseData[@"Pin"]];
        self.smsRecieved = [NSString validStringForObject:responseData[@"SmsReceived"]];
        self.timeStamp = [NSString validStringForObject:responseData[@"TimeStamp"]];
       
        
        if ([[NSString validStringForObject:responseData[@"UType"]] isEqualToString:kUSER_TYPE_STD] || [[NSString validStringForObject:responseData[@"UType"]] isEqualToString:kUSER_TYPE_STD_STRING]) {
            self.uType = kUSER_TYPE_STD;
            self.isAdmin = NO;
        }else if ([[NSString validStringForObject:responseData[@"UType"]] isEqualToString:kUSER_TYPE_ADMIN] || [[NSString validStringForObject:responseData[@"UType"]] isEqualToString:kUSER_TYPE_ADMIN_STRING]) {
            self.uType = kUSER_TYPE_ADMIN;
            self.isAdmin = YES;
        }else{
            self.uType = kUSER_TYPE_EXT;
        }
        
        self.userId = [NSString validStringForObject:responseData[@"UserId"]];
        self.lName = [NSString validStringForObject:responseData[@"LName"]];
        self.fName = [NSString validStringForObject:responseData[@"FName"]];
        self.jobTitle = @"";
        
        NSArray *namesArray = [self.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        
        if ([namesArray count]) {
            if (self.fName == nil || [self.fName isEqualToString:@""]) {
                self.fName = [namesArray objectAtIndex:0];
            }
            
            if ((self.lName == nil || [self.lName isEqualToString:@""]) && [namesArray count]> 1) {
                self.lName = [namesArray objectAtIndex:1];
            }
        }
    }
    
    return self;
}

- (id)initWithManagedObject:(NSManagedObject *) conversationUserObj {
    self = [super init];
    if (self) {
        
self.avatarUrl = [conversationUserObj valueForKey:@"avatarUrl"];
//        self.deleted = [[conversationUserObj valueForKey:@"userDelete"]boolValue];
        self.disabled = [[conversationUserObj valueForKey:@"disabled"]boolValue];
        self.email = [conversationUserObj valueForKey:@"email"];
        self.fName = [conversationUserObj valueForKey:@"fName"];
        self.fullId = [conversationUserObj valueForKey:@"fullId"];
        self.isRegistered = [conversationUserObj valueForKey:@"isRegistered"];
        self.lName = [conversationUserObj valueForKey:@"lName"];
        self.lastSeen = [conversationUserObj valueForKey:@"lastSeen"];
        self.name = [conversationUserObj valueForKey:@"name"];
        self.objects = [conversationUserObj valueForKey:@"objects"];
        self.org = [conversationUserObj valueForKey:@"org"];
        self.phone = [conversationUserObj valueForKey:@"phone"];
        self.pin = [conversationUserObj valueForKey:@"pin"];
        self.smsRecieved = [conversationUserObj valueForKey:@"smsRecieved"];
        self.timeStamp = [conversationUserObj valueForKey:@"timeStamp"];
        self.uType = [conversationUserObj valueForKey:@"uType"];
        self.userId = [conversationUserObj valueForKey:@"userId"];
        self.isAdmin = [[conversationUserObj valueForKey:@"isAdmin"] boolValue];
        self.jobTitle = [NSString validStringForObject:[[NSDictionary dictionaryFromString:self.objects] valueForKey:@"jobTitle"]];
    }
    
    return self;
}





@end
