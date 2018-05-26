//
//  MessageModel.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 07/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel

@synthesize about,cTemplate,callBackId,conversationId,create,host,lastMsg,lastMsgId,lastMsgRecieved,senderName,startingUser,tags,timeStamp,users,objects,isPinned,isArchieved;


-(instancetype)init
{
    self = [super init];
    if (self) {
        self.messages = [[NSMutableArray alloc]init];
        self.members = [[NSMutableArray alloc]init];
        self.users  = [[NSMutableArray alloc]init];
    }

    return self;
}

- (id)initWithNotificationDictionary:(NSDictionary *) responseData
{
//    NSLog(@"%@",responseData);
    self = [super init];
    
    if (self) {
        
        NSString *strTemp = [NSString validStringForObject:responseData[@"messageId"]];
        if(strTemp.length>1) {
            NSString *tempConversationID = [strTemp componentsSeparatedByString:@"/"][0];
            NSString *tempMessageID = [strTemp componentsSeparatedByString:@"/"][1];
            
            NSDateFormatter *dateFormatter = [NSDateFormatter defaultDateManager];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ";
            NSTimeZone *gmtZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
            [dateFormatter setTimeZone:gmtZone];
            
            NSString *timeStampStr = [dateFormatter stringFromDate:[NSDate date]];
            
            self.messages = [[NSMutableArray alloc] init];
            self.members = [[NSMutableArray alloc] init];
            
            self.callBackId = [self validStringForObject:responseData[@"callbackid"]];
            self.conversationId = tempConversationID;
            self.host =[self validStringForObject:responseData[@"host"]];
            self.lastMsg = [self validStringForObject:responseData[@"body"]];
            self.lastMsgId = tempMessageID;
            self.lastMsgRecieved = timeStampStr;
            self.senderName =[self validStringForObject:responseData[@"senderName"]];
            self.startingUser = [self validStringForObject:responseData[@"userId"]];
            self.timeStamp = timeStamp;
            self.unReadMsgsCount = @"0";
            self.objects = responseData[@"objects"];
        }
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *) responseData
{
//    NSLog(@"%@",responseData);
    self = [super init];
   
    if (self) {
        
        self.messages = [[NSMutableArray alloc] init];
        self.members = [[NSMutableArray alloc] init];
        self.about = [self validStringForObject:responseData[@"About"]];
        self.cTemplate =[self validStringForObject:responseData[@"CTemplate"]];
        self.callBackId = [self validStringForObject:responseData[@"CallBackid"]];
        self.conversationId =[self validStringForObject:responseData[@"ConversationId"]];
        self.create = [self validStringForObject:responseData[@"Create"]];
        self.host =[self validStringForObject:responseData[@"Host"]];
        self.lastMsg = [self validStringForObject:responseData[@"LastMessage"]];
        self.lastMsgId =[self validStringForObject:responseData[@"LastMessageId"]];
        self.lastMsgRecieved = [self validStringForObject:responseData[@"LastMessageReceived"]];
        self.senderName =[self validStringForObject:responseData[@"SenderName"]];
        self.startingUser = [self validStringForObject:responseData[@"StartingUser"]];
        self.tags =[self validStringForObject:responseData[@"Tags"]];
        self.timeStamp =[self validStringForObject:responseData[@"TimeStamp"]];
        self.unReadMsgsCount = @"0";
        self.users = responseData[@"Users"];
        self.objects = responseData[@"Objects"];
        NSArray *noDuplicateUsers = [users valueForKeyPath:@"@distinctUnionOfObjects.self"];
        self.users = [noDuplicateUsers mutableCopy];
        
        NSArray *namesArray = [self.senderName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        
        if ([namesArray count]) {
            self.firstName = [namesArray objectAtIndex:0];
            if ([namesArray count]> 1) {
                self.lastName = [namesArray objectAtIndex:1];
            }
        }
    }
    
    return self;
}


- (id)initWithManagedObject:(NSManagedObject *) messageObj {
    
    self = [super init];
    if (self) {
        
        self.messages = [[NSMutableArray alloc] init];
        self.members = [[NSMutableArray alloc] init];
        self.isPinned = [[messageObj valueForKey:@"isPinned"] boolValue];
        self.isArchieved = [[messageObj valueForKey:@"isArchieved"] boolValue];
        self.about = [messageObj valueForKey:@"about"];
        self.cTemplate =[messageObj valueForKey:@"cTemplate"];
        self.callBackId = [messageObj valueForKey:@"callBackId"];
        self.conversationId =[messageObj valueForKey:@"conversationId"];
        self.create = [messageObj valueForKey:@"create"];
        self.host = [messageObj valueForKey:@"host"];
        self.lastMsg = [messageObj valueForKey:@"lastMsg"];
        self.lastMsgId = [messageObj valueForKey:@"lastMsgId"];
        self.lastMsgRecieved = [messageObj valueForKey:@"lastMsgRecieved"];
        self.senderName = [messageObj valueForKey:@"senderName"];
        self.firstName = [messageObj valueForKey:@"firstName"];
        self.lastName = [messageObj valueForKey:@"lastName"];
        self.startingUser = [messageObj valueForKey:@"startingUser"];
        self.tags = [messageObj valueForKey:@"tags"];
        self.timeStamp = [messageObj valueForKey:@"timeStamp"];
        self.users = [messageObj valueForKey:@"users"];
        self.objects = [messageObj valueForKey:@"objects"];
        self.unReadMsgsCount = [messageObj valueForKey:@"unreadMsgsCount"];
        self.message = messageObj;
        
        if ([self.users count]) {
            for (NSString *userId in self.users) {
                ConversationUser *user = [[CoreDataController sharedManager] getUserWithID:userId];
                if (user) {
                    [self.members addObject:user];
                }
            }
        }
        
        NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                                ascending:YES
                                                                 selector:@selector(caseInsensitiveCompare:)];
        
        self.members = [[self.members sortedArrayUsingDescriptors:@[sort]] mutableCopy];

    }
    
    return self;
}




@end
