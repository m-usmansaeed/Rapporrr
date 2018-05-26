//
//  ContactModel.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 3/6/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "ContactModel.h"

@implementation ContactModel
- (id)initWithDictionary:(NSDictionary *) responseData
{
    self = [super init];
    
    if (self) {
        self.phone = [self validStringForObject:responseData[@"phone"]];
        self.title =[self validStringForObject:responseData[@"title"]];
        self.category = [self validStringForObject:responseData[@"category"]];
        self.contentType =[self validStringForObject:responseData[@"contentType"]];
    }
    return self;
}
@end
