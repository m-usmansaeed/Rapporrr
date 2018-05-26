//
//  ChatDetailVC.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 29/5/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatDetailVCDelegate <NSObject>

-(void)didNewMembersSelected:(NSMutableArray *)users;

@end


@interface ChatDetailVC : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *startedByTxt;
@property (strong, nonatomic) IBOutlet UILabel *startedByDateTxt;
@property (strong, nonatomic) IBOutlet AsyncImageView *startedByImg;

@property (strong, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property(strong, nonatomic) MessageModel *conversation;
@property (weak, nonatomic) id<ChatDetailVCDelegate>delegate;


@property (nonatomic, strong) RapporrAlertView *customAlert;

@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end
