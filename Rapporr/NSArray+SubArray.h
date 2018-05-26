//
//  NSArray+SubArray.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 29/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSArray (SubArray)

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)removeDuplicatesFromArrayOnProperty:(NSString *)lastMessageId andUserId:(NSString *)userId;
- (NSArray *)reversedArray;

@end
