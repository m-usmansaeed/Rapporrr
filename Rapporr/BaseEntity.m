//
//  BaseEntity.m
//  LawNote
//
//  Created by Samreen Noor on 22/07/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "BaseEntity.h"

@implementation BaseEntity

+ (id)entityName
{
    return NSStringFromClass(self);
}

- (NSString *) validStringForObject:(NSString *) object{
    
    if (![object isKindOfClass:[NSNull class]])
        return (NSString *)object;
    
    return @"";
    
}
- (NSNumber *) validNumberForObject:(NSString *) object{
    
    if (![object isKindOfClass:[NSNull class]])
        return object;
    
    return @"";
    
}

-(NSString *)completeImageURL:(NSString *)shortURL{
    
    
    if ([shortURL isKindOfClass:[NSNull class]])
        return @"";
    
    if ([shortURL hasPrefix:@"http"]) {
        return shortURL;
    }
    
    if (shortURL) {
        return [BASE_URL stringByAppendingString:shortURL];
    }
    return @"";
}



@end
