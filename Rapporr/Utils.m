//
//  Utils.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 18/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "Utils.h"
#import "NSDate+NKLocalizedWeekday.h"
#import "RKDropdownAlert.h"

static const CGFloat kFontResizingProportion = 0.42f;
@implementation Utils

+(UIAlertController *) showCustomAlert:(NSString *) title andMessage : (NSString *) message {
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Okay"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
//    UIAlertAction* noButton = [UIAlertAction
//                               actionWithTitle:@"Cancel"
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction * action) {
//                                   //Handle no, thanks button
//                               }];
    
    [alert addAction:yesButton];
    //[alert addAction:noButton];
    
    return alert;
    
}

+ (BOOL)validateEmail:(NSString *)candidate {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

+ (NSString*)getTelephonicCountryCode:(NSString *)countryCode {
    NSDictionary *countryCodeDict = [self getCountryCodeDictionary];
    NSString *telephonicCode = [countryCodeDict objectForKey:countryCode];
    telephonicCode = [NSString stringWithFormat:@"+%@",telephonicCode];
    
    return telephonicCode;
    
}

+ (NSDictionary *)getCountryCodeDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
            @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
            @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
            @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
            @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
            @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
            @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
            @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
            @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
            @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
            @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
            @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
            @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
            @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
            @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
            @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
            @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
            @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
            @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
            @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
            @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
            @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
            @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
            @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
            @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
            @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
            @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
            @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
            @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
            @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
            @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
            @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
            @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
            @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
            @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
            @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
            @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
            @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
            @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
            @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
            @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
            @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
            @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
            @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
            @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
            @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
            @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
            @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
            @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
            @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
            @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
            @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
            @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
            @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
            @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
            @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
            @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
            @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
            @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
            @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
            @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
}

#pragma mark - Server Communication Helpher Method
+ (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}



+ (NSString *) dateDifference:(NSDate *)date
{
    const NSTimeInterval secondsPerDay = 60 * 60 * 24;
    NSTimeInterval diff = [date timeIntervalSinceNow] * -1.0;
    
    diff /= secondsPerDay;
    
    if (diff < 1)
        return @"Today";
    else if (diff < 2)
        return @"Yesterday";
    else if (diff < 8)
        return @"Last week";
    else
        return [date description]; // use a date formatter if necessary
}

+ (BOOL) isDateofSameDay : (NSDate*) date1 andDate2 : (NSDate*) date2 {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps1 = [cal components:(NSMonthCalendarUnit| NSYearCalendarUnit | NSDayCalendarUnit)
                                      fromDate:date1];
    NSDateComponents *comps2 = [cal components:(NSMonthCalendarUnit| NSYearCalendarUnit | NSDayCalendarUnit)
                                      fromDate:date2];
    
    
    BOOL sameDay = ([comps1 day] == [comps2 day]
                    && [comps1 month] == [comps2 month]
                    && [comps1 year] == [comps2 year]);
    
    return sameDay;
}

+ (NSString*) getTableViewHeaderForDate : (NSDate*) tempDate {
    
    NSDate *today = [NSDate date];
    NSDate *thisWeek  = [self getStartDateOfWeek];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    
    NSMutableArray *daysOfThisWeek = [self getDatesBetweenTwoDates:thisWeek andEndDate:[yesterday dateByAddingTimeInterval: -86400.0]];
    
    if([[NSCalendar currentCalendar] isDateInToday:tempDate]) {
        return @"Today";
    }
    else if([[NSCalendar currentCalendar] isDateInYesterday:tempDate]) {
        return @"Yesterday";
    }
    else {
        for(int i=0; i<daysOfThisWeek.count; i++) {
            NSDate *dateFromArray = [daysOfThisWeek objectAtIndex:i];
            if([[NSCalendar currentCalendar] isDate:dateFromArray inSameDayAsDate:tempDate]) {
                return [self getWeekDayForDate:tempDate];
            }
        }
    }
    
    
    
    return nil;
}

