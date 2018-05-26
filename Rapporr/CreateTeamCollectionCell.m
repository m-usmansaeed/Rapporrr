//
//  CreateTeamCollectionCell.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 25/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "CreateTeamCollectionCell.h"

@implementation CreateTeamCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    self.mainImg.image = NULL;
    [self.mainImg sd_cancelCurrentImageLoad];
    
}

@end
