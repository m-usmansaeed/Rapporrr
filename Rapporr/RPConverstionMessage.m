//
//  RPConverstionMessage.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/11/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//


#import "RPConverstionMessage.h"

NSString * const MESSAGE_CONTENT_TYPEAnnouncement   = @"announcement";
NSString * const MESSAGE_CONTENT_TYPEFileAdded      = @"file";
NSString * const MESSAGE_CONTENT_TYPEUserAdded      = @"UserAdded";
NSString * const MESSAGE_CONTENT_TYPELOCATION       = @"location";
NSString * const MESSAGE_CONTENT_TYPEShareContact   = @"link";
NSString * const MESSAGE_CONTENT_TYPESharePhoto     = @"photo";
NSString * const MESSAGE_CONTENT_TYPE_TEXT          = @"text";


@implementation RPConverstionMessage

-(instancetype)init{

    if (self) {
      self =  [super init];
        
        self.user = [[ConversationUser alloc]init];
        self.announcement = [[AnnouncementModel alloc]init];
        self.attachment = [[AttachmentModel alloc]init];
        self.locationModel = [[GPSLocationModel alloc]init];
        self.contactModel = [[ContactModel alloc]init];
        self.seenByUsers  = [[NSMutableArray alloc]init];
        self.seenUsers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *) responseData;
{
    self = [super init];
    
    if (self) {
        
        self.isSentMessage = YES;
        self.isTextFieldMessage = NO;
        self.isSeenByAll = NO;
        self.isField = NO;
        self.callBackid        = [NSString validStringForObject:responseData[@"CallBackid"]];
        self.conversationId    = [NSString validStringForObject:responseData[@"ConversationId"]];
        self.message           = [NSString validStringForObject:responseData[@"Text"]];
        self.html              = [NSString validStringForObject:responseData[@"HTML"]];
        self.host              = [NSString validStringForObject:responseData[@"Host"]];
        self.mType             = [NSString validStringForObject:responseData[@"MType"]];
        self.msgId             = [NSString validStringForObject:responseData[@"MessageId"]];
        self.previousMessageId = [NSString validStringForObject:responseData[@"PreviousMessageId"]];
        self.senderName        = [NSString validStringForObject:responseData[@"SenderName"]];
        self.sentOn            = [NSString validStringForObject:responseData[@"SentOn"]];
        self.timeStamp         = [NSString validStringForObject:responseData[@"TimeStamp"]];
        self.organisation      = [NSString validStringForObject:responseData[@"organisation"]];
        self.userId            = [NSString validStringForObject:responseData[@"UserId"]];
        self.tempMsgId         = @"";
        self.seenByCount       = @"";
        self.seenByUsers       = [[NSMutableArray alloc] init];
        self.objects           = [NSString validStringForObject:responseData[@"Objects"]];
        
    }
    return self;
}

- (id)initWithNotificationDictionary:(NSDictionary *) responseData
{
    self = [super init];
    
    if (self) {
        
        NSString *strTemp = [NSString validStringForObject:responseData[@"messageId"]];
        if(strTemp.length>1) {
            NSString *tempConversationID = [strTemp componentsSeparatedByString:@"/"][0];
            NSString *tempMessageID = [strTemp componentsSeparatedByString:@"/"][1];
            
            NSDateFormatter *dateFormatter = [NSDateFormatter defaultDateManager];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ";
            NSTimeZone *gmtZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
            [dateFormatter setTimeZone:gmtZone];
            
            NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
            
            self.isSentMessage = YES;
            self.isTextFieldMessage = NO;
            self.isSeenByAll = NO;
            self.isField = NO;
            self.callBackid        = [NSString validStringForObject:responseData[@"callbackid"]];
            self.conversationId    = tempConversationID;
            self.message           = [NSString validStringForObject:responseData[@"text"]];
            self.host              = [NSString validStringForObject:responseData[@"host"]];
            self.msgId             = tempMessageID;
            self.senderName        = [NSString validStringForObject:responseData[@"senderName"]];
            self.sentOn            = [NSString validStringForObject:responseData[@"sentOn"]];
            self.timeStamp         = timeStamp;
            self.organisation      = [NSString validStringForObject:responseData[@"organisationId"]];
            self.userId            = [NSString validStringForObject:responseData[@"userId"]];
            self.title            = [NSString validStringForObject:responseData[@"title"]];
            self.tempMsgId         = @"";
            self.seenByCount       = @"";
            self.seenByUsers       = [[NSMutableArray alloc] init];
            self.objects           = [NSString validStringForObject:responseData[@"objects"]];
        }
        
        
    }
    return self;
}

- (id)initWithManagedObject:(NSManagedObject *) teamObject
{
    self = [super init];
    
    if (self) {
        
        NSData *image = [teamObject valueForKey:@"placeHolderImage"];
        self.placeHolderImage = [UIImage imageWithData:image];
        
        self.isSentMessage  = [[teamObject valueForKey:@"isSentMessage"] boolValue];
        self.isSentMessage  = [[teamObject valueForKey:@"isSentMessage"] boolValue];
        self.isField = [[teamObject valueForKey:@"isField"] boolValue];        
        self.isSeenByAll    = [[teamObject valueForKey:@"isSeenByAll"] boolValue];
        self.isTextFieldMessage  = [[teamObject valueForKey:@"isTextFieldMessage"] boolValue];
        self.isRead  = [[teamObject valueForKey:@"isRead"] boolValue];
        self.conversationId = [teamObject valueForKey:@"conversationId"];
        self.message        = [teamObject valueForKey:@"message"];
        self.convCallBackId = [teamObject valueForKey:@"convCallBackId"];
        self.userId         = [teamObject valueForKey:@"userId"];
        self.msgId             = [teamObject valueForKey:@"msgId"];
        self.html              = [teamObject valueForKey:@"html"];
        self.callBackid        = [teamObject valueForKey:@"callBackid"];
        self.host              = [teamObject valueForKey:@"host"];
        self.mType             = [teamObject valueForKey:@"mType"];
        self.objects           = [teamObject valueForKey:@"objects"];
        self.previousMessageId = [teamObject valueForKey:@"previousMessageId"];
        self.senderName        = [teamObject valueForKey:@"senderName"];
        self.sentOn            = [teamObject valueForKey:@"sentOn"];
        self.timeStamp         = [teamObject valueForKey:@"timeStamp"];
        self.organisation      = [teamObject valueForKey:@"organisation"];
        self.user              = [[CoreDataController sharedManager] getUserWithID:self.userId];
        self.tempMsgId         = [teamObject valueForKey:@"tempMsgId"];
        self.seenByUsers = [[NSMutableArray alloc] init];
        self.attachmentLocalUrl = [teamObject valueForKey:@"attachmentLocalUrl"];
        self.translation        = [teamObject valueForKey:@"translation"];
        
        self.seenByUsers = [[CoreDataController sharedManager] getMessageSeenByUsersWithMessageId:self.msgId andConversationId:self.conversationId];
       
        self.seenByCount = [NSString stringWithFormat:@"%d",(int)[self.seenByUsers count]];
        
        self.contentType = MESSAGE_CONTENT_TYPE_TEXT;
        
        if (self.objects != nil && ![self.objects isEqualToString:@""]) {
            
            NSDictionary *dict = [NSDictionary dictionaryFromString:self.objects];
            
//            NSLog(@"%@",dict);
            
            if([dict count] > 0){

            self.date = [NSString validStringForObject:dict[@"date"]];
            self.endTime = [NSString validStringForObject:dict[@"endTime"]];
            self.location = [NSString validStringForObject:dict[@"location"]];
            self.rapporrverison = [NSString validStringForObject:dict[@"source"][@"rapporrverison"]];
            self.platform = [NSString validStringForObject:dict[@"source"][@"platform"]];
            self.startTime = [NSString validStringForObject:dict[@"startTime"]];
            self.title = [NSString validStringForObject:dict[@"title"]];
            
            if (dict[@"mimeType"]) {
                self.contentType = MESSAGE_CONTENT_TYPEFileAdded;
            }else{
                self.contentType = [NSString validStringForObject:dict[@"contentType"]];
            }
            
            if ([self.contentType isEqualToString:MESSAGE_CONTENT_TYPEUserAdded]) {
                
            }else if([self.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]){
                self.announcement = [[AnnouncementModel alloc]initWithDictionary:dict];
            }else if([self.contentType isEqualToString:MESSAGE_CONTENT_TYPELOCATION]){
                self.imageUrl   = [NSString stringWithFormat:@"https://images.rapporrapp.com/%@/original",dict[@"photoID"]];
                self.thumbImage = [NSString stringWithFormat:@"https://images.rapporrapp.com/%@/thumbnail",dict[@"photoID"]];
                self.locationModel = [[GPSLocationModel alloc]initWithDictionary:dict];
            }else if([self.contentType isEqualToString:MESSAGE_CONTENT_TYPEShareContact]){
                self.contactModel = [[ContactModel alloc]initWithDictionary:dict];
            }else if([self.contentType isEqualToString:MESSAGE_CONTENT_TYPESharePhoto]){
                self.imageUrl   = [NSString stringWithFormat:@"https://images.rapporrapp.com/%@/original",dict[@"photoID"]];
                self.thumbImage = [NSString stringWithFormat:@"https://images.rapporrapp.com/%@/thumbnail",dict[@"photoID"]];
            }else if([self.contentType isEqualToString:MESSAGE_CONTENT_TYPEFileAdded]){
                self.attachment = [[AttachmentModel alloc]initWithDictionary:dict];
                self.attachment.localUrl = self.attachmentLocalUrl;
            }
            }
        }
    }
    
    return self;
}

+(NSMutableArray *)parseConversationMessages:(NSArray *)array;
{
    //    https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/ClassMethod.html
    
    
//    NSLog(@"%@",array);
    
    NSMutableArray *messages = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in array) {
        RPConverstionMessage *convMsg = [[RPConverstionMessage alloc]initWithDictionary:dict];
        
        if(![[CoreDataController sharedManager] searchForMessage:convMsg]){
            [[CoreDataController sharedManager] saveConversationMessage:convMsg];
            [messages addObject:convMsg];
        }else{
            
            RPConverstionMessage *message = [[CoreDataController sharedManager] getMessageWithId:convMsg];
            if (!message.isRead) {
                message.isRead = YES;
            }
            
            [[CoreDataController sharedManager] updateConversationMessage:convMsg];
        }
    }
    return messages;
}



@end
