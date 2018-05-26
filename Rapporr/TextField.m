//
//  GrowableTextView.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 17/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "TextField.h"

@interface TextField(private)
-(void)commonInitialiser;
-(void)resizeTextView:(NSInteger)newSizeH;
-(void)growDidStop;
@end

@implementation TextField
@synthesize internalTextView;
@synthesize delegate;
@synthesize maxHeight;
@synthesize minHeight;
@synthesize font;
@synthesize textColor;
@synthesize textAlignment;
@synthesize selectedRange;
@synthesize editable;
@synthesize dataDetectorTypes;
@synthesize animateHeightChange;
@synthesize animationDuration;
@synthesize returnKeyType;
@dynamic placeholder;
@dynamic placeholderColor;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInitialiser];
        [self customInit];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInitialiser];
        [self customInit];
        
    }
    return self;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if ((self = [super initWithFrame:frame])) {
        [self commonInitialiser:textContainer];
    }
    return self;
}

-(void)commonInitialiser {
    [self commonInitialiser:nil];
}

-(void)commonInitialiser:(NSTextContainer *)textContainer
#else
-(void)commonInitialiser
#endif
{
    // Initialization code
    CGRect r = self.frame;
    r.origin.y = 0;
    r.origin.x = 0;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    internalTextView = [[InternalTextView alloc] initWithFrame:r textContainer:textContainer];
#else
    internalTextView = [[InternalTextView alloc] initWithFrame:r];
#endif
    internalTextView.delegate = self;
    internalTextView.scrollEnabled = NO;
    internalTextView.font = ROBOTO_LIGHT(13);
    internalTextView.contentInset = UIEdgeInsetsZero;
    internalTextView.showsHorizontalScrollIndicator = NO;
    internalTextView.text = @"-";
    internalTextView.contentMode = UIViewContentModeRedraw;
    
    [self addSubview:internalTextView];
    
    minHeight = internalTextView.frame.size.height;
    minNumberOfLines = 1;
    
    animateHeightChange = YES;
    animationDuration = 0.1f;
    
    internalTextView.text = @"";
    
    [self setMaxNumberOfLines:3];
    
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    internalTextView.displayPlaceHolder = YES;
    
    internalTextView.backgroundColor = [UIColor clearColor];
}

-(CGSize)sizeThatFits:(CGSize)size
{
    if (self.text.length == 0) {
        size.height = minHeight;
    }
    return size;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect r = self.bounds;
    r.origin.y = 0;
    r.origin.x = contentInset.left;
    r.size.width -= contentInset.left + contentInset.right;
    
    internalTextView.frame = r;
}

-(void)setContentInset:(UIEdgeInsets)inset
{
    contentInset = inset;
    
    CGRect r = self.frame;
    r.origin.y = inset.top - inset.bottom;
    r.origin.x = inset.left;
    r.size.width -= inset.left + inset.right;
    
    internalTextView.frame = r;
    
    [self setMaxNumberOfLines:maxNumberOfLines];
    [self setMinNumberOfLines:minNumberOfLines];
}

-(UIEdgeInsets)contentInset
{
    return contentInset;
}

-(void)setMaxNumberOfLines:(int)n
{
    if(n == 0 && maxHeight > 0)
        return;
    
    NSString *saveText = internalTextView.text, *newText = @"-";
    
    internalTextView.delegate = nil;
    internalTextView.hidden = YES;
    
    for (int i = 1; i < n; ++i)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    internalTextView.text = newText;
    
    maxHeight = [self measureHeight];
    
    internalTextView.text = saveText;
    internalTextView.hidden = NO;
    internalTextView.delegate = self;
    
    [self sizeToFit];
    
    maxNumberOfLines = n;
}

-(int)maxNumberOfLines
{
    return maxNumberOfLines;
}

- (void)setMaxHeight:(int)height
{
    maxHeight = height;
    maxNumberOfLines = 0;
}

