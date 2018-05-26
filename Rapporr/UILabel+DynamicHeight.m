//
//  UILabel+DynamicHeight.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/15/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "UILabel+DynamicHeight.h"
#import <CoreText/CoreText.h>
#import <Foundation/NSAttributedString.h>



@implementation NSString (Utility)
- (CGFloat)heightForWidth:(CGFloat)width font:(UIFont *)font {
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize actualSize = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    return actualSize.height;
}
@end

@implementation NSAttributedString (Utility)
- (CGFloat)heightForWidth:(CGFloat)width {
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize actualSize = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return actualSize.height;
}
@end

@implementation UILabel (DynamicHeight)

- (CGFloat)textHeightForWidth:(CGFloat)width {
    return [self.text heightForWidth:width font:self.font];
}
- (CGFloat)attributedTextHeightForWidth:(CGFloat)width {
    return [self.attributedText heightForWidth:width];
}

- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth
{
    if (fixedWidth < 0) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0);
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    }
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.textAlignment = NSTextAlignmentCenter;

    self.numberOfLines = 0;
    [self sizeToFit];
}


-(CGSize)sizeOfMultiLineLabel{
    
    NSAssert(self, @"UILabel was nil");
    
    //Label text
    NSString *aLabelTextString = [self text];
    
    //Label font
    UIFont *aLabelFont = [self font];
    
    //Width of the Label
    CGFloat aLabelSizeWidth = self.bounds.size.width;
//    [UIScreen mainScreen].bounds.size.width - 20;
    
    
    if (SYSTEM_VERSION_LESS_THAN(iOS7_0)) {
        //version < 7.0
        return [aLabelTextString sizeWithFont:aLabelFont
                            constrainedToSize:CGSizeMake(aLabelSizeWidth, MAXFLOAT)
                                lineBreakMode:NSLineBreakByWordWrapping];
    }
    else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        //version >= 7.0
        
        //Return the calculated size of the Label
        
        [self setAdjustsFontSizeToFitWidth:NO];
        self.lineBreakMode = NSLineBreakByWordWrapping;
       
        CGSize size = [aLabelTextString boundingRectWithSize:CGSizeMake(aLabelSizeWidth, MAXFLOAT)
                                                     options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                                  attributes:@{
                                                               NSParagraphStyleAttributeName:[NSParagraphStyle defaultParagraphStyle],
                                                               NSFontAttributeName : aLabelFont
                                                               }
                                                     context:nil].size;
        return size;
    }
    
    return [self bounds].size;
    
}

- (CGSize)frameSizeForAttributedString:(NSAttributedString *)attributedString
{
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGFloat width = self.bounds.size.width;
    
    CFIndex offset = 0, length;
    CGFloat y = 0;
    do {
        length = CTTypesetterSuggestLineBreak(typesetter, offset, width);
        CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(offset, length));
        
        CGFloat ascent, descent, leading;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        CFRelease(line);
        
        offset += length;
        y += ascent + descent + leading;
    } while (offset < [attributedString length]);
    
    CFRelease(typesetter);
    
    return CGSizeMake(width, ceil(y));
}

- (CGFloat)heightForAttributedStringWithEmojis:(NSAttributedString *)attributedString forWidth:(CGFloat)width {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CFRange fitRange;
    CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(width, CGFLOAT_MAX), &fitRange);
    
    CFRelease(framesetter);
    
    return frameSize.height;
}

- (CGSize)heightStringWithEmojis
{
    NSString *aLabelTextString = [self text];
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (CFStringRef) aLabelTextString );
    CFIndex stringLength = CFStringGetLength((CFStringRef) attrString);
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef) self.font.fontName, self.font.pointSize, NULL);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, stringLength), kCTFontAttributeName, ctFont);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    CFRange fitRange;
    CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(self.frame.size.width, CGFLOAT_MAX), &fitRange);
    CFRelease(ctFont);
    CFRelease(framesetter);
    CFRelease(attrString);
    
    return frameSize;
    
}

- (CGFloat)setExpectedHeightForLabel:(UILabel *)label
{
    [label setNumberOfLines:0];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    CGSize currentLabelSize = CGSizeMake(label.frame.origin.x, label.frame.origin.y);
    
    NSDictionary *attributesDictionary = @{NSFontAttributeName:label.font};
    CGSize maximumLabelSize = CGSizeMake(label.frame.size.width, MAXFLOAT);
    CGRect expectedLabelRect = [label.text boundingRectWithSize:maximumLabelSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributesDictionary context:nil];
    CGSize expectedLabelSize = expectedLabelRect.size;
//    [label setFrame:CGRectMake(currentLabelSize.width, currentLabelSize.height, expectedLabelSize.width, expectedLabelSize.height)];
    
    return expectedLabelRect.size.height;
}


-(float)resizeToFit{
    float height = [self expectedHeight];
    CGRect newFrame = [self frame];
    newFrame.size.height = height;
    [self setFrame:newFrame];
    return newFrame.origin.y + newFrame.size.height;
}

-(float)expectedHeight{
    [self setNumberOfLines:0];
    [self setLineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,9999);
    
    CGSize expectedLabelSize = [[self text] sizeWithFont:[self font]
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:[self lineBreakMode]];
    return expectedLabelSize.height;
}

- (CGFloat)heightForAttributedString:(NSAttributedString *)attrString forWidth:(CGFloat)inWidth
{
    CGFloat H = 0;
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (CFMutableAttributedStringRef) attrString);
    
    CGRect box = CGRectMake(0,0, inWidth, CGFLOAT_MAX);
    
    CFIndex startIndex = 0;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, box);
    
    // Create a frame for this column and draw it.
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), path, NULL);
    
    // Start the next frame at the first character not visible in this frame.
    //CFRange frameRange = CTFrameGetVisibleStringRange(frame);
    //startIndex += frameRange.length;
    
    CFArrayRef lineArray = CTFrameGetLines(frame);
    CFIndex j = 0, lineCount = CFArrayGetCount(lineArray);
    CGFloat h, ascent, descent, leading;
    
    for (j=0; j < lineCount; j++)
    {
        CTLineRef currentLine = (CTLineRef)CFArrayGetValueAtIndex(lineArray, j);
        CTLineGetTypographicBounds(currentLine, &ascent, &descent, &leading);
        h = ascent + descent + leading;
        H+=h;
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    
    return H;
}


@end

