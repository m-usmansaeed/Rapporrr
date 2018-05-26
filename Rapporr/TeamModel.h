//
//  TeamModel.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 25/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "BaseEntity.h"
#import "ConversationUser.h"

typedef enum TeamStatus : NSUInteger {
    kTeamActive,
    kTeamInactive
} TeamStatus;


@interface TeamModel : BaseEntity

@property (nonatomic) BOOL isActive;
@property (strong, nonatomic) NSString *callBackId;
@property (strong, nonatomic) NSString *gType;
@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSString *hostId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *usersIdArray;
@property (strong, nonatomic) NSMutableArray <ConversationUser *>*members;
@property (strong, nonatomic) NSString *membersListString;
@property (strong, nonatomic) NSString *usersString;
@property (strong, nonatomic) NSString *orgId;
@property (strong, nonatomic) NSString *publicID;
@property (strong, nonatomic) NSString *recType;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *timeStamp;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) UIImage *image;

@property (nonatomic) TeamStatus teamStatus;

@property (nonatomic) BOOL isSelected;

- (id)initWithDictionary:(NSDictionary *) responseData;
- (id)initWithManagedObject:(NSManagedObject *) teamObject;
-(NSString *)getTeamUsers:(NSMutableArray *)array team:(TeamModel *)team;








@end
