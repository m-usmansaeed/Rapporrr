//
//  NSMutableArray+SubArray.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 29/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (SubArray)
- (void)addObject:(id)anObject toSubarrayAtIndex:(NSUInteger)idx;

- (BOOL)isContainsDictionary:(NSDictionary *)dict;


@end
