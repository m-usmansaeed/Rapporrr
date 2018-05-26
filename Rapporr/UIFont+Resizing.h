//
//  UIFont+Resizing.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 15/05/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIFont (Resizing)

+ (void)logFontNames;

+ (UIFont *_Nullable)regularFontWithSize:(CGFloat)size;
+ (UIFont *_Nullable)boldFontWithSize:(CGFloat)size;
+ (UIFont *_Nullable)italicFontOfSize:(CGFloat)fontSize;




@end
