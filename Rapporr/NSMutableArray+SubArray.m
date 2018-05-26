//
//  NSMutableArray+SubArray.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 29/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "NSMutableArray+SubArray.h"

@implementation NSMutableArray (SubArray)

- (void)addObject:(id)anObject toSubarrayAtIndex:(NSUInteger)idx
{
    while ([self count] <= idx) {
        [self addObject:[NSMutableArray array]];
    }
    [[self objectAtIndex:idx] addObject:anObject];
}

- (BOOL)isContainsDictionary:(NSDictionary *)dict;
{
    BOOL exist = NO;
    for (NSDictionary *aDict in self) {
        if ([[aDict objectForKey:@"LastMessageId"] isEqualToString:[dict objectForKey:@"LastMessageId"]] && [[dict objectForKey:@"UserId"] isEqualToString:[aDict objectForKey:@"UserId"]]) {
            exist = YES;
            break;
        }
    }
    
    return exist;
}

@end