+ (NSMutableArray*) getConversationTableViewSectionByDates {
    
    NSMutableArray *headerDates = [[NSMutableArray alloc] init];
    NSDate *today = [NSDate date];
    
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    NSDate *thisWeek  = [self getStartDateOfWeek];
    NSDate *lastWeek  = [self getStartOfLastWeek];
    
    if([self isDateofSameDay:today andDate2:thisWeek]) {
        NSMutableDictionary *headersDictionaryToday = [[NSMutableDictionary alloc] init];
        [headersDictionaryToday setObject:today forKey:@"date"];
        [headersDictionaryToday setObject:@"Today" forKey:@"day"];
        [headerDates addObject: headersDictionaryToday];
    }
    else if([self isDateofSameDay:yesterday andDate2:thisWeek]) {
        
        NSMutableDictionary *headersDictionaryToday = [[NSMutableDictionary alloc] init];
        [headersDictionaryToday setObject:today forKey:@"date"];
        [headersDictionaryToday setObject:@"Today" forKey:@"day"];
        [headerDates addObject: headersDictionaryToday];
        
        NSMutableDictionary *headersDictionaryYesterday = [[NSMutableDictionary alloc] init];
        [headersDictionaryYesterday setObject:yesterday forKey:@"date"];
        [headersDictionaryYesterday setObject:@"Yesterday" forKey:@"day"];
        [headerDates addObject: headersDictionaryYesterday];
        
    }
    else {
        NSMutableDictionary *headersDictionaryToday = [[NSMutableDictionary alloc] init];
        [headersDictionaryToday setObject:today forKey:@"date"];
        [headersDictionaryToday setObject:@"Today" forKey:@"day"];
        [headerDates addObject: headersDictionaryToday];
        
        NSMutableDictionary *headersDictionaryYesterday = [[NSMutableDictionary alloc] init];
        [headersDictionaryYesterday setObject:yesterday forKey:@"date"];
        [headersDictionaryYesterday setObject:@"Yesterday" forKey:@"day"];
        [headerDates addObject: headersDictionaryYesterday];
        
        
        NSMutableArray *daysOfThisWeek = [self getDatesBetweenTwoDates:thisWeek andEndDate:[yesterday dateByAddingTimeInterval: -86400.0]];
        
        daysOfThisWeek = [[[daysOfThisWeek reverseObjectEnumerator] allObjects] mutableCopy];
        
        for(int i=0; i<daysOfThisWeek.count; i++) {
            NSDate *tempDate = [daysOfThisWeek objectAtIndex:i];
            
            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
            [tempDictionary setObject:tempDate forKey:@"date"];
            [tempDictionary setObject:[self getWeekDayForDate:tempDate] forKey:@"day"];
            [headerDates addObject: tempDictionary];
        }
    }
    
    NSMutableDictionary *headersDictionaryLastWeek = [[NSMutableDictionary alloc] init];
    [headersDictionaryLastWeek setObject:lastWeek forKey:@"date"];
    [headersDictionaryLastWeek setObject:@"Last Week" forKey:@"day"];
    [headerDates addObject: headersDictionaryLastWeek];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *older = [cal dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:lastWeek options:0];
    
    NSMutableDictionary *headersDictionaryThisMonth = [[NSMutableDictionary alloc] init];
    [headersDictionaryThisMonth setObject:older forKey:@"date"];
    [headersDictionaryThisMonth setObject:@"Older Conversations" forKey:@"day"];
    [headerDates addObject: headersDictionaryThisMonth];
    
    return headerDates;
}


