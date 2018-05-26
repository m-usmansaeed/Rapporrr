//
//  CompanyModel.m
//  Rapporr
//
//  Created by Rapporr-Dev-AS on 21/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "CompanyModel.h"

@implementation CompanyModel

- (id)initWithDictionary:(NSDictionary *) responseData
{
    self = [super init];
    if (self) {
        self.companyName = [self validStringForObject:responseData[@"company"]];
        self.hostID =[self validStringForObject:responseData[@"hostId"]];
    }
    
    return self;
}

@end
