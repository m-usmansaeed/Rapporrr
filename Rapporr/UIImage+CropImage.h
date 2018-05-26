//
//  UIImage+CropImage.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/8/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIImage (CropImage)
- (UIImage *)croppedImageInRect:(CGRect)rect;
- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize;
+ (UIImage *) imageWithView:(UIView *)view;
- (UIImage *)imageWithFillSize:(CGSize)size;

@end
