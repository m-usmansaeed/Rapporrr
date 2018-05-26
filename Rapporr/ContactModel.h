//
//  ContactModel.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 3/6/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "BaseEntity.h"

@interface ContactModel : BaseEntity
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *contentType;
- (id)initWithDictionary:(NSDictionary *) responseData;
@end
