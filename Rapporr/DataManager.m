//
//  DataManager.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 20/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "DataManager.h"
#import "Constants.h"
#import "NSString+hex.h"
#import "NSData+NSData_Conversion.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation DataManager
static DataManager *sharedManager;

+ (DataManager *) sharedManager
{
    if(sharedManager == nil)
    {
        sharedManager = [[DataManager alloc] init];
        sharedManager.authToken         = @"";
    }
    
    return sharedManager;
}

+ (NSString*) generateSignature : (NSString*) urlStr {
    
    const char* str = [urlStr UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }

    
    return ret;
}

+ (NSString*) createNewHostFor : (NSString*) organisationName {
    
    NSString *hostID = @"";
    for (int x = 0; x < organisationName.length; x++) {
        char character = [organisationName characterAtIndex:x];
        BOOL isValidChar = false;
        
        if(character >=48 && character<= 57) {
            isValidChar = true;
        }
        else if(character >=65 && character<= 90) {
            isValidChar = true;
        }
        else if(character >=97 && character<= 122) {
            isValidChar = true;
        }
        
        if(isValidChar) {
            hostID = [NSString stringWithFormat:@"%@%c",hostID,[organisationName characterAtIndex:x]];
        }
        
        if (hostID.length > 8) {
            x = organisationName.length;
        }
    }
    NSString * timeInMS = [NSString stringWithFormat:@"%lld", [@(floor(([[NSDate date] timeIntervalSince1970] * 1000)/60000)-24000000) longLongValue]];

    hostID = [NSString stringWithFormat:@"%@%@",hostID,timeInMS];
    return hostID;
}

+ (NSString*) createAuthHeader : (NSString*) userId andHostId : (NSString*) hostId {
    
    NSString *timeInMS = [NSString stringWithFormat:@"%lld", [@(floor(([[NSDate date] timeIntervalSince1970] * 1000)/60000)-24000000) longLongValue]];
    
    NSString *uname = [NSString stringWithFormat:@"%@.%@.%@",timeInMS,hostId,userId];
    NSString *device = RAPPORR_API_KEY;
    
    uname = [NSString stringWithFormat:@"D%@",uname];
    
    NSString *tempPass = [NSString stringWithFormat:@"%@%@%@",uname,RAPPORR_API_KEY,device];
    tempPass = [self generateSignature:tempPass];
    
    NSString *pass = [tempPass lowercaseString];
    
    NSString *secret = [NSString stringWithFormat:@"%@:%@",uname,pass];
    
    secret = [self encodeStringTo64:secret];
    
    NSString *authStr = [NSString stringWithFormat:@"Basic %@",secret];
    authStr = [authStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    authStr = [authStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return authStr;
}



#pragma mark - helper methods 

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
+ (NSString*)encodeStringTo64:(NSString*)fromString
{
    NSData *plainData = [fromString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String;
    if ([plainData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        base64String = [plainData base64EncodedStringWithOptions:kNilOptions];  // iOS 7+
    } else {
        base64String = [plainData base64Encoding];                              // pre iOS7
    }
    
    return base64String;
}

@end
