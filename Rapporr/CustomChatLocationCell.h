//
//  CustomChatLocationCell.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 3/6/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomChatLocationCellDelegate <NSObject>
-(void)didTranslateMessagePressed:(RPConverstionMessage *)message atIndexPath:(NSIndexPath *)indexPath;
-(void)didShowMessageDetailsPressed:(RPConverstionMessage *)message;
-(void)didMakeCallPressed:(RPConverstionMessage *)message;
@end


@interface CustomChatLocationCell : UITableViewCell {
    NSString *latitude;
    NSString *longitude;
}
@property (strong, nonatomic) IBOutlet AsyncImageView *imgView;

@property (weak, nonatomic) id<CustomChatLocationCellDelegate>delegate;

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
@property (strong, nonatomic) IBOutlet MKMapView *locMap;

@property (weak, nonatomic) IBOutlet AsyncImageView *imgViewMessageStatus;
@property (weak, nonatomic) IBOutlet CircleProgressBar *seenByProgress;
@property (strong, nonatomic) IBOutlet UILabel *seenByLbl;
@property (weak, nonatomic) IBOutlet UILabel *contactTxtLbl;


@property(nonatomic, retain) CLLocationManager *locationManager;

@property (strong, nonatomic) RPConverstionMessage *message;
@property (strong, nonatomic) MessageModel *conversation;
@property (assign, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;


- (void) customizeCell : (RPConverstionMessage*)message andIndexPath :(NSIndexPath*)indexPath andTimeStr : (NSString*)string;

@end
