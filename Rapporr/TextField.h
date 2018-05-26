//
//  TextView.h
//  MachoCart
//
//  Created by Rapporr-Dev-MUS on 17/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

//#BCBCC2 Apple's PlaceHolder Text Color
//#F9F9F9 Apple's Message Text Field Background Color
//#BBBAC1 Apple's Message Text Field Border Color
// Standard Apple's TextField Hight 30

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
#define NSTextAlignment UITextAlignment
#endif

@class TextField;
@class InternalTextView;

@protocol TextViewDelegate

@optional
- (BOOL)growableTextViewShouldBeginEditing:(TextField *)textField;
- (BOOL)growableTextViewShouldEndEditing:(TextField *)textField;

- (void)growableTextViewDidBeginEditing:(TextField *)textField;
- (void)growableTextViewDidEndEditing:(TextField *)textField;

- (BOOL)growableTextView:(TextField *)textField shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growableTextViewDidChange:(TextField *)textField;

- (void)growableTextView:(TextField *)textField willChangeHeight:(float)height;
- (void)growableTextView:(TextField *)textField didChangeHeight:(float)height;

- (void)growableTextViewDidChangeSelection:(TextField *)textField;
- (BOOL)growableTextViewShouldReturn:(TextField *)textField;
@end

IB_DESIGNABLE
@interface TextField : UIView <UITextViewDelegate> {
    InternalTextView *internalTextView;
    
    int minHeight;
    int maxHeight;
    
    int maxNumberOfLines;
    int minNumberOfLines;
    
    BOOL animateHeightChange;
    NSTimeInterval animationDuration;
    
    NSObject <TextViewDelegate> *__unsafe_unretained delegate;
    NSTextAlignment textAlignment;
    NSRange selectedRange;
    BOOL editable;
    UIDataDetectorTypes dataDetectorTypes;
    UIReturnKeyType returnKeyType;
    UIKeyboardType keyboardType;

    UIEdgeInsets contentInset;

}

@property (nonatomic ,strong)  UITextView *internalTextView;

@property (nonatomic ,assign) IBInspectable int maxNumberOfLines;
@property (nonatomic ,assign) IBInspectable int minNumberOfLines;
@property (nonatomic ,assign) IBInspectable int maxHeight;
@property (nonatomic ,assign) IBInspectable int minHeight;
@property (nonatomic ,assign) IBInspectable BOOL animateHeightChange;
@property (nonatomic ,assign) IBInspectable NSTimeInterval animationDuration;

@property  IBInspectable NSString *placeholder;
@property  IBInspectable UIColor *placeholderColor;


@property (nonatomic) IBInspectable NSInteger borderWidth;
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable BOOL masksToBounds;
@property IBInspectable UIColor *borderColor;


@property(unsafe_unretained) NSObject<TextViewDelegate> *delegate;

@property(nonatomic,strong) NSString *text;
@property IBInspectable UIFont *font;
@property IBInspectable UIColor *textColor;
@property(nonatomic ,assign) IBInspectable NSTextAlignment textAlignment;
@property(nonatomic) NSRange selectedRange;            // only ranges of length 0 are supported
@property(nonatomic,getter=isEditable) BOOL editable;
@property(nonatomic) UIDataDetectorTypes dataDetectorTypes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_0);
@property (nonatomic, assign) IBInspectable UIReturnKeyType returnKeyType;
@property (nonatomic, assign) IBInspectable UIKeyboardType keyboardType;
@property (nonatomic, assign) IBInspectable UIEdgeInsets contentInset;
@property (nonatomic) IBInspectable BOOL isScrollable;
@property(nonatomic) IBInspectable BOOL enablesReturnKeyAutomatically;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer;
#endif

- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (BOOL)isFirstResponder;

- (BOOL)hasText;
- (void)scrollRangeToVisible:(NSRange)range;


- (void)refreshHeight;

@end

@interface InternalTextView : UITextView
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic) BOOL displayPlaceHolder;

@end



