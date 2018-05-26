//
//  CoreDataController.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 12/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MessageModel.h"
#import "VerifiedCompanyModel.h"
#import "ConversationUser.h"
#import "TeamModel.h"
#import "RPConverstionMessage.h"
#import "MessageSeenUser.h"
#import "AttachmentModel.h"


@interface CoreDataController : NSObject {
    
}

@property (strong, nonatomic) NSManagedObjectContext * _Nullable privateQueueContext;
@property (strong, nonatomic) NSManagedObjectContext * _Nullable mainManagedObjectContext;


+ (CoreDataController *_Nullable) sharedManager;

#pragma mark - Save Models
- (void) saveMessageModel : (MessageModel*_Nullable) mModel;
- (void) removeAllMessageModel;
- (void) saveVerifiedCompany : (VerifiedCompanyModel*_Nullable) vcModel;
- (void) updateDeactiveCompanies;
- (void) removeAllMessages;
- (MessageModel*) getMessageModel : (NSString*) conversationID;
- (void) removeAllUnSentMessages:(RPConverstionMessage *_Nullable)message;
- (void) UpdateMessageModelForNotification : (NSString*_Nullable) lastMsg andTimeStamp :(NSString*_Nullable)timeStamp andConversationID : (NSString*_Nullable) conversationID;
- (void) UpdateMessageModelForNotificationWithoutCount : (NSString*) lastMsg andTimeStamp :(NSString*)timeStamp andConversationID : (NSString*) conversationID;


- (void) saveConversationUser : (ConversationUser*_Nullable) conversationUser;
- (ConversationUser*_Nullable) getUserWithID: (NSString*_Nullable)userId;
- (BOOL)checkIfConversationUserExist:(ConversationUser *_Nullable)ConversationUser;

- (void) removeAllUsers;
- (void) removeUser:(ConversationUser *_Nullable)user;
- (void) updateUser:(ConversationUser *_Nullable)user;
        
- (void) saveTeam:(TeamModel*_Nullable)team;
- (void) updateTeam : (TeamModel*_Nullable) team;

- (void) removeTeam:(TeamModel *_Nullable)team;
- (void) removeAllTeam:(TeamModel *_Nullable)team;
- (void) fetchTeamsFromDBWithCompletion:(void(^_Nullable)(BOOL isFinished,NSMutableArray * _Nullable array))completion;
-(BOOL)checkIfTeamExist:(TeamModel *_Nullable)team;


- (NSMutableArray *_Nullable) fetchUserFromDBUnblockedUsers;
- (NSMutableArray *_Nullable) fetchUserFromDB;



#pragma mark - Update Models
- (void) UpdateMessageModel : (MessageModel*_Nullable) mModel;


#pragma mark - Get Models
- (NSMutableArray*_Nullable) getVerifiedCompanies;

#pragma mark - Utility Methods
- (BOOL) ifAnyVerifiedCompant;

#pragma mark - ConversationMessage
- (void)saveConversationMessage:(RPConverstionMessage *_Nullable)message;
- (NSMutableArray *_Nullable) fetchConversationMessagesFromDBForConversation:(MessageModel *_Nullable)conversation WithCompletion:(void (^_Nullable)( RPConverstionMessage * _Nullable unSentMessage))completion;
- (BOOL)searchForMessage:(RPConverstionMessage *_Nullable)message;
- (BOOL)searchTempSavedMessage:(RPConverstionMessage *_Nullable)message;
-(void)updateConversationMessage:(RPConverstionMessage *_Nullable)message;
-(void)updateMessageStatus:(RPConverstionMessage *_Nullable)message withStatus:(BOOL)status;
- (void) removeTempMessage:(RPConverstionMessage *_Nullable)message;
- (RPConverstionMessage *_Nullable)getMessageWithId:(RPConverstionMessage *_Nullable)message;


-(void)updateSeenByUser:(MessageSeenUser *_Nullable)messageSeenBy;
-(BOOL)searchForSeenBy:(MessageSeenUser *_Nullable)messageSeenBy;
-(void)saveSeenByUser:(MessageSeenUser *_Nullable)messageSeenBy;
- (void)saveSeenUser:(MessageSeenUser *)messageSeenBy;

-(NSMutableArray *_Nullable)getMessageSeenByUsersWithMessageId:(NSString *_Nullable)msgId andConversationId:(NSString *_Nullable)conversationId;





-(AttachmentModel *_Nullable)getAttachmentWithMessage:(RPConverstionMessage *_Nullable)message;
-(void)updateAttachmentForConversation:(RPConverstionMessage *)message;


- (void) UpdateMessageModelWithoutUnReadCount : (MessageModel*) mModel;



@end
