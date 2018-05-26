//
//  UINavigationController+FlatNavigationBar.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 30/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "UINavigationController+FlatNavigationBar.h"

@implementation UINavigationController (FlatNavigationBar)


- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    
    return nil;
}

- (void)setFlatColorToNavigationBar:(UIColor *)color withTitleColor:(UIColor *)titleColor andFont:(UIFont *)font;
{
    [self.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationBar setBarTintColor:color];
    [self.navigationBar setTranslucent:NO];
    [self setHidesNavigationBarHairline:YES];
    [self.navigationBar setTitleTextAttributes:@{
                                                 NSForegroundColorAttributeName: titleColor,
                                                 NSFontAttributeName: font}];
}


- (void)setHidesNavigationBarHairline:(BOOL)hidesNavigationBarHairline {
    
    NSNumber *number = [NSNumber numberWithBool:hidesNavigationBarHairline];
    objc_setAssociatedObject(self, @selector(hidesNavigationBarHairline), number, OBJC_ASSOCIATION_RETAIN);
    
    UIView *hairlineImageView = [self findHairlineImageViewUnder:self.navigationBar];
    [self.navigationBar setTranslucent:NO];

    if (hairlineImageView) {
        
        if (hidesNavigationBarHairline) {
            hairlineImageView.hidden = YES;
            
        } else {
            hairlineImageView.hidden = NO;
        }
    }
}

- (BOOL)hidesNavigationBarHairline {
    
    NSNumber *number = objc_getAssociatedObject(self, @selector(hidesNavigationBarHairline));
    return [number boolValue];
}

@end
