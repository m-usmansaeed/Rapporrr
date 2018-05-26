//
//  CreateTeamCollectionCell.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 25/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateTeamCollectionCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *mainImg;
@property (strong, nonatomic) IBOutlet UIImageView *tickImg;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *contactTxtLbl;

@end
