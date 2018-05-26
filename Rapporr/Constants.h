//
//  Constants.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 20/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#pragma mark Screen Sizes
#define IS_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 667)
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height == 480)
#define IS_IPAD ([[UIScreen mainScreen] bounds].size.height == 1024)
#define IS_IPHONE_6Plus ([[UIScreen mainScreen] bounds].size.height == 736)

#pragma mark Colors
#define statusBarColor [UIColor colorWithRed:0.996 green:0.341 blue:0.129 alpha:1.0]
#define App_GrayColor   [UIColor colorFromHexCode:@"#D6D6D6"]

#define App_OrangeColor       [UIColor colorFromHexCode:@"#FF5723"]
#define App_BlueColor         [UIColor colorFromHexCode:@"#1D71A3"]
#define App_DarkYellowColor   [UIColor colorFromHexCode:@"#FF9600"]
#define App_LightYellowColor   [UIColor colorFromHexCode:@"#FFD9A3"]


/*  ------------------- BASE URL ------------------- */


#if DEBUG
#define BASE_URL            @"https://app.rapporrapp.com"   // Stagging
#else
#define BASE_URL            @"https://app.rapporrapp.com"  // Production
#endif

///

#define URI_VALIDATE_NUMBER             @"/validateMobile?number="
#define URI_AUTHENTICATE_NUMBER         @"/auth/phone"
#define URI_VALIDATE_CODE               @"/auth/device"
#define URI_CREATE_RAPPORR              @"/organisation/create"
#define URI_GET_CONVERSATION            @"/conversations/user/"
#define URI_GET_USERS                   @"/organisation/"
#define URI_GET_COMMANDATA              @"/commondata/"
#define URI_CREATE_TEAM                 @"/group"
#define URI_PROMOTE_USER                @"/account/change_admin_user"
#define URI_DEACTIVE_USER               @"/account/remove_user"
#define URI_RESEND_INVITE               @"/organisation/resend_invite"

#define URI_UPDATEUSER                  @"/account/userupdate"
#define URI_INVITE_USER                 @"/organisation/invite_user"


#define URI_GET_ALL_MESSAGES            @"/messages/%@/%@?last=%@"
#define URI_GET_CONVERSATION_MESSAGES   @"/conversation/%@/%@"

#define URI_POST_SEND_MESSAGES           @"/messages/send"
#define URI_GET_SEEN_BY                  @"/read/%@?last=all"

#define URI_POST_SEEN_BY                  @"/read"

#define URI_POST_START_NEW_CONVERSATION   @"/conversations/start"

#define URI_POST_ACCESS_CODE            @"/access"
#define URI_POST_SEND_AVATAR            @"/account/avatar"
#define URI_POST_USER_PROFILE           @"/account/userprofile"
#define URI_UPDATE_URL_CALL             @"/rapporr"
#define URI_PING_CALL                   @"/ping"

#define RAPPORRVERSION                  @"300"
#define COOKIE                          @"GOOGAPPUID=300"
#define RAPPORR_API_KEY                 @"xpeEfxTJ1cIyeE41"

#define DEV_STRING @"dev"
#define TERMS_URL                           @"http://www.rapporr.com/terms"
#define PRIVACY_URL                              @"http://www.rapporr.com/privacy"
#define HELP_URL                                     @"http://rapporrapp.com/redirect?redirect=help"
#define RAPPORR_DEFAULT_URL @"https://rapporr.com/app_intranet.html/"

#define ROBOTO_REGULAR(theFontSize)[UIFont fontWithName:@"Roboto-Regular" size:(theFontSize)]
#define ROBOTO_LIGHT(theFontSize)[UIFont fontWithName:@"Roboto-Light" size:(theFontSize)]
#define ROBOTO_BOLD(theFontSize)[UIFont fontWithName:@"Roboto-Bold" size:(theFontSize)]


#define INDEX_PATH(indexPath)             [NSString stringWithFormat:@"%@",indexPath]

#define SET_IMAGE(image) [UIImage imageNamed:(image)]
#define appDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define FullTimeStamp [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000]

#define $(...)  [NSSet setWithObjects:__VA_ARGS__, nil]


#define kUSER_TYPE_STD                   @"Std"
#define kUSER_TYPE_EXT                   @"Ext"
#define kUSER_TYPE_ADMIN                 @"Admin"

#define kUSER_TYPE_STD_STRING                   @"Standard"
#define kUSER_TYPE_ADMIN_STRING                 @"Administrator"





#pragma mark - Timestamps

#define kfetchWithUserTimestamp                    @"UserTimestamp"
#define kfetchWithConversationTimestamp            @"ConversationTimestamp"
#define kfetchWithTeamAPITimestamp                 @"TeamTimestamp"


#define kfetchWithAllMessagesTimestamp            @"AllMessagesTimestamp"
#define kfetchWithConversationMessagesTimestamp   @"ConversationMessagesTimestamp"


#define BASE_LANGUAGE_CODE                          @"en"
#define SELECT_LANGUAGE_NAME                        @"langEngName"
#define SELECT_LANGUAGE_CODE                        @"langCede"

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)



#endif /* Constants_h */