+ (NSMutableArray*) getTableViewSectionByDates {
    
    NSMutableArray *headerDates = [[NSMutableArray alloc] init];
    NSDate *today = [NSDate date];
    
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    NSDate *thisWeek  = [self getStartDateOfWeek];
    NSDate *lastWeek  = [self getStartOfLastWeek];
    
    if([self isDateofSameDay:today andDate2:thisWeek]) {
        NSMutableDictionary *headersDictionaryToday = [[NSMutableDictionary alloc] init];
        [headersDictionaryToday setObject:today forKey:@"date"];
        [headersDictionaryToday setObject:@"Today" forKey:@"day"];
        [headerDates addObject: headersDictionaryToday];
    }
    else if([self isDateofSameDay:yesterday andDate2:thisWeek]) {
        
        NSMutableDictionary *headersDictionaryToday = [[NSMutableDictionary alloc] init];
        [headersDictionaryToday setObject:today forKey:@"date"];
        [headersDictionaryToday setObject:@"Today" forKey:@"day"];
        [headerDates addObject: headersDictionaryToday];
        
        NSMutableDictionary *headersDictionaryYesterday = [[NSMutableDictionary alloc] init];
        [headersDictionaryYesterday setObject:yesterday forKey:@"date"];
        [headersDictionaryYesterday setObject:@"Yesterday" forKey:@"day"];
        [headerDates addObject: headersDictionaryYesterday];
        
    }
    else {
        NSMutableDictionary *headersDictionaryToday = [[NSMutableDictionary alloc] init];
        [headersDictionaryToday setObject:today forKey:@"date"];
        [headersDictionaryToday setObject:@"Today" forKey:@"day"];
        [headerDates addObject: headersDictionaryToday];
        
        NSMutableDictionary *headersDictionaryYesterday = [[NSMutableDictionary alloc] init];
        [headersDictionaryYesterday setObject:yesterday forKey:@"date"];
        [headersDictionaryYesterday setObject:@"Yesterday" forKey:@"day"];
        [headerDates addObject: headersDictionaryYesterday];
        
        
        NSMutableArray *daysOfThisWeek = [self getDatesBetweenTwoDates:thisWeek andEndDate:[yesterday dateByAddingTimeInterval: -86400.0]];
        
        daysOfThisWeek = [[[daysOfThisWeek reverseObjectEnumerator] allObjects] mutableCopy];
        
        for(int i=0; i<daysOfThisWeek.count; i++) {
            NSDate *tempDate = [daysOfThisWeek objectAtIndex:i];
            
            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
            [tempDictionary setObject:tempDate forKey:@"date"];
            [tempDictionary setObject:[self getWeekDayForDate:tempDate] forKey:@"day"];
            [headerDates addObject: tempDictionary];
        }
    }
    
    NSMutableDictionary *headersDictionaryLastWeek = [[NSMutableDictionary alloc] init];
    [headersDictionaryLastWeek setObject:lastWeek forKey:@"date"];
    [headersDictionaryLastWeek setObject:@"Last Week" forKey:@"day"];
    [headerDates addObject: headersDictionaryLastWeek];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *older = [cal dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:lastWeek options:0];
    
    NSMutableDictionary *headersDictionaryThisMonth = [[NSMutableDictionary alloc] init];
    [headersDictionaryThisMonth setObject:older forKey:@"date"];
    [headersDictionaryThisMonth setObject:@"Older Conversations" forKey:@"day"];
    [headerDates addObject: headersDictionaryThisMonth];
    
    return headerDates;
}

+ (NSDate*) getStartDateOfWeek {
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:today];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    
    [componentsToSubtract setDay: - ([weekdayComponents weekday] - [gregorian firstWeekday])];
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
    
    NSDateComponents *components = [gregorian components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                fromDate: beginningOfWeek];
    beginningOfWeek = [gregorian dateFromComponents: components];
    
    return beginningOfWeek;
}

+ (NSDate* ) getStartOfThisMonth {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    components.day = 1;
    NSDate *firstDayOfMonthDate = [[NSCalendar currentCalendar] dateFromComponents: components];
    
    return firstDayOfMonthDate;

}

+ (NSDate* ) getStartOfLastWeek {
    return [[self getStartDateOfWeek] dateByAddingTimeInterval: -7*24*60*60];
    
}




+ (NSDate* ) getStartOfLastMonth {
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    components.day = 1;
    components.month = components.month-1;
    
    if(components.month < 1){
        components.month = 12;
        components.year = components.year-1;
    }
    
    NSDate *firstDayOfMonthDate = [[NSCalendar currentCalendar] dateFromComponents: components];
    
    return firstDayOfMonthDate;
    
}

+ (NSString*) getWeekDayForDate : (NSDate*) date {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:date];
    int weekdayNumber = (int)[components weekday];
    NSDateFormatter *formatter = [NSDateFormatter defaultDateManager];
    NSString *weekdayString = [[formatter weekdaySymbols] objectAtIndex:weekdayNumber - 1];
    
    return weekdayString;
}

+ (NSMutableArray*) getDatesBetweenTwoDates :(NSDate*) startDate andEndDate :(NSDate*) endDate {
    
    NSMutableArray *dates = [@[startDate] mutableCopy];
    
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:0];
    
    for (int i = 1; i < components.day; ++i) {
        NSDateComponents *newComponents = [NSDateComponents new];
        newComponents.day = i;
        
        NSDate *date = [gregorianCalendar dateByAddingComponents:newComponents
                                                          toDate:startDate
                                                         options:0];
        [dates addObject:date];
    }
    
    [dates addObject:endDate];
    
    return dates;
}

