//
//  PictureCell.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/4/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PictureCellDelegate <NSObject>
-(void)didTranslateMessagePressed:(RPConverstionMessage *)message atIndexPath:(NSIndexPath *)indexPath;
-(void)didShowMessageDetailsPressed:(RPConverstionMessage *)message;
-(void)didMakeCallPressed:(RPConverstionMessage *)message;
@end


@interface PictureCell : UITableViewCell
@property (weak, nonatomic) id<PictureCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet AsyncImageView *profileImg;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet AsyncImageView *downArrowImg;
@property (weak, nonatomic) IBOutlet UIView *sepratorView;
@property (weak, nonatomic) IBOutlet UIView *blueBar;
@property (weak, nonatomic) IBOutlet UIView *orangeBar;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;
@property (weak, nonatomic) IBOutlet UIImageView *announcementImg;


@property (weak, nonatomic) IBOutlet AsyncImageView *imgViewMessageStatus;
@property (weak, nonatomic) IBOutlet CircleProgressBar *seenByProgress;
@property (weak, nonatomic) IBOutlet UILabel *seenByLbl;

@property (weak, nonatomic) RPConverstionMessage *message;
@property (weak, nonatomic) MessageModel *conversation;
@property (assign, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) UIViewController *context;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *contactTxtLbl;


- (void) customizeCell : (RPConverstionMessage*)message andIndexPath :(NSIndexPath*)indexPath andTimeStr : (NSString*)string;


@end
