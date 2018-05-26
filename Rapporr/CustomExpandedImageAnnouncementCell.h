//
//  CustomExpandedImageAnnouncementCellTableViewCell.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/3/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleProgressBar.h"
#import "FRHyperLabel.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UIImageView+AnimationCompletion.h"
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"
#import "AsyncImageView.h"

@protocol CustomExpandedImageAnnouncementCellDelegate <NSObject>
-(void)didTranslateMessagePressed:(RPConverstionMessage *)message atIndexPath:(NSIndexPath *)indexPath;
-(void)didShowMessageDetailsPressed:(RPConverstionMessage *)message;
-(void)didMakeCallPressed:(RPConverstionMessage *)message;
@end


@interface CustomExpandedImageAnnouncementCell : UITableViewCell

@property (weak, nonatomic) id<CustomExpandedImageAnnouncementCellDelegate>delegate;

@property (strong, nonatomic) IBOutlet AsyncImageView *profileImg;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (strong, nonatomic) IBOutlet UILabel *detailTxt;
@property (strong, nonatomic) IBOutlet AsyncImageView *downArrowImg;
@property (strong, nonatomic) IBOutlet UIView *sepratorView;
@property (strong, nonatomic) IBOutlet UIView *blueBar;
@property (strong, nonatomic) IBOutlet UIView *orangeBar;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UILabel *headerTitle;
@property (strong, nonatomic) IBOutlet UIImageView *announcementImg;
@property (strong, nonatomic) IBOutlet UILabel *announcementTitle;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet UILabel *seenByLbl;
@property (weak, nonatomic) IBOutlet AsyncImageView *imgViewMessageStatus;
@property (weak, nonatomic) IBOutlet CircleProgressBar *seenByProgress;
@property (strong, nonatomic) UIViewController *context;


@property (strong, nonatomic) RPConverstionMessage *message;
@property (strong, nonatomic) MessageModel *conversation;
@property (assign, nonatomic) NSIndexPath *indexPath;


- (void) customizeCell : (RPConverstionMessage*)message andIndexPath :(NSIndexPath*)indexPath andTimeStr : (NSString*)string;

@end