+(void)prepareSearchBarUI:(UISearchBar *)searchBar
{
    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"search"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    for (UIView *subview in searchBar.subviews) {
        for (UIView *sv in subview.subviews) {
            if ([NSStringFromClass([sv class]) isEqualToString:@"UISearchBarTextField"]) {
                
                if ([sv respondsToSelector:@selector(setAttributedPlaceholder:)]) {
                    ((UITextField *)sv).attributedPlaceholder = [[NSAttributedString alloc] initWithString:searchBar.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorFromHexCode:@"#6D6E70"]}];
                }
                break;
            }
        }
    }
    
    for ( UIView *v in [searchBar.subviews.firstObject subviews] )
    {
        if ( YES == [v isKindOfClass:[UITextField class]] )
        {
            [((UITextField*)v) setTintColor:App_OrangeColor];
            break;
        }
    }
        
    CGSize size = CGSizeMake(30, 28);
    // create context with transparent background
    UIGraphicsBeginImageContextWithOptions(size, NO, 1);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,0,30,30)
                                cornerRadius:2.0] addClip];
    [[UIColor colorFromHexCode:@"#F7F7F7"] setFill];
    
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    [searchBar setSearchFieldBackgroundImage:image forState:UIControlStateNormal];
    [searchBar setBackgroundColor:[UIColor colorFromHexCode:@"#F7F7F7"]];
    searchBar.enablesReturnKeyAutomatically = NO;

}



+(NSDictionary *)dictionaryFromJson:(NSString *)json{
    
    NSError *jsonError;
    NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    NSLog(@"%@",dict);
    
    return dict;
}

+ (NSArray *)arrayFromJson:(NSString *) json {
    NSError* error;
    NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:objectData options: NSJSONReadingMutableContainers error: &error];
    
    return jsonArray;
}

+ (NSArray *)arrayFromString:(NSString *) str {
    str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSArray *items = [str componentsSeparatedByString:@","];
    
    return items;
}

+(NSString *)jsonFromArray:(NSArray *)array
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}


+ (void)moveViewPosition:(CGFloat)yPostition onView:(UIView *)view completion:(Completion) completion;
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [view setFrame:CGRectMake(view.frame.origin.x, yPostition, view.frame.size.width, view.frame.size.height)];
    [UIView commitAnimations];
    completion(YES);
    
}

+(int)getRandomNumber{
    return (int)1 + arc4random() % (999999-1+1);
}

+ (NSString*) getInitialsFromString :(NSString*) fullString {
    
    NSDictionary *textAttributes;
    
    if (!textAttributes) {
        textAttributes = @{
                           NSFontAttributeName: [self fontForFontName:nil],
                           NSForegroundColorAttributeName: [UIColor whiteColor]
                           };
    }
    
    NSMutableString *displayString = [NSMutableString stringWithString:@""];
    
    NSMutableArray *words = [[fullString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
    
    if ([words count]) {
        NSString *firstWord = [words firstObject];
        if ([firstWord length]) {
            // Get character range to handle emoji (emojis consist of 2 characters in sequence)
            NSRange firstLetterRange = [firstWord rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 1)];
            [displayString appendString:[firstWord substringWithRange:firstLetterRange]];
        }
        
        if ([words count] >= 2) {
            NSString *lastWord = [words lastObject];
            
            while ([lastWord length] == 0 && [words count] >= 2) {
                [words removeLastObject];
                lastWord = [words lastObject];
            }
            
            if ([words count] > 1) {
                // Get character range to handle emoji (emojis consist of 2 characters in sequence)
                NSRange lastLetterRange = [lastWord rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 1)];
                [displayString appendString:[lastWord substringWithRange:lastLetterRange]];
            }
        }
    }

    return [displayString uppercaseString];
}

+ (UIFont *)fontForFontName:(NSString *)fontName {
    
    CGFloat fontSize = 35 * kFontResizingProportion;
    if (fontName) {
        return [UIFont fontWithName:fontName size:fontSize];
    }
    else {
        return [UIFont systemFontOfSize:fontSize];
    }
    
}

+(NSString *)getAccessWebConsole:(int)length{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    return randomString;
}

+(void)saveImage: (UIImage*)image
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:@"profile.png" ];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}

+(BOOL)hasCachedImage{
    UIImage *profileImage = [Utils loadImage];
    CGImageRef cgref = [profileImage CGImage];
    CIImage *cim = [profileImage CIImage];
    if (cim == nil && cgref == NULL)
    {
        NSLog(@"no underlying data");
        return NO;
    }
    else{
        return YES;
    }
}


+(UIImage*)loadImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      @"profile.png" ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

+(void)saveUrlAndHubName:(NSString *)url hubname:(NSString *)hubname{
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"urlKey"];
    [[NSUserDefaults standardUserDefaults] setObject:hubname forKey:@"hubName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