-(void)setMinNumberOfLines:(int)m
{
    if(m == 0 && minHeight > 0) return;
    
    NSString *saveText = internalTextView.text, *newText = @"-";
    
    internalTextView.delegate = nil;
    internalTextView.hidden = YES;
    
    for (int i = 1; i < m; ++i)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    internalTextView.text = newText;
    
    minHeight = [self measureHeight];
    
    internalTextView.text = saveText;
    internalTextView.hidden = NO;
    internalTextView.delegate = self;
    
    [self sizeToFit];
    
    minNumberOfLines = m;
}

-(int)minNumberOfLines
{
    return minNumberOfLines;
}

- (void)setMinHeight:(int)height
{
    minHeight = height;
    minNumberOfLines = 0;
}

- (NSString *)placeholder
{
    return internalTextView.placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [internalTextView setPlaceholder:placeholder];
    [internalTextView setNeedsDisplay];
}

- (UIColor *)placeholderColor
{
    return internalTextView.placeholderColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    [internalTextView setPlaceholderColor:placeholderColor];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshHeight];
}

- (void)refreshHeight
{
    NSInteger newSizeH = [self measureHeight];
    if (newSizeH < minHeight || !internalTextView.hasText) {
        newSizeH = minHeight;
    }
    else if (maxHeight && newSizeH > maxHeight) {
        newSizeH = maxHeight;
    }
    
    if (internalTextView.frame.size.height != newSizeH)
    {
        
        if (newSizeH >= maxHeight)
        {
            if(!internalTextView.scrollEnabled){
                internalTextView.scrollEnabled = YES;
                [internalTextView flashScrollIndicators];
            }
            
        } else {
            internalTextView.scrollEnabled = NO;
        }
        
        
        if (newSizeH <= maxHeight)
        {
            if(animateHeightChange) {
                
                if ([UIView resolveClassMethod:@selector(animateWithDuration:animations:)]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
                    [UIView animateWithDuration:animationDuration
                                          delay:0
                                        options:(UIViewAnimationOptionAllowUserInteraction|
                                                 UIViewAnimationOptionBeginFromCurrentState)
                                     animations:^(void) {
                                         [self resizeTextView:newSizeH];
                                     }
                                     completion:^(BOOL finished) {
                                         if ([delegate respondsToSelector:@selector(growableTextView:didChangeHeight:)]) {
                                             [delegate growableTextView:self didChangeHeight:newSizeH];
                                         }
                                     }];
#endif
                } else {
                    [UIView beginAnimations:@"" context:nil];
                    [UIView setAnimationDuration:animationDuration];
                    [UIView setAnimationDelegate:self];
                    [UIView setAnimationDidStopSelector:@selector(growDidStop)];
                    [UIView setAnimationBeginsFromCurrentState:YES];
                    [self resizeTextView:newSizeH];
                    [UIView commitAnimations];
                }
            } else {
                [self resizeTextView:newSizeH];
                
                if ([delegate respondsToSelector:@selector(growableTextView:didChangeHeight:)]) {
                    [delegate growableTextView:self didChangeHeight:newSizeH];
                }
            }
        }
    }
    
    BOOL wasDisplayingPlaceholder = internalTextView.displayPlaceHolder;
    internalTextView.displayPlaceHolder = self.internalTextView.text.length == 0;
    
    if (wasDisplayingPlaceholder != internalTextView.displayPlaceHolder) {
        [internalTextView setNeedsDisplay];
    }
    
    
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        [self performSelector:@selector(resetScrollPositionForIOS7) withObject:nil afterDelay:0.1f];
    }
    
    if ([delegate respondsToSelector:@selector(growableTextViewDidChange:)]) {
        [delegate growableTextViewDidChange:self];
    }
}

- (CGFloat)measureHeight
{
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        return ceilf([self.internalTextView sizeThatFits:self.internalTextView.frame.size].height);
    }
    else {
        return self.internalTextView.contentSize.height;
    }
}

- (void)resetScrollPositionForIOS7
{
    CGRect r = [internalTextView caretRectForPosition:internalTextView.selectedTextRange.end];
    CGFloat caretY =  MAX(r.origin.y - internalTextView.frame.size.height + r.size.height + 8, 0);
    if (internalTextView.contentOffset.y < caretY && r.origin.y != INFINITY)
        internalTextView.contentOffset = CGPointMake(0, caretY);
}

