//
//  NSDateFormatter+Locale.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/20/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "NSDateFormatter+Locale.h"

@implementation NSDateFormatter (Locale)

+ (instancetype)defaultDateManager
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dateFormatter   = [[NSDateFormatter alloc] init];
    });
    
    return dateFormatter;
}

@end
