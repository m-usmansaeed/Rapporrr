//
//  Utils.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 18/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface Utils : NSObject

typedef enum ListType : NSUInteger {
    kContacts,
    kExternal,
    kMyTeams,
    kAllTeams
} ListType;

typedef enum CONTENTType : NSUInteger {
    kCONTENTTypeTable,
    kCONTENTTypeCollection
} CONTENTType;


typedef void(^Completion)(BOOL finished);

+ (BOOL)validateEmail:(NSString *)candidate;
+ (NSData*)encodeDictionary:(NSDictionary*)dictionary;
+ (NSString*)getTelephonicCountryCode:(NSString *)countryCode;
+ (UIAlertController *) showCustomAlert:(NSString *) title andMessage : (NSString *) message;
+ (NSString *) dateDifference:(NSDate *)date;
+ (NSMutableArray*) getTableViewSectionByDates;
+ (NSMutableArray*) getConversationTableViewSectionByDates;
+ (BOOL) isDateofSameDay : (NSDate*) date1 andDate2 : (NSDate*) date2;
+ (NSDate*) getStartDateOfWeek;
+ (NSDate* ) getStartOfLastWeek;
+ (NSDate* ) getStartOfThisMonth;
+ (NSDate* ) getStartOfLastMonth;
+ (NSString*) getTableViewHeaderForDate : (NSDate*) tempDate;

+(void)prepareSearchBarUI:(UISearchBar *)searchBar;
+(NSDictionary *)dictionaryFromJson:(NSString *)json;
+(NSString *)jsonFromArray:(NSArray *)array;
+ (NSArray *)arrayFromJson:(NSString *) json;
+ (NSArray *)arrayFromString:(NSString *) str;

+ (NSString*) getInitialsFromString :(NSString*) fullString;
+(NSString *)getAccessWebConsole:(int)length;

+ (void)moveViewPosition:(CGFloat)yPostition onView:(UIView *)view completion:(Completion) completion;

+(int)getRandomNumber;
+(void)saveImage:(UIImage*)image;
+(UIImage*)loadImage;
+(void)saveUrlAndHubName:(NSString *)name hubname:(NSString *)hubname;
+(BOOL)hasCachedImage;
-(CGSize)frameSizeForAttributedString:(NSAttributedString *)attributedString;


@end
