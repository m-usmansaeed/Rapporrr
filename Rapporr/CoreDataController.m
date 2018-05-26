//
//  CoreDataController.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 12/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "CoreDataController.h"

@implementation CoreDataController
static CoreDataController *sharedManager;

+ (CoreDataController *) sharedManager
{
    if(sharedManager == nil)
    {
        sharedManager = [[CoreDataController alloc] init];
    }
    
    
    //    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:nil usingBlock:^(NSNotification* note) {
    //
    //        NSManagedObjectContext *mainContext = appDelegate.managedObjectContext;
    //        NSManagedObjectContext *otherMoc = note.object;
    //
    //        if (otherMoc.persistentStoreCoordinator == mainContext.persistentStoreCoordinator) {
    //            if (otherMoc != mainContext) {
    //                [mainContext performBlock:^(){
    //                    [mainContext mergeChangesFromContextDidSaveNotification:note];
    //                }];
    //            }
    //        }
    //    }];
    
    return sharedManager;
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (NSManagedObjectContext *)privateQueueContext
{
    if (!_privateQueueContext) {
        
        _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_privateQueueContext setParentContext:[self managedObjectContext]];
    }
    return _privateQueueContext;
}


#pragma mark - Conversation

- (void) UpdateMessageModelWithoutUnReadCount : (MessageModel*) mModel {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Message"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"conversationId == %@", mModel.conversationId]];
    
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        
        NSManagedObject* conversation = [results objectAtIndex:0];
        [conversation setValue:mModel.host forKey:@"host"];
        [conversation setValue:mModel.tags forKey:@"tags"];
        [conversation setValue:mModel.about forKey:@"about"];
        [conversation setValue:mModel.create forKey:@"create"];
        [conversation setValue:mModel.lastMsg forKey:@"lastMsg"];
        [conversation setValue:mModel.timeStamp forKey:@"timeStamp"];
        [conversation setValue:mModel.lastMsgId forKey:@"lastMsgId"];
        [conversation setValue:mModel.cTemplate forKey:@"cTemplate"];
        [conversation setValue:mModel.senderName forKey:@"senderName"];
        [conversation setValue:mModel.firstName forKey:@"firstName"];
        [conversation setValue:mModel.lastName forKey:@"lastName"];
        [conversation setValue:mModel.callBackId forKey:@"callBackId"];
        [conversation setValue:mModel.startingUser forKey:@"startingUser"];
        [conversation setValue:mModel.conversationId forKey:@"conversationId"];
        [conversation setValue:mModel.lastMsgRecieved forKey:@"lastMsgRecieved"];
        [conversation setValue:[NSNumber numberWithBool:mModel.isPinned] forKey:@"isPinned"];
        [conversation setValue:[NSNumber numberWithBool:mModel.isArchieved] forKey:@"isArchieved"];
        [conversation setValue:mModel.users forKey:@"users"];
        [conversation setValue:mModel.objects forKey:@"objects"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
    
}

- (void) UpdateMessageModel : (MessageModel*) mModel {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Message"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"conversationId == %@", mModel.conversationId]];
    
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        
        NSManagedObject* conversation = [results objectAtIndex:0];
        [conversation setValue:mModel.host forKey:@"host"];
        [conversation setValue:mModel.tags forKey:@"tags"];
        [conversation setValue:mModel.about forKey:@"about"];
        [conversation setValue:mModel.create forKey:@"create"];
        [conversation setValue:mModel.lastMsg forKey:@"lastMsg"];
        [conversation setValue:mModel.timeStamp forKey:@"timeStamp"];
        [conversation setValue:mModel.lastMsgId forKey:@"lastMsgId"];
        [conversation setValue:mModel.cTemplate forKey:@"cTemplate"];
        [conversation setValue:mModel.senderName forKey:@"senderName"];
        [conversation setValue:mModel.firstName forKey:@"firstName"];
        [conversation setValue:mModel.lastName forKey:@"lastName"];
        [conversation setValue:mModel.callBackId forKey:@"callBackId"];
        [conversation setValue:mModel.startingUser forKey:@"startingUser"];
        [conversation setValue:mModel.conversationId forKey:@"conversationId"];
        [conversation setValue:mModel.lastMsgRecieved forKey:@"lastMsgRecieved"];
        [conversation setValue:[NSNumber numberWithBool:mModel.isPinned] forKey:@"isPinned"];
        [conversation setValue:[NSNumber numberWithBool:mModel.isArchieved] forKey:@"isArchieved"];
        [conversation setValue:mModel.users forKey:@"users"];
        [conversation setValue:mModel.objects forKey:@"objects"];
        
        [conversation setValue:mModel.unReadMsgsCount forKey:@"unreadMsgsCount"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

- (MessageModel*) getMessageModel : (NSString*) conversationID {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Message"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"conversationId == %@", conversationID]];
    
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        
        NSManagedObject* conversation = [results objectAtIndex:0];
        MessageModel *mModel = [[MessageModel alloc] initWithManagedObject:conversation];
        return mModel;
        
    }
    
    return nil;
}

- (void) UpdateMessageModelForNotification : (NSString*) lastMsg andTimeStamp :(NSString*)timeStamp andConversationID : (NSString*) conversationID {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Message"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"conversationId == %@", conversationID]];
    
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        
        NSManagedObject* conversation = [results objectAtIndex:0];
        
        MessageModel *mModel = [[MessageModel alloc] initWithManagedObject:conversation];
        [conversation setValue:lastMsg forKey:@"lastMsg"];
        [conversation setValue:timeStamp forKey:@"timeStamp"];
        int unRead = [mModel.unReadMsgsCount intValue];
        unRead = unRead+1;;
        
        [conversation setValue:[NSString stringWithFormat:@"%d",unRead] forKey:@"unreadMsgsCount"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

- (void) UpdateMessageModelForNotificationWithoutCount : (NSString*) lastMsg andTimeStamp :(NSString*)timeStamp andConversationID : (NSString*) conversationID {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Message"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"conversationId == %@", conversationID]];
    
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        
        NSManagedObject* conversation = [results objectAtIndex:0];
        
        [conversation setValue:lastMsg forKey:@"lastMsg"];
        [conversation setValue:timeStamp forKey:@"timeStamp"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

- (void) saveMessageModel : (MessageModel*) mModel {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    // Create a new managed object
    NSManagedObject *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    [newMessage setValue:mModel.host forKey:@"host"];
    [newMessage setValue:mModel.tags forKey:@"tags"];
    [newMessage setValue:mModel.about forKey:@"about"];
    [newMessage setValue:mModel.create forKey:@"create"];
    [newMessage setValue:mModel.lastMsg forKey:@"lastMsg"];
    [newMessage setValue:mModel.timeStamp forKey:@"timeStamp"];
    [newMessage setValue:mModel.lastMsgId forKey:@"lastMsgId"];
    [newMessage setValue:mModel.cTemplate forKey:@"cTemplate"];
    [newMessage setValue:mModel.senderName forKey:@"senderName"];
    [newMessage setValue:mModel.firstName forKey:@"firstName"];
    [newMessage setValue:mModel.lastName forKey:@"lastName"];
    [newMessage setValue:mModel.callBackId forKey:@"callBackId"];
    [newMessage setValue:mModel.startingUser forKey:@"startingUser"];
    [newMessage setValue:mModel.conversationId forKey:@"conversationId"];
    [newMessage setValue:mModel.lastMsgRecieved forKey:@"lastMsgRecieved"];
    [newMessage setValue:[NSNumber numberWithBool:false]  forKey:@"isPinned"];
    [newMessage setValue:[NSNumber numberWithBool:false]  forKey:@"isArchieved"];
    [newMessage setValue:mModel.users forKey:@"users"];
    [newMessage setValue:mModel.objects forKey:@"objects"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [[self managedObjectContext] save:nil];
}

- (void) removeAllMessageModel
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Message"];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    for (NSManagedObject* userObj in results) {
        [[self managedObjectContext] deleteObject:userObj];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

#pragma mark - User

- (NSMutableArray *) fetchUserFromDBUnblockedUsers {
    
    NSManagedObjectContext *managedObjectContext = [self privateQueueContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ConverstionUser"];
    NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                            ascending:YES
                                                             selector:@selector(caseInsensitiveCompare:)];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"disabled == 0"]];
    
    NSMutableArray *tempUsers = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    NSMutableArray *users = [[NSMutableArray alloc] init];
    
    for(int i=0; i<tempUsers.count; i++) {
        NSManagedObject *conversationUserObj = [tempUsers objectAtIndex:i];
        ConversationUser *cUserModel = [[ConversationUser alloc] initWithManagedObject:conversationUserObj];
        if (!cUserModel.disabled) {
            [users addObject:cUserModel];
        }
    }
    
    return users;
}

- (NSMutableArray *) fetchUserFromDB {
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ConverstionUser"];
    NSSortDescriptor *sort =  [NSSortDescriptor sortDescriptorWithKey:@"fName"
                                                            ascending:YES
                                                             selector:@selector(caseInsensitiveCompare:)];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSMutableArray *tempUsers = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    NSMutableArray *users = [[NSMutableArray alloc] init];
    
    for(int i=0; i<tempUsers.count; i++) {
        NSManagedObject *conversationUserObj = [tempUsers objectAtIndex:i];
        ConversationUser *cUserModel = [[ConversationUser alloc] initWithManagedObject:conversationUserObj];
        [users addObject:cUserModel];
    }
    
    return users;
}

- (void) saveConversationUser : (ConversationUser*) conversationUser {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    // Create a new managed object
    NSManagedObject *newConversationUser = [NSEntityDescription insertNewObjectForEntityForName:@"ConverstionUser" inManagedObjectContext:context];
    
    
    [newConversationUser setValue:conversationUser.avatarUrl forKey:@"avatarUrl"];
    //    [newConversationUser setValue:[NSNumber numberWithBool:conversationUser.deleted] forKey:@"userDelete"];
    [newConversationUser setValue:[NSNumber numberWithBool:conversationUser.disabled] forKey:@"disabled"];
    [newConversationUser setValue:conversationUser.email forKey:@"email"];
    [newConversationUser setValue:conversationUser.fName forKey:@"fName"];
    [newConversationUser setValue:conversationUser.fullId forKey:@"fullId"];
    [newConversationUser setValue:conversationUser.isRegistered forKey:@"isRegistered"];
    [newConversationUser setValue:conversationUser.lName forKey:@"lName"];
    [newConversationUser setValue:conversationUser.lastSeen forKey:@"lastSeen"];
    [newConversationUser setValue:conversationUser.name forKey:@"name"];
    [newConversationUser setValue:conversationUser.objects forKey:@"objects"];
    [newConversationUser setValue:conversationUser.org forKey:@"org"];
    [newConversationUser setValue:conversationUser.phone forKey:@"phone"];
    [newConversationUser setValue:conversationUser.pin forKey:@"pin"];
    [newConversationUser setValue:conversationUser.smsRecieved  forKey:@"smsRecieved"];
    [newConversationUser setValue:conversationUser.timeStamp forKey:@"timeStamp"];
    [newConversationUser setValue:conversationUser.uType forKey:@"uType"];
    [newConversationUser setValue:conversationUser.userId forKey:@"userId"];
    [newConversationUser setValue:[NSNumber numberWithBool:conversationUser.isAdmin] forKey:@"isAdmin"];
    
    //    [newConversationUser setValue:[NSNumber numberWithBool:conversationUser.isDeactivateUser] forKey:@"isDeactivateUser"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [[self managedObjectContext] save:nil];
}


- (void)removeAllUsers
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"ConverstionUser"];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    for (NSManagedObject* userObj in results) {
        [[self managedObjectContext] deleteObject:userObj];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

- (void) updateUser:(ConversationUser *)user;
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"ConverstionUser"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"fullId == %@", user.fullId]];
    
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        NSManagedObject* newConversationUser = [results objectAtIndex:0];
        
        
        [newConversationUser setValue:user.avatarUrl forKey:@"avatarUrl"];
        [newConversationUser setValue:[NSNumber numberWithBool:user.disabled] forKey:@"disabled"];
        [newConversationUser setValue:user.email forKey:@"email"];
        [newConversationUser setValue:user.fName forKey:@"fName"];
        [newConversationUser setValue:user.fullId forKey:@"fullId"];
        [newConversationUser setValue:user.isRegistered forKey:@"isRegistered"];
        [newConversationUser setValue:user.lName forKey:@"lName"];
        [newConversationUser setValue:user.lastSeen forKey:@"lastSeen"];
        [newConversationUser setValue:user.name forKey:@"name"];
        [newConversationUser setValue:user.objects forKey:@"objects"];
        [newConversationUser setValue:user.org forKey:@"org"];
        [newConversationUser setValue:user.phone forKey:@"phone"];
        [newConversationUser setValue:user.pin forKey:@"pin"];
        [newConversationUser setValue:user.smsRecieved  forKey:@"smsRecieved"];
        [newConversationUser setValue:user.timeStamp forKey:@"timeStamp"];
        [newConversationUser setValue:user.uType forKey:@"uType"];
        [newConversationUser setValue:user.userId forKey:@"userId"];
        [newConversationUser setValue:[NSNumber numberWithBool:user.isAdmin] forKey:@"isAdmin"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    } else {
        NSLog(@"Enter Corect Course number");
    }
}

- (void) removeUser:(ConversationUser *)user
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"ConverstionUser"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"fullId == %@", user.fullId]];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        NSManagedObject* userObj = [results objectAtIndex:0];
        
        [[self managedObjectContext] deleteObject:userObj];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            abort();
            
        }
    } else {
        NSLog(@"Enter Corect Course number");
    }
}

