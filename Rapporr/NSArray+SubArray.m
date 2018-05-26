//
//  NSArray+SubArray.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 29/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "NSArray+SubArray.h"

@implementation NSArray (SubArray)

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
}


- (NSArray *)removeDuplicatesFromArrayOnProperty:(NSString *)lastMessageId andUserId:(NSString *)userId {
    
    NSArray *workingCopy = [NSArray arrayWithArray:self];
    NSMutableArray *mutableCopy = [NSMutableArray arrayWithArray:[self mutableCopy]];

    for (int i = 0; i < [workingCopy count] - 1; i++) {
        for (int j = i+1; j < [workingCopy count]; j++) {
            if ([[[workingCopy objectAtIndex:i] objectForKey:@"LastMessageId"] isEqualToString: [[workingCopy objectAtIndex:j] objectForKey:@"LastMessageId"]] && [[[workingCopy objectAtIndex:i] objectForKey:@"UserId"] isEqualToString: [[workingCopy objectAtIndex:j] objectForKey:@"UserId"]]) {
                [mutableCopy removeObject:[workingCopy objectAtIndex:i]];
            }
        }
    }
    
    return mutableCopy;
}


- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end
