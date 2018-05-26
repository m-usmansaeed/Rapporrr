//
//  VerifiedCompanyModel.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 10/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "VerifiedCompanyModel.h"

@implementation VerifiedCompanyModel

- (id)initWithDictionary:(NSDictionary *) responseData
{
    self = [super init];
    if (self) {
        self.companyName = [self validStringForObject:responseData[@"CompanyName"]];
        self.expires =[self validStringForObject:responseData[@"Expires"]];
        self.hostID = [self validStringForObject:responseData[@"Host"]];
        self.orgId =[self validStringForObject:responseData[@"OrgId"]];
        self.token = [self validStringForObject:responseData[@"Token"]];
        self.uType =[self validStringForObject:responseData[@"UType"]];
        self.userId = [self validStringForObject:responseData[@"UserId"]];
        self.userName =[self validStringForObject:responseData[@"UserName"]];
    }
    
    return self;
}

- (id)initWithManagedObject:(NSManagedObject *) messageObj {
    self = [super init];
    if (self) {
        
        self.companyName = [messageObj valueForKey:@"companyName"];
        self.expires = [messageObj valueForKey:@"expires"];
        self.hostID = [messageObj valueForKey:@"hostID"];
        self.orgId = [messageObj valueForKey:@"orgId"];
        self.token = [messageObj valueForKey:@"token"];
        self.uType = [messageObj valueForKey:@"uType"];
        self.userId = [messageObj valueForKey:@"userId"];
        self.userName = [messageObj valueForKey:@"userName"];
        self.isActive = [NSNumber numberWithBool:[messageObj valueForKey:@"isActive"]];
        
    }
    return self;
}
@end
