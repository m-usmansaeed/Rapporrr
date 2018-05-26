//
//  ChatMessageDetailVC.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 29/5/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "RPConverstionMessage.h"
#import "UnReadCollectionCell.h"


@interface ChatMessageDetailVC : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *chatTitle;
@property (strong, nonatomic) IBOutlet UILabel *sentBtNameTxt;
@property (strong, nonatomic) IBOutlet UILabel *sentByDateTime;
@property (strong, nonatomic) IBOutlet AsyncImageView *sentByImgView;

@property (strong, nonatomic) IBOutlet UITableView *mainTblView;

@property (strong, nonatomic) RPConverstionMessage *message;
@property (strong, nonatomic) MessageModel *conversation;

//-----
@property (weak, nonatomic) IBOutlet UIView *tableContainer;
@property (weak, nonatomic) IBOutlet UIView *collectionContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *array;
@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;


@end
