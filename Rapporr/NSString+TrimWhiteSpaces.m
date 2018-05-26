//
//  NSString+TrimWhiteSpaces.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/22/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "NSString+TrimWhiteSpaces.h"

@implementation NSString (TrimWhiteSpaces)

- (NSString *)stringByTrimingWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


@end
