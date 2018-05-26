//
//  ChatMessageCell.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 29/5/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface ChatMessageCell : UITableViewCell
@property (strong, nonatomic) IBOutlet AsyncImageView *readyByImg;
@property (strong, nonatomic) IBOutlet UILabel *readByTxt;
@property (strong, nonatomic) IBOutlet UILabel *readyByDateTxt;

@end