- (ConversationUser*) getUserWithID: (NSString*)userId;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"ConverstionUser"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fullId == %@",userId];
    [fetchRequest setPredicate:predicate];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    ConversationUser *conversationUser = nil;
    
    if (results.count > 0) {
        NSManagedObject* userObj = [results lastObject];
        conversationUser = [[ConversationUser alloc]initWithManagedObject:userObj];
    }
    return conversationUser;
}


-(BOOL)checkIfConversationUserExist:(ConversationUser *)ConversationUser{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ConverstionUser"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"fullId = %@", ConversationUser.fullId]];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    if (count == NSNotFound){}
    else if (count == 0){
        return NO;
    }else{
        return YES;
    }
    return NO;
}

- (void) saveVerifiedCompany : (VerifiedCompanyModel*) vcModel {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newCompany = [NSEntityDescription insertNewObjectForEntityForName:@"VerifiedCompany" inManagedObjectContext:context];
    [newCompany setValue:vcModel.companyName forKey:@"companyName"];
    [newCompany setValue:vcModel.expires forKey:@"expires"];
    [newCompany setValue:vcModel.hostID forKey:@"hostID"];
    [newCompany setValue:vcModel.orgId forKey:@"orgId"];
    [newCompany setValue:vcModel.token forKey:@"token"];
    [newCompany setValue:vcModel.userId forKey:@"userId"];
    [newCompany setValue:vcModel.userName forKey:@"userName"];
    [newCompany setValue:vcModel.uType forKey:@"uType"];
    [newCompany setValue:[NSNumber numberWithBool:vcModel.isActive] forKey:@"isActive"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}


-(void)updateDeactiveCompanies{
    
    NSMutableArray *fetchedCompanies = [[CoreDataController sharedManager] getVerifiedCompanies];
    if ([fetchedCompanies count]) {
        for (NSManagedObject *company in fetchedCompanies) {
            VerifiedCompanyModel *tempVcModel = [[VerifiedCompanyModel alloc] initWithManagedObject:company];
            tempVcModel.isActive = NO;
            [self saveVerifiedCompany:tempVcModel];
        }
    }
}


- (BOOL) ifAnyVerifiedCompant {
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"VerifiedCompany"];
    [fetchRequest setFetchLimit:1];
    NSMutableArray *tempMessages = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if(tempMessages.count > 0) {
        return true;
    }
    return false;
}

