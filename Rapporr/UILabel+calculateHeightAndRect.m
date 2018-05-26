//
//  UILabel+calculateHeightAndRect.m
//  textHeight
//
//  Created by shayinqi on 16/3/2.
//  Copyright © 2016年 Yinqi. All rights reserved.
//

#import <objc/runtime.h>
#import "UILabel+calculateHeightAndRect.h"

#define UNLIMITED_LINES 0

@interface UILabel()

/**
 *  必要属性
 */
@property(nonatomic,weak) UILabel* changeLabel;
/**
 *  可能以后用
 */
@property(nonatomic,strong) UILabel* newLabel;
@end

@implementation UILabel (calculateHeightAndRect)

static void* changeLabelKey = &changeLabelKey;
static void* newLabelKey = &newLabelKey;

-(void)setChangeLabel:(UILabel *)changeLabel{
    objc_setAssociatedObject(self, changeLabelKey, changeLabel, OBJC_ASSOCIATION_ASSIGN);
}
-(UILabel*)changeLabel{
    return objc_getAssociatedObject(self, changeLabelKey);
}

-(void)setNewLabel:(UILabel *)newLabel{
    objc_setAssociatedObject(self, newLabelKey, newLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UILabel*)newLabel{
    return objc_getAssociatedObject(self, newLabelKey);
}

/**
 *  从新设置高度正确的Frame 高度修改核心方法
 *
 *  @param myLabel 视图控制器中Label
 */
-(void)reSetLabelWithNewHeight:(UILabel*)myLabel
{
    self.changeLabel = myLabel;
    self.changeLabel.numberOfLines = 0;
    CGRect rectOfText = CGRectMake(0, 0,self.changeLabel.frame.size.width, MAXFLOAT);
    rectOfText = [self.changeLabel textRectForBounds:rectOfText limitedToNumberOfLines:UNLIMITED_LINES];
    CGRect newTextFrame = self.changeLabel.frame;
    newTextFrame.size.height = rectOfText.size.height;
    self.changeLabel.frame = newTextFrame;
}

/**
 *  2次修改Label的frame
 *
 *  @param myLabel 你的Label
 */
+(void)ReSetLabelByFullyDisplay:(UILabel*)myLabel
{
    [[self alloc]reSetLabelWithNewHeight:myLabel];
}

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
                    FontSize:(int)fontSize
{
    self = [[UILabel alloc] initWithFrame:frame];
    self.font = [UIFont systemFontOfSize:fontSize];
    self.text = text;
    [self reSetLabelWithNewHeight:self];
    return self;
}

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
                    FontSize:(int)fontSize
{
    self = [[UILabel alloc] initWithFrame:CGRectMake(X, Y, width, 0)];
    self.font = [UIFont systemFontOfSize:fontSize];
    self.text = text;
    [self reSetLabelWithNewHeight:self];
    return self;
}

/**
 *  计算文字高度
 *
 *  @param text     Label内的NSString
 *  @param fontSize 文字大小
 *  @param width    Label宽度限制
 *
 *  @return 返回文字的高度
 */
+(CGFloat)CalculateHeightForFullDisplayText:(NSString*)text
                                       Font:(int)fontSize
                                  textWidth:(CGFloat)width
{
    UILabel* textLabel = [UILabel new];
    textLabel.font = ROBOTO_LIGHT(fontSize);
    textLabel.frame = CGRectMake(0, 0, width, MAXFLOAT);
    textLabel.text = text;
    textLabel.numberOfLines = 0;
    CGRect rectOfText = CGRectMake(0, 0, width, MAXFLOAT);
    rectOfText = [textLabel textRectForBounds:rectOfText limitedToNumberOfLines:UNLIMITED_LINES];
    CGRect newTextFrame = textLabel.frame;
    newTextFrame.size.height = rectOfText.size.height;
    textLabel.frame = newTextFrame;
    
    return textLabel.frame.size.height;
}

@end
