//
//  CustomChatTextCell.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 2/6/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseChatCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CircleProgressBar.h"
#import "FRHyperLabel.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UIImageView+AnimationCompletion.h"
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"


@protocol CustomChatTextCellDelegate <NSObject>
-(void)didTranslateMessagePressed:(RPConverstionMessage *)message atIndexPath:(NSIndexPath *)indexPath;
-(void)didShowMessageDetailsPressed:(RPConverstionMessage *)message;
-(void)didMakeCallPressed:(RPConverstionMessage *)message;
@end

@interface CustomChatTextCell : BaseChatCell

@property (weak, nonatomic) id<CustomChatTextCellDelegate>delegate;

@property (strong, nonatomic) IBOutlet AsyncImageView *profileImg;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (strong, nonatomic) IBOutlet UITextView *detailTxt;
@property (strong, nonatomic) IBOutlet AsyncImageView *downArrowImg;
@property (strong, nonatomic) IBOutlet UIView *sepratorView;
@property (strong, nonatomic) IBOutlet UIView *blueBar;
@property (strong, nonatomic) IBOutlet UIView *orangeBar;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UILabel *headerTitle;
@property (weak, nonatomic) IBOutlet AsyncImageView *imgViewMessageStatus;
@property (weak, nonatomic) IBOutlet CircleProgressBar *seenByProgress;
@property (strong, nonatomic) IBOutlet UILabel *seenByLbl;

@property (strong, nonatomic) RPConverstionMessage *message;
@property (strong, nonatomic) MessageModel *conversation;
@property (assign, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) UIViewController *context;

@property (weak, nonatomic) IBOutlet UITextView *lblTranslation;
@property (weak, nonatomic) IBOutlet UILabel *contactTxtLbl;



@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void) customizeCell : (RPConverstionMessage*)message andIndexPath :(NSIndexPath*)indexPath andTimeStr : (NSString*)string ;

@end
