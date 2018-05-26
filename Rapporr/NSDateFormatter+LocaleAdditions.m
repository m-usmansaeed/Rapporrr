//
//  NSDateFormatter+LocaleAdditions.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 19/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "NSDateFormatter+LocaleAdditions.h"

@implementation NSDateFormatter (LocaleAdditions)

- (id)initWithPOSIXLocaleAndFormat:(NSString *)formatString {
    self = [super init];
    if (self) {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [self setLocale:locale];
        [self setDateFormat:formatString];
    }
    return self;
}

@end
