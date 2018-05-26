//
//  UnReadCollectionCell.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/6/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnReadCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet AsyncImageView *imageView;

@end
