//
//  FileSharingExpandedCell.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/4/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FileSharingExpandedCellDelegate <NSObject>
-(void)didTranslateMessagePressed:(RPConverstionMessage *)message atIndexPath:(NSIndexPath *)indexPath;
-(void)didShowMessageDetailsPressed:(RPConverstionMessage *)message;
-(void)didMakeCallPressed:(RPConverstionMessage *)message;
-(void)didCallDownloadFile:(RPConverstionMessage *)message;


@end


@interface FileSharingExpandedCell : UITableViewCell
@property (weak, nonatomic) id<FileSharingExpandedCellDelegate>delegate;

@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet AsyncImageView *fileImage;
@property (strong, nonatomic) IBOutlet AsyncImageView *downArrowImg;

@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIView *sepratorView;
@property (strong, nonatomic) IBOutlet UIView *blueBar;
@property (strong, nonatomic) IBOutlet UIView *orangeBar;

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UILabel *headerTitle;

@property (strong, nonatomic) IBOutlet UILabel *announcementTitle;

@property (strong, nonatomic) IBOutlet UILabel *contactTitle;

@property (weak, nonatomic) IBOutlet AsyncImageView *imgViewMessageStatus;
@property (weak, nonatomic) IBOutlet CircleProgressBar *seenByProgress;
@property (strong, nonatomic) IBOutlet UILabel *seenByLbl;


@property (strong, nonatomic) RPConverstionMessage *message;
@property (strong, nonatomic) MessageModel *conversation;
@property (assign, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadActivityIndicator;


@property (strong, nonatomic) IBOutlet AsyncImageView *profileImg;

- (void) customizeCell : (RPConverstionMessage*)message andIndexPath :(NSIndexPath*)indexPath andTimeStr : (NSString*)string;



@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *contactTxtLbl;



@end
