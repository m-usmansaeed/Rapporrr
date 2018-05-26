//
//  UserProfileCell.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/19/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "UserProfileCell.h"

@implementation UserProfileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (BOOL) becomeFirstResponder {
    return [self.txtField becomeFirstResponder];
}

@end
