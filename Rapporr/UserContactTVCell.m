//
//  UserContactTVCell.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 24/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "UserContactTVCell.h"

@implementation UserContactTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    self.imgViewUserAvatar.image = NULL;
    [_imgViewUserAvatar sd_cancelCurrentImageLoad];
    
}

-(void)configureCell
{
    
    if ([self.objc isKindOfClass:[ConversationUser class]]) {
        
        ConversationUser *user = (ConversationUser *)self.objc;
        if(user.avatarUrl.length > 1) {
            
            NSURL *imageUrl = [NSURL URLWithString:user.avatarUrl];
            [self.imgViewUserAvatar sd_setImageWithURLWithProgress:imageUrl];
            self.contactTxtLbl.hidden = true;
        }
        else {
            self.contactTxtLbl.text = [Utils getInitialsFromString:user.name];
            self.contactTxtLbl.hidden = false;
            self.contactTxtLbl.backgroundColor = [UIColor colorFromHexCode:@"#FF9433"];
        }
        
        self.lblFirstName.text = [NSString stringWithFormat:@"%@",user.name];
        self.lblUserJobDesc.text = [NSString stringWithFormat:@"%@",user.jobTitle];
    }else{
        
        TeamModel *team = (TeamModel *)self.objc;
        if(team.avatarUrl.length > 1) {
            
            NSURL *imageUrl = [NSURL URLWithString:team.avatarUrl];
            [self.imgViewUserAvatar sd_setImageWithURLWithProgress:imageUrl];
            self.txtLbl.hidden = true;
            
        }
        else {
            self.imgViewUserAvatar.backgroundColor = [UIColor colorFromHexCode:@"#FF9433"];
            self.txtLbl.text = [Utils getInitialsFromString:team.name];
            self.txtLbl.hidden = false;
        }
        self.lblFirstName.text = [NSString stringWithFormat:@"%@",team.name];
        self.lblUserJobDesc.text = [NSString stringWithFormat:@"%@",[self getTeamUsers:[team.usersIdArray mutableCopy]]];
    }
    
}

- (IBAction)btnMessagePressed:(id)sender {
    
    if ([self.objc isKindOfClass:[ConversationUser class]]) {
        ConversationUser *user = (ConversationUser *)self.objc;
        if (self.userContactTVCellDelegate && [self.userContactTVCellDelegate respondsToSelector:@selector(didMessageButtonPressed:)]) {
            [self.userContactTVCellDelegate didMessageButtonPressed:user];
        }
    }
}

- (IBAction)btnCallPressed:(id)sender {
    
    if ([self.objc isKindOfClass:[ConversationUser class]]) {
        ConversationUser *user = (ConversationUser *)self.objc;
        if (self.userContactTVCellDelegate && [self.userContactTVCellDelegate respondsToSelector:@selector(didCallButtonPressed:)]) {
            [self.userContactTVCellDelegate didCallButtonPressed:user];
        }
    }
}

- (IBAction)btnProfilePressed:(id)sender {
    
    if ([self.objc isKindOfClass:[ConversationUser class]]) {
        ConversationUser *user = (ConversationUser *)self.objc;
        if ([self.userContactTVCellDelegate respondsToSelector:@selector(didProfileButtonPressed:)]) {
            [self.userContactTVCellDelegate didProfileButtonPressed:user];
        }
    }
}

-(NSString *)getTeamUsers:(NSMutableArray *)array{
    
    NSString *users = @"";
    TeamModel *team = (TeamModel *)self.objc;
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