- (NSMutableArray*) getVerifiedCompanies {
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"VerifiedCompany"];
    return [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

#pragma mark - Team

- (void) saveTeam : (TeamModel*) team {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newTeam = [NSEntityDescription insertNewObjectForEntityForName:@"Team" inManagedObjectContext:context];
    
    [newTeam setValue:[NSNumber numberWithBool:team.isActive] forKey:@"isActive"];
    [newTeam setValue:team.callBackId forKey:@"callBackId"];
    [newTeam setValue:team.gType forKey:@"gType"];
    [newTeam setValue:team.groupId forKey:@"groupId"];
    [newTeam setValue:team.hostId forKey:@"hostId"];
    [newTeam setValue:team.name forKey:@"name"];
    [newTeam setValue:team.orgId forKey:@"orgId"];
    [newTeam setValue:team.publicID forKey:@"publicID"];
    [newTeam setValue:team.recType forKey:@"recType"];
    [newTeam setValue:team.status forKey:@"status"];
    [newTeam setValue:team.usersString forKey:@"users"];
    [newTeam setValue:team.timeStamp forKey:@"timeStamp"];
    [newTeam setValue:team.userId forKey:@"userId"];
    [newTeam setValue:team.usersIdArray forKey:@"users"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [[self managedObjectContext] save:nil];
    
}

- (void) updateTeam : (TeamModel*) team {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Team"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"callBackId == %@", team.callBackId]];
    
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        
        NSManagedObject* newTeam = [results objectAtIndex:0];
        [newTeam setValue:[NSNumber numberWithBool:team.isActive] forKey:@"isActive"];
        [newTeam setValue:team.callBackId forKey:@"callBackId"];
        [newTeam setValue:team.gType forKey:@"gType"];
        [newTeam setValue:team.groupId forKey:@"groupId"];
        [newTeam setValue:team.hostId forKey:@"hostId"];
        [newTeam setValue:team.name forKey:@"name"];
        [newTeam setValue:team.orgId forKey:@"orgId"];
        [newTeam setValue:team.publicID forKey:@"publicID"];
        [newTeam setValue:team.recType forKey:@"recType"];
        [newTeam setValue:team.status forKey:@"status"];
        [newTeam setValue:team.usersString forKey:@"users"];
        [newTeam setValue:team.timeStamp forKey:@"timeStamp"];
        [newTeam setValue:team.userId forKey:@"userId"];
        [newTeam setValue:team.usersIdArray forKey:@"users"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
    }
}


- (void) removeTeam:(TeamModel *)team
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Team"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"callBackId == %@", team.callBackId]];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        NSManagedObject* userObj = [results objectAtIndex:0];
        [[self managedObjectContext] deleteObject:userObj];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    } else {
        NSLog(@"Enter Corect Course number");
    }
}

