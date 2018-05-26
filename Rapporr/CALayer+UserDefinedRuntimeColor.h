//
//  CALayer+UserDefinedRuntimeColor.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 15/05/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//
//

#import <QuartzCore/QuartzCore.h>
#include <UIKit/UIKit.h>

@interface CALayer (UserDefinedRuntimeColor)

- (void)setBorderColorFromUIColor:(UIColor *)color;
- (void)setShadowColorFromUIColor:(UIColor *)color;
- (void)setCommentForm:(BOOL)isTrue;
- (void)setKickCardFormUIColor:(UIColor *)color;


@end
