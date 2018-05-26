//
//  ConversationUser.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 12/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BaseEntity.h"
#import "MessageSeenUser.h"


@interface ConversationUser : BaseEntity

@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *fName;
@property (strong, nonatomic) NSString *isRegistered;
@property (strong, nonatomic) NSString *lName;
@property (strong, nonatomic) NSString *fullId;
@property (strong, nonatomic) NSString *lastSeen;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *objects;
@property (strong, nonatomic) NSString *org;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *pin;
@property (strong, nonatomic) NSString *smsRecieved;
@property (strong, nonatomic) NSString *timeStamp;
@property (strong, nonatomic) NSString *uType;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *jobTitle;
@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) MessageSeenUser* seen;

@property (nonatomic) BOOL isAdmin;
@property (nonatomic) BOOL deleted;
@property (nonatomic) BOOL disabled;






@property (strong, nonatomic) UIImage *avatarImage;
@property BOOL isSelected;
- (id)initWithManagedObject:(NSManagedObject *) conversationUserObj;
- (id)initWithDictionary:(NSDictionary *) responseData;



@end