- (void) removeAllTeam:(TeamModel *)team
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Team"];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    for (NSManagedObject* userObj in results) {
        [[self managedObjectContext] deleteObject:userObj];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

- (void) fetchTeamsFromDBWithCompletion:(void(^)(BOOL isFinished,NSMutableArray *array))completion
{
    NSManagedObjectContext *managedObjectContext = [self privateQueueContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    NSMutableArray *tempUsers = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    NSMutableArray *teams = [[NSMutableArray alloc] init];
    
    if ([tempUsers count]) {
        
        for (NSManagedObject *conversationUserObj in tempUsers) {
            
            TeamModel *team = [[TeamModel alloc] initWithManagedObject:conversationUserObj];
            for (ConversationUser *user in team.members) {
                if ([team.members count]) {
                    if ([user.fullId isEqualToString:team.userId]) {
                        if (user.disabled) {
                        }else{
                            if (team != nil) {
                                NSLog(@"%@",team);
                                [teams addObject:team];
                            }
                        }
                    }
                }
            }
        }
        
        if ([teams count]) {
            completion(YES, teams);
        }else{
            completion(NO, teams);
        }
    }
    
}

-(BOOL)checkIfTeamExist:(TeamModel *)team{
    
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Team"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"groupId = %@", team.groupId]];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    if (count == NSNotFound){}
    else if (count == 0){
        return NO;
    }else{
        return YES;
    }
    return NO;
}


#pragma mark - ConversationMessage

- (void) removeAllMessages
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"ConverstionMessage"];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    for (NSManagedObject* userObj in results) {
        [[self managedObjectContext] deleteObject:userObj];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

- (void) removeAllUnSentMessages:(RPConverstionMessage *)message
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"ConverstionMessage"];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userId == %@",[RapporrManager sharedManager].vcModel.userId];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"conversationId == %@",message.conversationId];
    NSPredicate *predicate5 = [NSPredicate predicateWithFormat:@"isTextFieldMessage == %@",[NSNumber numberWithBool:YES]];
    NSPredicate *predicate  = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate3,predicate5]];
    
    [fetchRequest setPredicate:predicate];
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    for (NSManagedObject* userObj in results) {
        [[self managedObjectContext] deleteObject:userObj];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

- (void)saveConversationMessage:(RPConverstionMessage *)message
{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    // Create a new managed object
    NSManagedObject *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"ConverstionMessage" inManagedObjectContext:context];
    
    NSData *image = UIImagePNGRepresentation(message.placeHolderImage);
    [newMessage setValue:message.userId forKey:@"userId"];
    [newMessage setValue:message.message forKey:@"message"];
    [newMessage setValue:message.conversationId forKey:@"conversationId"];
    [newMessage setValue:[NSNumber numberWithBool:message.isSentMessage]  forKey:@"isSentMessage"];
    [newMessage setValue:message.msgId forKey:@"msgId"];
    [newMessage setValue:message.userId forKey:@"userId"];
    [newMessage setValue:message.html forKey:@"html"];
    [newMessage setValue:message.callBackid forKey:@"callBackid"];
    [newMessage setValue:message.host forKey:@"host"];
    [newMessage setValue:message.mType forKey:@"mType"];
    [newMessage setValue:message.objects forKey:@"objects"];
    [newMessage setValue:message.previousMessageId forKey:@"previousMessageId"];
    [newMessage setValue:message.senderName forKey:@"senderName"];
    [newMessage setValue:message.sentOn forKey:@"sentOn"];
    [newMessage setValue:message.timeStamp forKey:@"timeStamp"];
    [newMessage setValue:message.organisation forKey:@"organisation"];
    [newMessage setValue:message.tempMsgId forKey:@"tempMsgId"];
    [newMessage setValue:message.thumbImage forKey:@"thumbImage"];
    [newMessage setValue:message.imageUrl forKey:@"imageUrl"];
    [newMessage setValue:[NSNumber numberWithBool:message.isTextFieldMessage] forKey:@"isTextFieldMessage"];
    [newMessage setValue:[NSNumber numberWithBool:message.isSeenByAll] forKey:@"isSeenByAll"];
    [newMessage setValue:[NSNumber numberWithBool:message.isRead] forKey:@"isRead"];
    [newMessage setValue:image forKey:@"placeHolderImage"];
    
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}


