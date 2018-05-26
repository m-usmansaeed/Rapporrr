//
//  UserContactTVCell.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 24/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConversationUser.h"
#import "SWTableViewCell.h"



@protocol UserContactTVCellDelegate <NSObject>

-(void)didMessageButtonPressed:(ConversationUser *)user;
-(void)didCallButtonPressed:(ConversationUser *)user;
-(void)didProfileButtonPressed:(ConversationUser *)user;

@end


@interface UserContactTVCell : SWTableViewCell

@property (weak,nonatomic) id<UserContactTVCellDelegate>userContactTVCellDelegate;


@property (weak, nonatomic) IBOutlet UILabel *lblFirstName;
@property (weak, nonatomic) IBOutlet UILabel *lblUserJobDesc;
@property (weak, nonatomic) IBOutlet AsyncImageView *imgViewUserAvatar;

@property (strong, nonatomic) IBOutlet UILabel *txtLbl;
@property (strong, nonatomic) IBOutlet UILabel *contactTxtLbl;


@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) id objc;
@property (strong, nonatomic) NSMutableArray *users;

-(void)configureCell;

- (IBAction)btnMessagePressed:(id)sender;
- (IBAction)btnCallPressed:(id)sender;
- (IBAction)btnProfilePressed:(id)sender;

@end
