//
//  MessageSeenBy.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/1/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "BaseEntity.h"


@interface MessageSeenUser : BaseEntity

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *hostId;
@property (strong, nonatomic) NSString *lastMessageId;
@property (strong, nonatomic) NSString *orgId;
@property (strong, nonatomic) NSString *rType;
@property (strong, nonatomic) NSString *timeStamp;

+(NSMutableArray *)parseSeenMessages:(NSArray *)array forMessages:(NSMutableArray *)array;

- (id)initWithManagedObject:(NSManagedObject *) teamObject;
- (id)initWithDictionary:(NSDictionary *) responseData;

@end