-(void)updateMessageStatus:(RPConverstionMessage *)message withStatus:(BOOL)status
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"ConverstionMessage"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userId == %@",[RapporrManager sharedManager].vcModel.userId];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"conversationId == %@",message.conversationId];
    NSPredicate *predicate4 = [NSPredicate predicateWithFormat:@"isSentMessage == %@",[NSNumber numberWithBool:message.isSentMessage]];
    NSPredicate *predicate5 = [NSPredicate predicateWithFormat:@"tempMsgId == %@",message.tempMsgId];
    NSPredicate *predicate  = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate3,predicate4,predicate5]];
    
    [fetchRequest setPredicate:predicate];
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        for (NSManagedObject* newMessage in results) {
            if ([message.tempMsgId isEqualToString:[newMessage valueForKey:@"tempMsgId"]]) {
                [newMessage setValue:[NSNumber numberWithBool:status] forKey:@"isSentMessage"];
                [newMessage setValue:message.msgId forKey:@"msgId"];
                [newMessage setValue:message.previousMessageId forKey:@"previousMessageId"];
                [newMessage setValue:[NSNumber numberWithBool:message.isTextFieldMessage] forKey:@"isTextFieldMessage"];
                
                NSError *error = nil;
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
        }
    }
}


-(void)updateConversationMessage:(RPConverstionMessage *)message
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"ConverstionMessage"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userId == %@",message.userId];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"conversationId == %@",message.conversationId];
    NSPredicate *predicate4 = [NSPredicate predicateWithFormat:@"isSentMessage == %@",[NSNumber numberWithBool:message.isSentMessage]];
    NSPredicate *predicate5 = [NSPredicate predicateWithFormat:@"msgId == %@",message.msgId];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate3,predicate4,predicate5]];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if (results.count > 0) {
        NSManagedObject* newMessage = [results lastObject];
        
        [newMessage setValue:message.userId forKey:@"userId"];
        [newMessage setValue:message.message forKey:@"message"];
        [newMessage setValue:message.conversationId forKey:@"conversationId"];
        [newMessage setValue:[NSNumber numberWithBool:message.isSentMessage] forKey:@"isSentMessage"];
        [newMessage setValue:[NSNumber numberWithBool:message.isTextFieldMessage] forKey:@"isTextFieldMessage"];
        [newMessage setValue:message.msgId forKey:@"msgId"];
        [newMessage setValue:message.html forKey:@"html"];
        [newMessage setValue:message.callBackid forKey:@"callBackid"];
        [newMessage setValue:message.host forKey:@"host"];
        [newMessage setValue:message.mType forKey:@"mType"];
        [newMessage setValue:message.objects forKey:@"objects"];
        [newMessage setValue:message.previousMessageId forKey:@"previousMessageId"];
        [newMessage setValue:message.senderName forKey:@"senderName"];
        [newMessage setValue:message.sentOn forKey:@"sentOn"];
        [newMessage setValue:message.timeStamp forKey:@"timeStamp"];
        [newMessage setValue:message.organisation forKey:@"organisation"];
        [newMessage setValue:@"" forKey:@"tempMsgId"];
        [newMessage setValue:message.thumbImage forKey:@"thumbImage"];
        [newMessage setValue:message.imageUrl forKey:@"imageUrl"];
        [newMessage setValue:[NSNumber numberWithBool:message.isSeenByAll] forKey:@"isSeenByAll"];
        [newMessage setValue:[NSNumber numberWithBool:message.isRead] forKey:@"isRead"];
        
        NSData *image = UIImagePNGRepresentation(message.placeHolderImage);
//         [newMessage setValue:image forKey:@"placeHolderImage"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
    else{
        //        [self saveConversationMessage:message];
    }
}

