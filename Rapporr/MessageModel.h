//
//  MessageModel.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 07/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "BaseEntity.h"
#import "RPConverstionMessage.h"

@interface MessageModel : BaseEntity


@property (strong, nonatomic) NSString        *host;
@property (strong, nonatomic) NSString        *tags;
@property (strong, nonatomic) NSString        *about;
@property (strong, nonatomic) NSString        *create;
@property (strong, nonatomic) NSString        *lastMsg;
@property (strong, nonatomic) NSString        *timeStamp;
@property (strong, nonatomic) NSString        *lastMsgId;
@property (strong, nonatomic) NSString        *cTemplate;
@property (strong, nonatomic) NSString        *senderName;
@property (strong, nonatomic) NSString        *firstName;
@property (strong, nonatomic) NSString        *lastName;
@property (strong, nonatomic) NSString        *callBackId;
@property (strong, nonatomic) NSString        *startingUser;
@property (strong, nonatomic) NSString        *conversationId;
@property (strong, nonatomic) NSString        *lastMsgRecieved;
@property (strong, nonatomic) NSString        *unReadMsgsCount;
@property (strong, nonatomic) NSMutableArray  *users;
@property (strong, nonatomic) NSString  *objects;
@property (strong)            NSManagedObject *message;

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray <ConversationUser *>*members;

@property BOOL isPinned;
@property BOOL isArchieved;

- (id)initWithDictionary:(NSDictionary *) responseData;
- (id)initWithManagedObject:(NSManagedObject *) messageObj;
- (id)initWithNotificationDictionary:(NSDictionary *) responseData;
@end
