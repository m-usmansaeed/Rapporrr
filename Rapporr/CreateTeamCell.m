//
//  CreateTeamCell.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 25/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "CreateTeamCell.h"

@implementation CreateTeamCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    
    return self;
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    self.mainImg.image = NULL;
    [self.mainImg sd_cancelCurrentImageLoad];
    
}


@end
