//
//  FileAttachmentCell.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/31/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleProgressBar.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UIImageView+AnimationCompletion.h"
#import "DGActivityIndicatorView.h"


@protocol FileAttachmentCellDelegate <NSObject>

-(void)didTranslateMessagePressed:(RPConverstionMessage *)message atIndexPath:(NSIndexPath *)indexPath;
-(void)didShowMessageDetailsPressed:(RPConverstionMessage *)message;
-(void)didMakeCallPressed:(RPConverstionMessage *)message;
-(void)didCallDownloadFile:(RPConverstionMessage *)message;



@end

@interface FileAttachmentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *fileTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblSeenBy;
@property (weak, nonatomic) IBOutlet UIImageView *avtarImgView;
@property (weak, nonatomic) IBOutlet CircleProgressBar *seenByProgress;

@property (weak, nonatomic) IBOutlet UIImageView *successImageView;
@property (weak, nonatomic) IBOutlet UIView *prgressViewContainer;

@property (weak, nonatomic) IBOutlet UIView *buttonViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnDown;

@property (assign, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) id objc;
@property (strong, nonatomic) MessageModel *conversation;

@property (strong, nonatomic) UIViewController *context;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UILabel *headerTitleLbl;

@property (strong, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet UIButton *btnMessageDetails;


-(void)configureCell:(FileAttachmentCell *)cell;

- (IBAction)btnTranslate:(id)sender;
- (IBAction)btnMessageDetails:(id)sender;
- (IBAction)btnMakeCall:(id)sender;
- (IBAction)btnDownloadFile:(id)sender;

@property (weak, nonatomic) id<FileAttachmentCellDelegate>delegate;


@property (weak, nonatomic) IBOutlet UIView *messageContainer;
@property (weak, nonatomic) IBOutlet UIView *rightSeparator;
@property (weak, nonatomic) IBOutlet UIView *leftSeparator;

@property (nonatomic) BOOL isNewMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewfile;

@property (weak, nonatomic) IBOutlet UIView *spinner;
@property (strong,nonatomic) DGActivityIndicatorView *activityIndicatorView;



@end