-(void)updateAttachmentForConversation:(RPConverstionMessage *)message
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"ConverstionMessage"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userId == %@",message.userId];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"conversationId == %@",message.conversationId];
    
    NSPredicate *predicate4 = [NSPredicate predicateWithFormat:@"isSentMessage == %@",[NSNumber numberWithBool:message.isSentMessage]];
    NSPredicate *predicate5 = [NSPredicate predicateWithFormat:@"msgId == %@",message.msgId];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate3,predicate4,predicate5]];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if (results.count > 0) {
        
        NSManagedObject* newMessage = [results lastObject];
        
        [newMessage setValue:message.attachmentLocalUrl forKey:@"attachmentLocalUrl"];
        [newMessage setValue:message.translation forKey:@"translation"];
        [newMessage setValue:[NSNumber numberWithBool:message.isField] forKey:@"isField"];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}


- (BOOL)searchForMessage:(RPConverstionMessage *)message
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"ConverstionMessage"];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"conversationId == %@",message.conversationId];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"msgId == %@", message.msgId];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2]];
    [fetchRequest setPredicate:predicate];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    BOOL isFound = NO;
    if (results.count > 0) {
        isFound = YES;
    } else {
        isFound = NO;
    }
    return isFound;
}

- (BOOL)searchTempSavedMessage:(RPConverstionMessage *)message
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"ConverstionMessage"];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"conversationId == %@",message.conversationId];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"tempMsgId == %@", message.tempMsgId];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2]];
    [fetchRequest setPredicate:predicate];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    BOOL isFound = NO;
    if (results.count > 0) {
        isFound = YES;
    } else {
        isFound = NO;
    }
    return isFound;
}

