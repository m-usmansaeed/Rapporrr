//
//  RPConverstionMessage.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/11/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "BaseEntity.h"
#import "ConversationUser.h"
#import "MessageSeenUser.h"
#import "AnnouncementModel.h"
#import "GPSLocationModel.h"
#import "ContactModel.h"


extern NSString * const MESSAGE_CONTENT_TYPEAnnouncement;
extern NSString * const MESSAGE_CONTENT_TYPEUserAdded;
extern NSString * const MESSAGE_CONTENT_TYPEFileAdded;
extern NSString * const MESSAGE_CONTENT_TYPELOCATION;
extern NSString * const MESSAGE_CONTENT_TYPEShareContact;
extern NSString * const MESSAGE_CONTENT_TYPESharePhoto;
extern NSString * const MESSAGE_CONTENT_TYPE_TEXT;

@interface RPConverstionMessage : BaseEntity

@property (nonatomic) BOOL isSentMessage;
@property (nonatomic) BOOL isSeenByAll;
@property (nonatomic) BOOL isTextFieldMessage;
@property (nonatomic) BOOL isExpanded;
@property (nonatomic) BOOL isField;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *convCallBackId;
@property (strong, nonatomic) NSString *callBackid;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *translation;

@property (strong, nonatomic) NSString *msgId;
@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *tempMsgId;
@property (strong, nonatomic) NSString *html;
@property (strong, nonatomic) NSString *mType;

@property (strong, nonatomic) NSString *objects;
@property (strong, nonatomic) NSString *previousMessageId;
@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSString *sentOn;
@property (strong, nonatomic) NSString *timeStamp;
@property (strong, nonatomic) NSString *organisation;
@property (strong, nonatomic) NSString *seenByCount;
@property (strong, nonatomic) NSMutableArray <ConversationUser*> *seenByUsers;
@property (strong, nonatomic) NSMutableArray *seenUsers;

@property (strong, nonatomic) ConversationUser *user;
@property (strong, nonatomic) AnnouncementModel *announcement;
@property (strong, nonatomic) AttachmentModel *attachment;

@property (strong, nonatomic) GPSLocationModel *locationModel;
@property (strong, nonatomic) ContactModel *contactModel;

@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSString *thumbImage;
@property ( nonatomic) BOOL isRead;
@property (strong, nonatomic) NSString *contentType;

@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *endTime;
@property (strong, nonatomic) NSString *location;

@property (strong, nonatomic) NSString *platform;
@property (strong, nonatomic) NSString *rapporrverison;

@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *photoId;
@property (strong, nonatomic) NSString *tempImageUrl;
@property (strong, nonatomic) NSString *tempThumbImageUrl;

@property (strong, nonatomic) NSString *attachmentLocalUrl;
@property (strong, nonatomic) UIImage *placeHolderImage;

@property (strong, nonatomic) NSString *profilePlaceHolderString;

- (id)initWithDictionary:(NSDictionary *) responseData;
- (id)initWithManagedObject:(NSManagedObject *)teamObject;
- (id)initWithNotificationDictionary:(NSDictionary *) responseData;
+(NSMutableArray *)parseConversationMessages:(NSArray *)array;



@end


