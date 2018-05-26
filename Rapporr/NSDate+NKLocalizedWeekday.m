//
//  NSDate+NKLocalizedWeekday.m
//
//  Created by Nikola Kirev on 3/27/13.
//  Copyright (c) 2013 Nikola Kirev. All rights reserved.
//



#import "NSDate+NKLocalizedWeekday.h"

@implementation NSDate (NKLocalizedWeekday)

#pragma mark - Class Methods

typedef NS_ENUM(NSUInteger, NKLocalizedWeekdayMode) {
    kNKLocalizedWeekdayModeVeryShort,
    kNKLocalizedWeekdayModeShort,
    kNKLocalizedWeekdayModeFull
};

+ (NSString *)veryShortLocalizedWeekdayStringForWeekday:(int)weekday {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    return [formatter veryShortWeekdaySymbols][weekday - 1];
}

+ (NSString *)shortLocalizedWeekdayStringForWeekday:(int)weekday {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    return [formatter shortWeekdaySymbols][weekday - 1];
}

+ (NSString *)fullLocalizedWeekdayStringForWeekday:(int)weekday {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    return [formatter weekdaySymbols][weekday - 1];
}

#pragma mark - Instance Methods

- (NSString *)veryShorttWeekdayString {
    return [self internalWeekdayStringForMode:kNKLocalizedWeekdayModeVeryShort];
}

- (NSString *)shortWeekdayString {
        return [self internalWeekdayStringForMode:kNKLocalizedWeekdayModeShort];
}

- (NSString *)weekdayString {
        return [self internalWeekdayStringForMode:kNKLocalizedWeekdayModeFull];
}

- (NSString *)weekdayStringFormattingRecentDaysWithYesterdayLocalizedIdentifier:(NSString *)yesterday
                                                    andTodayLocalizedIdentifier:(NSString *)today {
    NSString *dateString = @"";
    NSDate *now = [NSDate date];
    NSInteger interval = [NSDate daysBetweenDate:self andDate:now];
    if (interval == 0) {
        dateString = NSLocalizedString(today, nil);
    }else if (interval == 1) {
        dateString = NSLocalizedString(yesterday, nil);
    }else {
        return [self weekdayString];
    }
    return dateString;
}

#pragma mark - Helper Methods

+ (NSDate *)addDays:(NSInteger)days toDate:(NSDate *)originalDate {
    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setDay:days];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:components toDate:originalDate options:0];
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    NSDateComponents *differenceComponents = [calendar components:NSDayCalendarUnit
                                                         fromDate:fromDate
                                                           toDate:toDate
                                                          options:0];
    return [differenceComponents day];
}

#pragma mark - Internal Methods

- (NSString *)internalWeekdayStringForMode:(NKLocalizedWeekdayMode)mode {
    NSString *weekdayString = @"";
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    int weekdayNumber = [components weekday];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    switch (mode) {
        case kNKLocalizedWeekdayModeVeryShort:
            weekdayString = [[formatter veryShortWeekdaySymbols] objectAtIndex:weekdayNumber - 1];
            break;
        case kNKLocalizedWeekdayModeShort:
            weekdayString = [[formatter shortWeekdaySymbols] objectAtIndex:weekdayNumber - 1];
            break;
        case kNKLocalizedWeekdayModeFull:
            weekdayString = [[formatter weekdaySymbols] objectAtIndex:weekdayNumber - 1];
            break;
        default:
            weekdayString = [[formatter weekdaySymbols] objectAtIndex:weekdayNumber - 1];
            break;
    }
    return weekdayString;
}

+(NSDate *)getDateInCurrentSystemTimeZone
{
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    return destinationDate;
}

+(NSString *)getTimestampForCallBackId
{

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";
    NSTimeZone *gmtZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmtZone];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDate *dateFromString = [dateFormatter dateFromString:timeStamp];
    NSTimeInterval timeInMiliseconds = [dateFromString timeIntervalSince1970]*1000;
    
    NSString *intervalString = [NSString stringWithFormat:@"%.0f", timeInMiliseconds];

    return intervalString;
}

+ (NSString *)dateTimeForRapporr:(NSString *)timeStamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPosixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUSPosixLocale];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
    NSDate *dateFromMessage = [formatter dateFromString:timeStamp];
    NSString *dateTimeString = @"";
    
    NSDate *currentDate = [NSDate getDateInCurrentSystemTimeZone];
    
    NSInteger isSameDay = [NSDate daysBetweenDate:currentDate andDate:dateFromMessage];
    if(isSameDay >= -6) {
        [formatter setDateFormat:@"hh:mma"];
        dateTimeString = [formatter stringFromDate:dateFromMessage];
    }else{
        [formatter setDateFormat:@"MMM d"];
        dateTimeString = [formatter stringFromDate:dateFromMessage];
    }
    return dateTimeString;
}

+ (NSString *)dayForRapporr:(NSString *)timeStamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPosixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUSPosixLocale];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
    NSDate *dateFromMessage = [formatter dateFromString:timeStamp];
    NSString *dateTimeString = @"";
    
    [formatter setDateFormat:@"dd-MMM-yy"];
    dateTimeString = [formatter stringFromDate:dateFromMessage];
    
    return dateTimeString;
}

+ (NSString *)dateTimeForMessageDetail:(NSString *)timeStamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPosixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUSPosixLocale];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
    NSDate *dateFromMessage = [formatter dateFromString:timeStamp];
    if (dateFromMessage == nil) {
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSZ"];
    } dateFromMessage = [formatter dateFromString:timeStamp];

    NSString *dateTimeString = @"";
    NSString *dateStr = @"";
    NSString *timeStr = @"";
    [formatter setDateFormat:@"EEE-dd MMM yyyy"];
    dateStr = [formatter stringFromDate:dateFromMessage];
    [formatter setDateFormat:@"hh:mm a"];
    timeStr = [formatter stringFromDate:dateFromMessage];
    dateTimeString = [NSString stringWithFormat:@"%@ at %@",dateStr,timeStr];
    
    return dateTimeString;
}

+ (NSString *)dateTimeSeenUsers:(NSString *)timeStamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPosixLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUSPosixLocale];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSZ"];
    NSDate *dateFromMessage = [formatter dateFromString:timeStamp];
    if (dateFromMessage == nil) {
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
    }
    
    dateFromMessage = [formatter dateFromString:timeStamp];

    NSString *dateTimeString = @"";
    NSString *dateStr = @"";
    NSString *timeStr = @"";
    [formatter setDateFormat:@"EEE-dd MMM yyyy"];
    dateStr = [formatter stringFromDate:dateFromMessage];
    [formatter setDateFormat:@"hh:mm a"];
    timeStr = [formatter stringFromDate:dateFromMessage];
    dateTimeString = [NSString stringWithFormat:@"%@ at %@",dateStr,timeStr];
    
    return dateTimeString;
}


@end
