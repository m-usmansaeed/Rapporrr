//
//  TeamModel.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 25/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "TeamModel.h"

@implementation TeamModel

- (id)initWithDictionary:(NSDictionary *) responseData {
    
    self = [super init];
    if (self) {
        
        self.isActive = [responseData[@"Active"] boolValue];
        self.callBackId = [NSString validStringForObject:responseData[@"CallBackId"]];
        self.gType = [NSString validStringForObject:responseData[@"GType"]];
        self.groupId = [NSString validStringForObject:responseData[@"GroupId"]];
        self.hostId = [NSString validStringForObject:responseData[@"HostId"]];
        self.name = [[NSString validStringForObject:responseData[@"Name"]] capitalizedString];
        self.usersString = [NSString validStringForObject:responseData[@"Objects"]];
        self.orgId = [NSString validStringForObject:responseData[@"OrgId"]];
        self.publicID = [NSString validStringForObject:responseData[@"PublicID"]];
        self.recType = [NSString validStringForObject:responseData[@"RecType"]];
        self.status = [NSString validStringForObject:responseData[@"Status"]];
        
        if([[self validStringForObject:responseData[@"Status"]] isEqualToString:@"active"]){
            self.teamStatus = kTeamActive;
        }else if([[self validStringForObject:responseData[@"Status"]] isEqualToString:@"inactive"]){
            self.teamStatus = kTeamInactive;
        }
        
        self.timeStamp = [self validStringForObject:responseData[@"TimeStamp"]];
        self.userId = [self validStringForObject:responseData[@"UserId"]];
        
        if ([self.usersString containsString:@"users"]) {
            NSDictionary *usersDict = [Utils dictionaryFromJson:self.usersString];
            self.usersIdArray = [usersDict valueForKey:@"users"];
        } else {
            self.usersIdArray = [Utils arrayFromString:self.usersString];
        }
    }
    
    return self;
}

- (id)initWithManagedObject:(NSManagedObject *) teamObject {
    self = [super init];
   
    if (self) {
        
        self.isActive = [[teamObject valueForKey:@"isActive"] boolValue];
        self.callBackId = [teamObject valueForKey:@"callBackId"];
        self.gType = [teamObject valueForKey:@"gType"];
        self.groupId = [teamObject valueForKey:@"groupId"];
        self.hostId = [teamObject valueForKey:@"hostId"];
        self.name = [[teamObject valueForKey:@"name"] capitalizedString];
        self.orgId = [teamObject valueForKey:@"orgId"];
        self.publicID = [teamObject valueForKey:@"publicID"];
        self.recType = [teamObject valueForKey:@"recType"];
        self.status = [teamObject valueForKey:@"status"];
        self.timeStamp = [teamObject valueForKey:@"timeStamp"];
        self.userId = [teamObject valueForKey:@"userId"];
        self.usersString  = [teamObject valueForKey:@"users"];
        self.usersIdArray = [teamObject valueForKey:@"users"];
        
        if([self.status isEqualToString:@"active"]){
            self.teamStatus = kTeamActive;
        }else if([self.status isEqualToString:@"inactive"]){
            self.teamStatus = kTeamInactive;
        }

        self.members = [[NSMutableArray alloc]init];
        for (NSString *user in self.usersIdArray) {
            ConversationUser *cObj = [[CoreDataController sharedManager] getUserWithID:user];
            if(!cObj.disabled) {
                NSLog(@"%@",cObj);
                if (cObj != nil) {
                    [self.members addObject:cObj];
                }
            }
        }
        self.membersListString = [self getTeamUsers:[self.usersIdArray mutableCopy] team:self];
    }
    
    return self;
}


-(NSString *)getTeamUsers:(NSMutableArray *)array team:(TeamModel *)team{
    
    NSString *users = @"";

    ConversationUser *adminUser = nil;
    NSArray *adminUserArr = [team.members filteredArrayUsingPredicate:
                             [NSPredicate predicateWithFormat:@"SELF.fullId ==[c] %@", team.userId]];
    
    if ([adminUserArr count]) {
        adminUser = [adminUserArr objectAtIndex:0];
        users = [NSString stringWithFormat:@"%@*",adminUser.fName];
    }
    
    for (ConversationUser *user in team.members) {
        if (![adminUser.fullId isEqualToString:user.fullId]) {
            if(users.length>0){
                users = [NSString stringWithFormat:@"%@, %@",users,user.fName];
            }else{
                users = [NSString stringWithFormat:@"%@",user.fName];
            }
        }
    }
    
    return users;
}


@end
