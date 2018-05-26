//
//  NSString+email.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 27/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (email)
- (BOOL)isValidURL;
- (BOOL)isValidEmail;
- (BOOL) validateUrl: (NSString *) candidate;
+ (NSString*)validStringForObject:(NSString*)string;
- (BOOL)containsString:(NSString *)substring;



@end
