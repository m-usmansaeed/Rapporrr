//
//  CreateTeamCell.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 25/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface CreateTeamCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *jobTitleLbl;
@property (strong, nonatomic) IBOutlet UIImageView *tickImg;
@property (strong, nonatomic) IBOutlet AsyncImageView *mainImg;
@property (weak, nonatomic) IBOutlet UILabel *contactTxtLbl;

@end
