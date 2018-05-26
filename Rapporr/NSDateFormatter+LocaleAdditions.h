//
//  NSDateFormatter+LocaleAdditions.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 19/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreFoundation/CFDateFormatter.h>

@interface NSDateFormatter (LocaleAdditions)
- (id)initWithPOSIXLocaleAndFormat:(NSString *)formatString;

@end