- (RPConverstionMessage *)getMessageWithId:(RPConverstionMessage *)message
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"ConverstionMessage"];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"conversationId == %@",message.conversationId];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"msgId == %@", message.msgId];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2]];
    [fetchRequest setPredicate:predicate];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    BOOL isFound = NO;
    RPConverstionMessage *aMessage = nil;
    if (results.count > 0) {
        aMessage = [[RPConverstionMessage alloc] initWithManagedObject:[results objectAtIndex:0]];
    }
    return aMessage;
}


- (NSMutableArray *) fetchConversationMessagesFromDBForConversation:(MessageModel *)conversation WithCompletion:(void (^_Nullable)( RPConverstionMessage * _Nullable unSentMessage))completion;
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ConverstionMessage"];
    NSSortDescriptor *timeStamp = [[NSSortDescriptor alloc] initWithKey:@"sentOn" ascending:YES];
    [fetchRequest setSortDescriptors:@[timeStamp]];
    
    
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"conversationId == %@",conversation.conversationId];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate3]];
    [fetchRequest setPredicate:predicate];
    NSMutableArray *cdMessages = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    RPConverstionMessage *unSentMessage = nil;
    
    NSInteger count = 0;
    
    if ([cdMessages count]) {
        for(NSManagedObject *Objc in cdMessages) {
            RPConverstionMessage *message = [[RPConverstionMessage alloc] initWithManagedObject:Objc];
            if(message.isTextFieldMessage){
                unSentMessage = message;
            }else{
                [messages addObject:message];
            }
            count++;
        }
        if (unSentMessage) {
            completion(unSentMessage);
        }
    }
    return messages;
}

- (void)saveSeenByUser:(MessageSeenUser *)messageSeenBy
{
    NSManagedObjectContext *privateQueueContext = [self privateQueueContext];
    NSManagedObjectContext *mainQueueContext = [self managedObjectContext];
    
    // create background context
    
    NSEntityDescription *eDescription = [NSEntityDescription entityForName:@"MessageSeenByUser" inManagedObjectContext:mainQueueContext];
    
    [privateQueueContext performBlock:^{
        for (int i = 0; i < 2000; i++){
            
            NSManagedObject *seenUser = [[NSManagedObject alloc] initWithEntity:eDescription
                                                 insertIntoManagedObjectContext:privateQueueContext];
            [seenUser setValue:messageSeenBy.userId forKey:@"userId"];
            [seenUser setValue:messageSeenBy.hostId forKey:@"hostId"];
            [seenUser setValue:messageSeenBy.conversationId forKey:@"conversationId"];
            [seenUser setValue:messageSeenBy.lastMessageId forKey:@"lastMessageId"];
            [seenUser setValue:messageSeenBy.orgId forKey:@"orgId"];
            [seenUser setValue:messageSeenBy.timeStamp forKey:@"timeStamp"];
            [seenUser setValue:messageSeenBy.rType forKey:@"rType"];
            [privateQueueContext save:nil];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"DoneSaving parent");
            [mainQueueContext save:nil];
        });
    }];
    
    
    
    //    NSManagedObject *seenUser = [NSEntityDescription insertNewObjectForEntityForName:@"MessageSeenByUser" inManagedObjectContext:privateQueueContext];
    //
    //        [seenUser setValue:messageSeenBy.userId forKey:@"userId"];
    //        [seenUser setValue:messageSeenBy.hostId forKey:@"hostId"];
    //        [seenUser setValue:messageSeenBy.conversationId forKey:@"conversationId"];
    //        [seenUser setValue:messageSeenBy.lastMessageId forKey:@"lastMessageId"];
    //        [seenUser setValue:messageSeenBy.orgId forKey:@"orgId"];
    //        [seenUser setValue:messageSeenBy.timeStamp forKey:@"timeStamp"];
    //        [seenUser setValue:messageSeenBy.rType forKey:@"rType"];
    //
    //        NSError *error = nil;
    //        // Save the object to persistent store
    //
    //        if (![saveObjectContext save:&error]){
    //            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    //        }
    
}


