//
//  PictureExpandedCell.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/4/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PictureExpandedCellDelegate <NSObject>
-(void)didTranslateMessagePressed:(RPConverstionMessage *)message atIndexPath:(NSIndexPath *)indexPath;
-(void)didShowMessageDetailsPressed:(RPConverstionMessage *)message;
-(void)didMakeCallPressed:(RPConverstionMessage *)message;
@end



@interface PictureExpandedCell : UITableViewCell
@property (weak, nonatomic) id<PictureExpandedCellDelegate>delegate;

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
@property (weak, nonatomic) IBOutlet UIView *bottomView;


@property (weak, nonatomic) IBOutlet AsyncImageView *imgViewMessageStatus;
@property (weak, nonatomic) IBOutlet CircleProgressBar *seenByProgress;
@property (weak, nonatomic) IBOutlet UILabel *seenByLbl;
@property (weak, nonatomic) IBOutlet UILabel *contactTxtLbl;

@property (strong, nonatomic) RPConverstionMessage *message;
@property (strong, nonatomic) MessageModel *conversation;
@property (assign, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UIViewController *context;


- (void) customizeCell : (RPConverstionMessage*)message andIndexPath :(NSIndexPath*)indexPath andTimeStr : (NSString*)string;


@end
