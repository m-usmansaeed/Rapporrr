//
//  LocationExtandedCell.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/3/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationExtandedCellDelegate <NSObject>
-(void)didTranslateMessagePressed:(RPConverstionMessage *)message atIndexPath:(NSIndexPath *)indexPath;
-(void)didShowMessageDetailsPressed:(RPConverstionMessage *)message;
-(void)didMakeCallPressed:(RPConverstionMessage *)message;
@end


@interface LocationExtandedCell : UITableViewCell {
    NSString *latitude;
    NSString *longitude;
}

@property (weak, nonatomic) id<LocationExtandedCellDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet AsyncImageView *profileImg;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (strong, nonatomic) IBOutlet AsyncImageView *downArrowImg;
@property (strong, nonatomic) IBOutlet UIView *sepratorView;
@property (strong, nonatomic) IBOutlet UIView *blueBar;
@property (strong, nonatomic) IBOutlet UIView *orangeBar;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UILabel *headerTitle;
@property (strong, nonatomic) IBOutlet UILabel *announcementTitle;
@property (strong, nonatomic) IBOutlet UILabel *addressLbl;

@property (weak, nonatomic) IBOutlet AsyncImageView *imgViewMessageStatus;
@property (weak, nonatomic) IBOutlet CircleProgressBar *seenByProgress;
@property (strong, nonatomic) IBOutlet UILabel *seenByLbl;


@property (strong, nonatomic) RPConverstionMessage *message;
@property (strong, nonatomic) MessageModel *conversation;
@property (assign, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;
@property (weak, nonatomic) IBOutlet UILabel *contactTxtLbl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


- (void) customizeCell : (RPConverstionMessage*)message andIndexPath :(NSIndexPath*)indexPath andTimeStr : (NSString*)string;




@end
