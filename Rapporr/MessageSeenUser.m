//
//  MessageSeenBy.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/1/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "MessageSeenUser.h"

@implementation MessageSeenUser


- (id)initWithDictionary:(NSDictionary *) responseData;
{
    //    NSLog(@"%@",responseData);
    
    self = [super init];
    if (self) {
        
        self.conversationId   = [NSString validStringForObject:responseData[@"ConversationId"]];
        self.hostId           = [NSString validStringForObject:responseData[@"HostId"]];
        self.lastMessageId    = [NSString validStringForObject:responseData[@"LastMessageId"]];
        self.orgId            = [NSString validStringForObject:responseData[@"OrgId"]];
        self.rType            = [NSString validStringForObject:responseData[@"RType"]];
        self.timeStamp        = [NSString validStringForObject:responseData[@"TimeStamp"]];
        self.userId           = [NSString validStringForObject:responseData[@"UserId"]];
    }
    
    return self;
}

- (id)initWithManagedObject:(NSManagedObject *) teamObject
{
    self = [super init];
    
    if (self) {
        
        self.conversationId   = [teamObject valueForKey:@"ConversationId"];
        self.hostId           = [teamObject valueForKey:@"HostId"];
        self.lastMessageId    = [teamObject valueForKey:@"LastMessageId"];
        self.orgId            = [teamObject valueForKey:@"OrgId"];
        self.rType            = [teamObject valueForKey:@"RType"];
        self.timeStamp        = [teamObject valueForKey:@"TimeStamp"];
        self.timeStamp        = [teamObject valueForKey:@"TimeStamp"];
        self.userId           = [teamObject valueForKey:@"UserId"];
    }
    
    return self;
}

+(NSMutableArray *)parseSeenMessages:(NSArray *)array forMessages:(NSMutableArray *)messages;
{
    
//    https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/ClassMethod.html
    
    NSMutableArray *filterArray = [[array removeDuplicatesFromArrayOnProperty:@"LastMessageId" andUserId:@"UserId"] mutableCopy];
    
    NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"msgId"
                                                            ascending:YES
                                                             selector:@selector(caseInsensitiveCompare:)];
    
    messages = [[messages sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    NSMutableSet *missingSet = [[NSMutableSet alloc]init];
    [messages enumerateObjectsUsingBlock:^(RPConverstionMessage *message, NSUInteger index, BOOL *stop) {
        for (NSDictionary *dict in filterArray) {
            if (![message.user.fullId isEqualToString:dict[@"UserId"]]) {
                if (![missingSet containsObject:message.user.fullId]){
                    if (message.user) {
                        [missingSet addObject:message.user.fullId];
                    }
                }
            }
        }
    }];
    
    [[missingSet allObjects] enumerateObjectsUsingBlock:^(NSString *userId, NSUInteger index, BOOL *stop) {
        for (RPConverstionMessage *message in messages) {
            if ([message.user.fullId isEqualToString:userId]) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setObject:[NSString stringWithFormat:@"%@",message.conversationId] forKey:@"ConversationId"];
                [dict setObject:[NSString stringWithFormat:@"%@",[RapporrManager sharedManager].vcModel.hostID] forKey:@"HostId"];
                [dict setObject:[NSString stringWithFormat:@"%@",message.msgId] forKey:@"LastMessageId"];
                [dict setObject:[NSString stringWithFormat:@"%@",[RapporrManager sharedManager].vcModel.orgId] forKey:@"OrgId"];
                [dict setObject:@"MESSAGE" forKey:@"RType"];
                [dict setObject:message.timeStamp forKey:@"TimeStamp"];
                [dict setObject:message.user.fullId forKey:@"UserId"];
                [filterArray addObject:dict];
            }
        }
    }];
    
    int count = 0;
    
    NSMutableArray *seenMessages = [[NSMutableArray alloc]init];
    NSMutableArray *seenModalArray = [[NSMutableArray alloc]init];

    for (int i = (int)[filterArray count]-1; i>0; i--) {
        NSDictionary *dict = filterArray[i];
        
        MessageSeenUser *seenBy = [[MessageSeenUser alloc]initWithDictionary:dict];
        if (seenBy) {
            if (![seenBy.lastMessageId isEqualToString:@"0"]) {
                
                for (int j = [seenBy.lastMessageId intValue]; j>0; j--) {
                    NSData *serializedData = [NSKeyedArchiver archivedDataWithRootObject:dict];
                    NSMutableDictionary* seenUser = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:serializedData];
                    
                    [seenUser setValue:seenBy.lastMessageId forKey:@"LastMessageId"];
                    if (![seenMessages isContainsDictionary:seenUser]) {
                        MessageSeenUser *obj = [[MessageSeenUser alloc]initWithDictionary:seenUser];
                        [seenModalArray addObject:obj];
                        [seenMessages addObject:seenUser];
                    }
                    seenBy.lastMessageId = [NSString stringWithFormat:@"%d",j-1];
                    count++;
                }
            }
        }
    }
    
    NSLog(@"%d",count);
    return seenModalArray;
}



@end
