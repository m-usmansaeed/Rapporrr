//
//  ConversationMessageCell.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 17/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleProgressBar.h"
#import "FRHyperLabel.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UIImageView+AnimationCompletion.h"
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"

@protocol ConversationMessageCellDelegate <NSObject>
-(void)didTranslateMessagePressed:(RPConverstionMessage *)message atIndexPath:(NSIndexPath *)indexPath;
-(void)didShowMessageDetailsPressed:(RPConverstionMessage *)message;
-(void)didMakeCallPressed:(RPConverstionMessage *)message;
@end

@interface ConversationMessageCell : UITableViewCell

@property (weak, nonatomic) id<ConversationMessageCellDelegate>delegate;


@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMeggage;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblSeenBy;
@property (weak, nonatomic) IBOutlet UIImageView *avtarImgView;

@property (weak, nonatomic) IBOutlet UIImageView *messageImageView;


@property (weak, nonatomic) IBOutlet CircleProgressBar *seenByProgress1;


@property (weak, nonatomic) IBOutlet UIImageView *successImageView;

@property (weak, nonatomic) IBOutlet UIView *prgressViewContainer;

@property (weak, nonatomic) IBOutlet UIView *buttonViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnDown;
@property (weak, nonatomic) IBOutlet UILabel *lblTranslation;
@property (weak, nonatomic) IBOutlet UITextView *txtViewTranslation;

@property (assign, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) id objc;
@property (strong, nonatomic) MessageModel *conversation;

@property (strong, nonatomic) UIViewController *context;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UILabel *headerTitleLbl;

@property (strong, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet UIButton *btnMessageDetails;


typedef void (^DidUpdateViewBlock)(NSIndexPath *indexPath);
@property (copy, nonatomic) DidUpdateViewBlock didUpdateViewBlock;
-(void)configureCell:(ConversationMessageCell *)cell;

- (IBAction)btnTranslate:(id)sender;
- (IBAction)btnMessageDetails:(id)sender;
- (IBAction)btnMakeCall:(id)sender;



@property (weak, nonatomic) IBOutlet UIView *messageContainer;
@property (weak, nonatomic) IBOutlet UIView *rightSeparator;
@property (weak, nonatomic) IBOutlet UIView *leftSeparator;

//Event Type
@property (weak, nonatomic) IBOutlet UIView *eventView;
@property (weak, nonatomic) IBOutlet UILabel *lblEventTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblEventDescription;
@property (weak, nonatomic) IBOutlet FRHyperLabel *eventUrl;


//Contact Type
@property (weak, nonatomic) IBOutlet UIView *contactView;
@property (weak, nonatomic) IBOutlet UILabel *lblContactTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblContactNumber;


@property (nonatomic) BOOL isNewMessage;






@end
