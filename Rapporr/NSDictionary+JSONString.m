//
//  NSDictionary+JSONString.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 26/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "NSDictionary+JSONString.h"

@implementation NSDictionary (JSONString)

-(NSString*)jsonString{
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&err];
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", err.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}


+(NSDictionary *)dictionaryFromString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return json;
}


@end
