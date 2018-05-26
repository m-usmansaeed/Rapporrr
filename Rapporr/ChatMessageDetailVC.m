//
//  ChatMessageDetailVC.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 29/5/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "ChatMessageDetailVC.h"
#import "ChatMessageCell.h"
#import "ConversationUser.h"

@interface ChatMessageDetailVC ()

@end

@implementation ChatMessageDetailVC
@synthesize message;
- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate.delegate = (id)self;
    self.seachabilityStatus = appDelegate.seachabilityStatus;

    _sentBtNameTxt.text = message.senderName;
    _sentByDateTime.text = [NSDate dateTimeForMessageDetail:message.timeStamp];
    _chatTitle.text = self.conversation.about;
    
    if (message.user.avatarImage) {
        [_sentByImgView setImage:message.user.avatarImage];
    }
    else if (message.user.avatarUrl.length > 1) {
       
        NSURL *imageUrl = [NSURL URLWithString:message.user.avatarUrl];
        
        [_sentByImgView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    else{
        
        [_sentByImgView setImageWithString:message.user.name color:[UIColor colorFromHexCode:@"#FD9527"] circular:NO];
    }
    
    BOOL isSelfSeen = NO;
    BOOL isSenderSeen = NO;
    
    for (ConversationUser *user in message.seenByUsers) {
        if ([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]) {
            isSelfSeen = YES;
        }
    }
    
    if (!isSelfSeen) {
        
        ConversationUser *user = [[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId];
        user.seen = [self addSelfAsSeenUser:message.timeStamp withUserId:[RapporrManager sharedManager].vcModel.userId];
        [message.seenByUsers addObject:user];
    }

    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"SELF.fullId CONTAINS[cd] %@", [RapporrManager sharedManager].vcModel.userId];
    
    
    
    NSArray *arrFiltered = [message.seenByUsers filteredArrayUsingPredicate:predicate];
    if ([arrFiltered count]) {
       
    }else{
        
//        BOOL isSelfSeen = NO;
//        BOOL isSenderSeen = NO;
//        
//        for (ConversationUser *user in message.seenByUsers) {
//            if ([user.fullId isEqualToString:[RapporrManager sharedManager].vcModel.userId]) {
//                isSelfSeen = YES;
//            }
//        }
//        
//        if (!isSelfSeen) {
//            
//            ConversationUser *user = [[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId];
//            user.seen = [self addSelfAsSeenUser:message.timeStamp withUserId:[RapporrManager sharedManager].vcModel.userId];
//            [message.seenByUsers addObject:user];
//        }

        
//        [message.seenByUsers addObject:[[CoreDataController sharedManager] getUserWithID:[RapporrManager sharedManager].vcModel.userId]];
        
//        for (ConversationUser *user in message.seenByUsers) {
//            if ([user.fullId isEqualToString:message.user.fullId]) {
//                user.seen.timeStamp = message.timeStamp;
//            }
//        }
    }

    
    self.array = [[NSMutableArray alloc] init];
    
    for (ConversationUser *user in self.conversation.members) {
        [self.array addObject:user];
    }

    NSMutableArray *seenUsers = [[NSMutableArray alloc] init];
    
    for (ConversationUser *seenuser in message.seenByUsers) {
        for (ConversationUser *auser in self.array) {
            if ([seenuser.fullId isEqualToString:auser.fullId]) {
                [seenUsers addObject:auser];
            }
        }
    }
    
    
    message.seenByUsers = [[message.seenByUsers sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                                            ascending:YES
                                                                                                             selector:@selector(caseInsensitiveCompare:)]]] mutableCopy];
    [self.array removeObjectsInArray:seenUsers];
    
    
    self.array = [[self.array sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                          ascending:YES
                                                                                           selector:@selector(caseInsensitiveCompare:)]]] mutableCopy];

    
    [self.collectionView registerNib:[UINib nibWithNibName:@"UnReadCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"UnReadCollectionCell"];
    
    if (message.user.avatarImage) {
        [_sentByImgView setImage:message.user.avatarImage];
    }
    else if (message.user.avatarUrl.length > 1) {
        NSURL *imageUrl = [NSURL URLWithString:message.user.avatarUrl];
        [_sentByImgView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    }
    else{
        [_sentByImgView setImageWithString:message.user.name color:[UIColor colorFromHexCode:@"#FD9527"] circular:NO];
    }
    
    
    CGRect tableFrame = self.tableContainer.frame;
    tableFrame.size.height = (message.seenByUsers.count * 60) + 32;
    self.tableContainer.frame = tableFrame;
    CGRect collectionFrame = self.collectionContainer.frame;
    collectionFrame.origin.y = tableFrame.size.height + tableFrame.origin.y + 21;
    collectionFrame.size.height = (self.array.count/2 * 60) + 250;
    self.collectionContainer.frame = collectionFrame;
    float scrollHeight = tableFrame.size.height + collectionFrame.size.height + 200;
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollHeight)];

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

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    
    return message.seenByUsers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;{
    
    ChatMessageCell * cell = (ChatMessageCell *)[_mainTblView dequeueReusableCellWithIdentifier:@"ChatMessageCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"ChatMessageCell" owner:self options:nil];
        cell=[nib objectAtIndex:0];
    }
    ConversationUser *cUser = (ConversationUser*)[message.seenByUsers objectAtIndex:indexPath.row];
    cell.readByTxt.text = [NSString stringWithFormat:@"%@ %@",cUser.fName,cUser.lName];
    cell.readyByDateTxt.text = [NSDate dateTimeSeenUsers:cUser.seen.timeStamp];
    if (cUser.avatarImage) {
        [cell.readyByImg setImage:cUser.avatarImage];
    }
    else if (cUser.avatarUrl.length > 1) {
        NSURL *imageUrl = [NSURL URLWithString:cUser.avatarUrl];
        [cell.readyByImg setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    }
    else{
        [cell.readyByImg setImageWithString:cUser.name color:[UIColor colorFromHexCode:@"#FD9527"] circular:NO];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}


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
    return self.array.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UnReadCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UnReadCollectionCell" forIndexPath:indexPath];
    
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"UnReadCollectionCell" owner:self options:nil];
        cell=[nib objectAtIndex:0];
    }
    
    
    ConversationUser *user = nil;
    user = [self.array objectAtIndex:indexPath.row];
    
    cell.title.text = user.name;
    
    if(user.avatarUrl.length > 1) {
        NSURL *imageUrl = [NSURL URLWithString:user.avatarUrl];
        [cell.imageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder_user"] options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    }
    else {
        [cell.imageView setImageWithString:user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
    }
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(CGRectGetWidth(collectionView.frame)/2 -10, 60);
    return size;
}


- (CGSize)collectionViewContentSize
{
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger pages = ceil(itemCount / 16.0);
    return CGSizeMake(self.collectionView.frame.size.width ,320 * pages);
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

-(MessageSeenUser *)addSelfAsSeenUser:(NSString *)withTimestamp withUserId:(NSString *)userId
{
    
    RPConverstionMessage *lastMessage = [self.conversation.messages lastObject];
    NSString *lastMessageId = lastMessage.msgId;
    
    MessageSeenUser *seenUser = [[MessageSeenUser alloc] init];
    seenUser.userId = [NSString stringWithFormat:@"%@",userId];
    seenUser.conversationId = [NSString stringWithFormat:@"%@",self.conversation.conversationId];
    seenUser.hostId = [NSString stringWithFormat:@"%@",[RapporrManager sharedManager].vcModel.hostID];
    seenUser.lastMessageId = [NSString stringWithFormat:@"%@",lastMessageId];
    seenUser.orgId = [NSString stringWithFormat:@"%@",[RapporrManager sharedManager].vcModel.orgId];
    seenUser.rType = @"MESSAGE";
    seenUser.timeStamp = [NSString stringWithFormat:@"%@",withTimestamp];
    
    return seenUser;
}

@end
