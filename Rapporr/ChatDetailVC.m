//
//  ChatDetailVC.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 29/5/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "ChatDetailVC.h"
#import "CreateTeamCollectionCell.h"

@interface ChatDetailVC ()

@end

@implementation ChatDetailVC
@synthesize conversation;



- (void)viewDidLoad {
    [super viewDidLoad];

    [self addFloatingButtonOnContact];
    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    [self.mainCollectionView registerNib:[UINib nibWithNibName:@"CreateTeamCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"CreateTeamCollectionCell"];
    
    ConversationUser *cUser = [[CoreDataController sharedManager] getUserWithID:conversation.startingUser];
    _startedByTxt.text = cUser.name;
    _startedByDateTxt.text = [NSDate dateTimeForMessageDetail:conversation.timeStamp];
    
    if(cUser.avatarUrl.length > 1) {
        NSURL *imageUrl = [NSURL URLWithString:cUser.avatarUrl];
        
        [_startedByImg setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    }
    else {
        [_startedByImg setImageWithString:cUser.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return conversation.members.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CreateTeamCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CreateTeamCollectionCell" forIndexPath:indexPath];
    
    ConversationUser *user = nil;
    user = [conversation.members objectAtIndex:indexPath.row];
    
    cell.titleLbl.text = user.name;
    
    if(user.avatarUrl.length > 1) {
        NSURL *imageUrl = [NSURL URLWithString:user.avatarUrl];
        
        [cell.mainImg setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        
    }
    else {
        [cell.mainImg setImageWithString:user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
    }
    cell.tickImg.hidden = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        return CGSizeMake(90, 90);
    }
    return CGSizeMake(CGRectGetWidth(collectionView.frame)/3 - 30, (CGRectGetWidth(collectionView.frame)/3  - 30));
}


- (CGSize)collectionViewContentSize
{
    NSInteger itemCount = [self.mainCollectionView numberOfItemsInSection:0];
    NSInteger pages = ceil(itemCount / 16.0);
    return CGSizeMake(self.mainCollectionView.frame.size.width ,320 * pages);
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - VCFloatingActionButton

- (void)addFloatingButtonOnContact {
    
    CGRect floatFrame = CGRectMake(self.view.bounds.size.width - 60 - 20, self.view.bounds.size.height - 80 , 60, 60);
    
    VCFloatingActionButton *addMenuButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:SET_IMAGE(@"createTeam") andPressedImage:SET_IMAGE(@"createTeam") withScrollview:self.mainCollectionView];
    
    addMenuButton.layer.shadowColor = [UIColor blackColor].CGColor;
    addMenuButton.layer.shadowOffset = CGSizeMake(1, 1);
    addMenuButton.layer.shadowOpacity = 0.3;
    addMenuButton.layer.shadowRadius = 2.0;
    addMenuButton.hideWhileScrolling = NO;
    addMenuButton.delegate = (id)self;
    addMenuButton.tag = 200;
    [self.view addSubview:addMenuButton];
}

-(void) didSelectMenuOptionAtIndex:(NSInteger)row
{
    
}


-(void)didNewMembersSelected:(NSMutableArray *)users;
{
    [self.delegate didNewMembersSelected:users];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) didMenuButtonTapped:(id)button;
{
    VCFloatingActionButton *btn = (VCFloatingActionButton*)button;
    
    if (btn.tag == 200){
        
        NSPredicate *Predicate = [NSPredicate predicateWithFormat:@"SELF.fullId contains[cd] %@",[RapporrManager sharedManager].vcModel.userId];
        
        NSArray *currentUser = [self.conversation.members filteredArrayUsingPredicate:Predicate];
        
        if ([currentUser count]) {
            
            ConversationUser *user = [currentUser lastObject];
            if ([user.fullId isEqualToString:self.conversation.startingUser] || [user.uType isEqualToString:kUSER_TYPE_ADMIN]) {
                
                AddNewMemberVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddNewMemberVC"];
                vc.conversation = self.conversation;
                vc.delegate = (id)self;
                
                [self presentViewController:vc animated:NO completion:^{
                    
                }];
            }
            else{
                
                [self setUpAlertView];
                _customAlert.alertTag = 10002;
                _customAlert.alertType = kAlertTypePopup;
                NSString *message = [NSString stringWithFormat:@"Only the creator of a conversation or admin can people"];
                [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Error",nil) andDescription:NSLocalizedString(message,nil)];
            }
        }else{
            
            [self setUpAlertView];
            _customAlert.alertTag = 10002;
            _customAlert.alertType = kAlertTypePopup;
            NSString *message = [NSString stringWithFormat:@"Only the creator of a conversation or admin can people"];
            [self.customAlert showPopUpInView:self.view withMessage:NSLocalizedString(@"Error",nil) andDescription:NSLocalizedString(message,nil)];
        }
    }
}

- (void) setUpAlertView {
    _customAlert = [[RapporrAlertView alloc] init];
    [_customAlert setDelegate:(id)self];
}


-(void)RapporrAlertOK:(id)sender {
    
    [_customAlert removeCustomAlertFromViewInstantly];
}

-(void)RapporrAlertCancel{
    
    [_customAlert removeCustomAlertFromViewInstantly];
}


#pragma mark - Network Status
-(void)didNetworkConnected:(AFNetworkReachabilityStatus)status;{
    self.seachabilityStatus = status;
    [RKDropdownAlert dismissAllAlert];

}

-(void)didNetworkDisconnected:(AFNetworkReachabilityStatus)status;{
    self.seachabilityStatus = status;
    [RKDropdownAlert dismissAllAlert];
    [appDelegate showAlertView];
}


@end
