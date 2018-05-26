//
//  NSString+hex.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 24/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "NSString+hex.h"

@implementation NSString (hex)

+ (NSString *) stringToHex:(NSString *)str
{
    NSUInteger len = [str length];
    unichar *chars = malloc(len * sizeof(unichar));
    [str getCharacters:chars];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
    {
        [hexString appendString:[NSString stringWithFormat:@"%x", chars[i]]];
    }
    free(chars);
    
    return hexString;
}
@end
