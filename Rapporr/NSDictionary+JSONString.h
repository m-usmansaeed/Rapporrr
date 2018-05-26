//
//  NSDictionary+JSONString.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 26/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONString)

-(NSString*)jsonString;
+(NSDictionary *)dictionaryFromString:(NSString *)string;

@end
