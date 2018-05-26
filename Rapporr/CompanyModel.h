//
//  CompanyModel.h
//  Rapporr
//
//  Created by Rapporr-Dev-AS on 21/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEntity.h"

@interface CompanyModel : BaseEntity

@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *hostID;

- (id)initWithDictionary:(NSDictionary *) responseData;

@end