- (void)saveSeenUser:(MessageSeenUser *)messageSeenBy
{
    NSManagedObjectContext *privateQueueContext = [self privateQueueContext];
    NSManagedObjectContext *mainQueueContext = [self managedObjectContext];
    
    NSEntityDescription *eDescription = [NSEntityDescription entityForName:@"MessageSeenByUser" inManagedObjectContext:mainQueueContext];
    __block NSError *error = nil;
    [privateQueueContext performBlockAndWait:^{
        NSManagedObject *seenUser = [[NSManagedObject alloc] initWithEntity:eDescription
                                             insertIntoManagedObjectContext:privateQueueContext];
        [seenUser setValue:messageSeenBy.userId forKey:@"userId"];
        [seenUser setValue:messageSeenBy.hostId forKey:@"hostId"];
        [seenUser setValue:messageSeenBy.conversationId forKey:@"conversationId"];
        [seenUser setValue:messageSeenBy.lastMessageId forKey:@"lastMessageId"];
        [seenUser setValue:messageSeenBy.orgId forKey:@"orgId"];
        [seenUser setValue:messageSeenBy.timeStamp forKey:@"timeStamp"];
        [seenUser setValue:messageSeenBy.rType forKey:@"rType"];
        if (![privateQueueContext save:&error]){
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"DoneSaving parent");
            if (![mainQueueContext save:&error]){
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
        });
    }];
    
}



-(void)updateSeenByUser:(MessageSeenUser *)messageSeenBy
{
    NSManagedObjectContext *context = [self privateQueueContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"MessageSeenByUser"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"userId == %@",messageSeenBy.userId];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"conversationId == %@",messageSeenBy.conversationId];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2]];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if (results.count > 0) {
        NSManagedObject* seenUser = [results lastObject];
        
        [seenUser setValue:messageSeenBy.userId forKey:@"userId"];
        [seenUser setValue:messageSeenBy.hostId forKey:@"hostId"];
        [seenUser setValue:messageSeenBy.conversationId forKey:@"conversationId"];
        [seenUser setValue:messageSeenBy.lastMessageId forKey:@"lastMessageId"];
        [seenUser setValue:messageSeenBy.orgId forKey:@"orgId"];
        [seenUser setValue:messageSeenBy.timeStamp forKey:@"timeStamp"];
        [seenUser setValue:messageSeenBy.rType forKey:@"rType"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
    else{
        
    }
}

- (BOOL)searchForSeenBy:(MessageSeenUser *)messageSeenBy
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"MessageSeenByUser"];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"conversationId == %@ AND lastMessageId == %@ AND userId == %@",messageSeenBy.conversationId,messageSeenBy.lastMessageId,messageSeenBy.userId];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1]];
    [fetchRequest setPredicate:predicate];
    
    NSManagedObjectContext *context = [self privateQueueContext];
    NSArray *results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    BOOL isFound = NO;
    if (results.count > 0) {
        isFound = YES;
    } else {
        isFound = NO;
    }
    return isFound;
}

-(NSMutableArray *)getMessageSeenByUsersWithMessageId:(NSString *)msgId andConversationId:(NSString *)conversationId
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageSeenByUser"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.conversationId == %@ AND SELF.lastMessageId == %@",conversationId,msgId];
    
    [fetchRequest setPredicate:predicate];
    fetchRequest.returnsDistinctResults = YES;
    
    NSMutableArray *seenByUsers = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSMutableArray *users = [[NSMutableArray alloc] init];
    
    if ([seenByUsers count]) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(NSManagedObject *Objc in seenByUsers) {
            
            NSString *userId = [Objc valueForKey:@"userId"];
            BOOL isAdded = NO;
            for (NSString *uId in array) {
                if ([uId isEqualToString:userId]) {
                    isAdded = YES;
                }
            }
            if (!isAdded) {
                ConversationUser *user = [[CoreDataController sharedManager]getUserWithID:userId];
                user.seen = [[MessageSeenUser alloc] initWithManagedObject:Objc];
                if (user) {
                    [users addObject:user];
                }
            }
            [array addObject:userId];
        }
    }
    
    return users;
}


@end
