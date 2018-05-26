//
//  UILabel+calculateHeightAndRect.h
//  textHeight
//
//  Created by shayinqi on 16/3/2.
//  Copyright © 2016年 Yinqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (calculateHeightAndRect)

/**
 *  根据完全显示的高度创建新的Label
 *
 *  @param frame    CGRECT高度无所谓会重写
 *  @param text     Label内的文字
 *  @param fontSize Label文字的大小
 *
 *  @return 返回完整高度的Label
 */
-(instancetype)initWithFrame:(CGRect)frame
             FullTextDisplay:(NSString*)text
                    FontSize:(int)fontSize;
/**
 *  根据宽度配置高度返回Label
 *
 *  @param X        X position
 *  @param Y        Y position
 *  @param width    Label_Width
 *  @param text     Label.text
 *  @param fontSize font_size
 *
 *  @return 返回完整高度的Label
 */
-(instancetype)initWithPositionX:(CGFloat)X
                       PositionY:(CGFloat)Y
                           Width:(CGFloat)width
                 FullTextDisplay:(NSString*)text
                        FontSize:(int)fontSize;
/**
 *  2次修改Label的frame
 *
 *  @param myLabel 你的Label
 */
+(void)ReSetLabelByFullyDisplay:(UILabel*)myLabel;

/**
 *  计算UILabel文字高度
 *
 *  @param text     Label内的NSString
 *  @param fontSize 文字大小
 *  @param width    Label宽度限制
 *
 *  @return 返回文字的高度
 */
+(CGFloat)CalculateHeightForFullDisplayText:(NSString*)text
                                       Font:(int)fontSize
                                  textWidth:(CGFloat)width;
@end
