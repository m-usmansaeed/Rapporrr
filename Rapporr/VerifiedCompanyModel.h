//
//  VerifiedCompanyModel.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 10/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEntity.h"
#import <CoreData/CoreData.h>

@interface VerifiedCompanyModel : BaseEntity

@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *hostID;
@property (strong, nonatomic) NSString *expires;
@property (strong, nonatomic) NSString *orgId;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *uType;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userName;
@property (nonatomic) BOOL isActive;

- (id)initWithDictionary:(NSDictionary *) responseData;
- (id)initWithManagedObject:(NSManagedObject *) messageObj;
@end
