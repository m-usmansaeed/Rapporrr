//
//  UINavigationController+FlatNavigationBar.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 30/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UINavigationController (FlatNavigationBar)

- (void)setHidesNavigationBarHairline:(BOOL)hidesNavigationBarHairline;
- (void)setFlatColorToNavigationBar:(UIColor *)color withTitleColor:(UIColor *)titleColor andFont:(UIFont *)font;


@end
