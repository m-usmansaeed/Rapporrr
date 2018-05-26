//
//  UILabel+DynamicHeight.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/15/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define iOS7_0 @"7.0"

@interface UILabel (DynamicHeight)


/*====================================================================*/

/* Calculate the size,bounds,frame of the Multi line Label */

/*====================================================================*/
/**
 *  Returns the size of the Label
 *
 *  @param aLabel To be used to calculte the height
 *
 *  @return size of the Label
 */

-(CGSize)sizeOfMultiLineLabel;
- (CGSize)frameSizeForAttributedString:(NSAttributedString *)attributedString;

- (CGFloat)attributedTextHeightForWidth:(CGFloat)width;
- (CGFloat)textHeightForWidth:(CGFloat)width;
- (CGFloat)heightForAttributedStringWithEmojis:(NSAttributedString *)attributedString forWidth:(CGFloat)width;
- (CGSize)heightStringWithEmojis;

- (CGFloat)setExpectedHeightForLabel:(UILabel *)label;

-(float)resizeToFit;
-(float)expectedHeight;
- (CGFloat)heightForAttributedString:(NSAttributedString *)attrString forWidth:(CGFloat)inWidth;

- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth;


@end