-(void)resizeTextView:(NSInteger)newSizeH
{
    if ([delegate respondsToSelector:@selector(growableTextView:willChangeHeight:)]) {
        [delegate growableTextView:self willChangeHeight:newSizeH];
    }
    
    CGRect internalTextViewFrame = self.frame;
    internalTextViewFrame.size.height = newSizeH; // + padding
    self.frame = internalTextViewFrame;
    
    internalTextViewFrame.origin.y = contentInset.top - contentInset.bottom;
    internalTextViewFrame.origin.x = contentInset.left;
    
    if(!CGRectEqualToRect(internalTextView.frame, internalTextViewFrame)) internalTextView.frame = internalTextViewFrame;
}

- (void)growDidStop
{
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        [self resetScrollPositionForIOS7];
    }
    
    if ([delegate respondsToSelector:@selector(growableTextView:didChangeHeight:)]) {
        [delegate growableTextView:self didChangeHeight:self.frame.size.height];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [internalTextView becomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    return [self.internalTextView becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [internalTextView resignFirstResponder];
}

-(BOOL)isFirstResponder
{
    return [self.internalTextView isFirstResponder];
}



#pragma mark UITextView properties

-(void)setText:(NSString *)newText
{
    internalTextView.text = newText;
    [self performSelector:@selector(textViewDidChange:) withObject:internalTextView];
}

-(NSString*) text
{
    return internalTextView.text;
}


-(void)setFont:(UIFont *)afont
{
    internalTextView.font= afont;
    
    [self setMaxNumberOfLines:maxNumberOfLines];
    [self setMinNumberOfLines:minNumberOfLines];
}

-(UIFont *)font
{
    return internalTextView.font;
}


-(void)setTextColor:(UIColor *)color
{
    internalTextView.textColor = color;
}

-(UIColor*)textColor{
    return internalTextView.textColor;
}


-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    internalTextView.backgroundColor = backgroundColor;
}

-(UIColor*)backgroundColor
{
    return internalTextView.backgroundColor;
}


-(void)setTextAlignment:(NSTextAlignment)aligment
{
    internalTextView.textAlignment = aligment;
}

-(NSTextAlignment)textAlignment
{
    return internalTextView.textAlignment;
}


-(void)setSelectedRange:(NSRange)range
{
    internalTextView.selectedRange = range;
}

-(NSRange)selectedRange
{
    return internalTextView.selectedRange;
}


- (void)setIsScrollable:(BOOL)isScrollable
{
    internalTextView.scrollEnabled = isScrollable;
}

- (BOOL)isScrollable
{
    return internalTextView.scrollEnabled;
}


-(void)setEditable:(BOOL)beditable
{
    internalTextView.editable = beditable;
}

-(BOOL)isEditable
{
    return internalTextView.editable;
}


-(void)setReturnKeyType:(UIReturnKeyType)keyType
{
    internalTextView.returnKeyType = keyType;
}

-(UIReturnKeyType)returnKeyType
{
    return internalTextView.returnKeyType;
}


- (void)setKeyboardType:(UIKeyboardType)keyType
{
    internalTextView.keyboardType = keyType;
}

- (UIKeyboardType)keyboardType
{
    return internalTextView.keyboardType;
}

- (void)drawRect:(CGRect)rect {
    [self customInit];
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)prepareForInterfaceBuilder {
    [self customInit];
}

- (void)customInit {
   
    self.layer.cornerRadius = self.cornerRadius;
    self.layer.borderWidth = self.borderWidth;
    self.layer.borderColor = self.borderColor.CGColor;
    self.layer.masksToBounds = self.masksToBounds;
}


- (void)setEnablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically
{
    internalTextView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically;
}

- (BOOL)enablesReturnKeyAutomatically
{
    return internalTextView.enablesReturnKeyAutomatically;
}


-(void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector
{
    internalTextView.dataDetectorTypes = datadetector;
}

-(UIDataDetectorTypes)dataDetectorTypes
{
    return internalTextView.dataDetectorTypes;
}


- (BOOL)hasText{
    return [internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range
{
    [internalTextView scrollRangeToVisible:range];
}

#pragma mark -
#pragma mark UITextViewDelegate


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([delegate respondsToSelector:@selector(growableTextViewShouldBeginEditing:)]) {
        return [delegate growableTextViewShouldBeginEditing:self];
        
    } else {
        return YES;
    }
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([delegate respondsToSelector:@selector(growableTextViewShouldEndEditing:)]) {
        return [delegate growableTextViewShouldEndEditing:self];
        
    } else {
        return YES;
    }
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([delegate respondsToSelector:@selector(growableTextViewDidBeginEditing:)]) {
        [delegate growableTextViewDidBeginEditing:self];
    }
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([delegate respondsToSelector:@selector(growableTextViewDidEndEditing:)]) {
        [delegate growableTextViewDidEndEditing:self];
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)atext {
    
    if(![textView hasText] && [atext isEqualToString:@""]) return NO;
    
    if ([delegate respondsToSelector:@selector(growableTextView:shouldChangeTextInRange:replacementText:)])
        return [delegate growableTextView:self shouldChangeTextInRange:range replacementText:atext];
    
    if ([atext isEqualToString:@"\n"]) {
        if ([delegate respondsToSelector:@selector(growableTextViewShouldReturn:)]) {
            if (![delegate performSelector:@selector(growableTextViewShouldReturn:) withObject:self]) {
                return YES;
            } else {
                [textView resignFirstResponder];
                return NO;
            }
        }
    }
    
    return YES;
    
    
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if ([delegate respondsToSelector:@selector(growableTextViewDidChangeSelection:)]) {
        [delegate growableTextViewDidChangeSelection:self];
    }
}

@end

@implementation InternalTextView

-(void)setText:(NSString *)text
{
    BOOL originalValue = self.scrollEnabled;
    [self setScrollEnabled:YES];
    [super setText:text];
    [self setScrollEnabled:originalValue];
}

- (void)setScrollable:(BOOL)isScrollable
{
    [super setScrollEnabled:isScrollable];
}

-(void)setContentOffset:(CGPoint)s
{
    if(self.tracking || self.decelerating){
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
        
    } else {
        
        float bottomOffset = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom);
        if(s.y < bottomOffset && self.scrollEnabled){
            UIEdgeInsets insets = self.contentInset;
            insets.bottom = 8;
            insets.top = 0;
            self.contentInset = insets;
        }
    }
    
    if (s.y > self.contentSize.height - self.frame.size.height && !self.decelerating && !self.tracking && !self.dragging)
        s = CGPointMake(s.x, self.contentSize.height - self.frame.size.height);
    
    [super setContentOffset:s];
}

-(void)setContentInset:(UIEdgeInsets)s
{
    UIEdgeInsets insets = s;
    
    if(s.bottom>8) insets.bottom = 0;
    insets.top = 0;
    
    [super setContentInset:insets];
}

-(void)setContentSize:(CGSize)contentSize
{
    if(self.contentSize.height > contentSize.height)
    {
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
    }
    
    [super setContentSize:contentSize];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.displayPlaceHolder && self.placeholder && self.placeholderColor)
    {
        if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.alignment = self.textAlignment;
            [self.placeholder drawInRect:CGRectMake(5, 5 + self.contentInset.top, self.frame.size.width-self.contentInset.left, self.frame.size.height- self.contentInset.top) withAttributes:@{NSFontAttributeName:self.font, NSForegroundColorAttributeName:self.placeholderColor, NSParagraphStyleAttributeName:paragraphStyle}];
        }
        else {
            
            [self.placeholderColor set];
            
            if ([self.placeholder respondsToSelector:@selector(drawInRect:withFont:)]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [self.placeholder drawInRect:CGRectMake(8.0f, 5.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f) withFont:self.font];
#pragma clang diagnostic pop
            }else{
                [self.placeholder drawInRect:CGRectMake(8.0f, 5.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f) withAttributes:@{NSFontAttributeName: self.font}];
            }
        }
    }
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    [self setNeedsDisplay];
}

@end



