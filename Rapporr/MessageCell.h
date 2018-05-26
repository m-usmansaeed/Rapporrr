//
//  MessageCell.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 07/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "SWTableViewCell.h"

@interface MessageCell : SWTableViewCell
@property (strong, nonatomic) IBOutlet AsyncImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (strong, nonatomic) IBOutlet UILabel *subTitle1Lbl;
@property (strong, nonatomic) IBOutlet UILabel *subTitle2Lbl;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPinConv;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberUsers;

@property (weak, nonatomic) IBOutlet UIView *rightBar;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end
