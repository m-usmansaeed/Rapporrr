//
//  CALayer+UserDefinedRuntimeColor.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 15/05/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//
//

#import "CALayer+UserDefinedRuntimeColor.h"

@implementation CALayer (UserDefinedRuntimeColor)


- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

- (void)setShadowColorFromUIColor:(UIColor *)color;
{
    self.shadowColor = color.CGColor;
}

- (void)setCommentForm:(BOOL)isTrue;
{
    if (isTrue) {
        
    self.masksToBounds = NO;
    self.shadowOffset = CGSizeMake(1, 1);
    self.shadowRadius = 3;
    self.shadowOpacity = 0.2;
    
    }
}


- (void)setKickCardFormUIColor:(UIColor *)color;{

        self.masksToBounds = NO;
        self.shadowOffset = CGSizeMake(1, 1);
        self.shadowRadius = 2;
        self.shadowOpacity = 0.2;
}



@end
