//
//  RapporrAlertView.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 15/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "RapporrAlertView.h"
#import "UILabel+calculateHeightAndRect.h"

@interface RapporrAlertView ()

@end

#define OK_BUTTON_TAG       888
#define CANCEL_BUTTON_TAG   999
#define ANIMATION_DURATION  0.25

@implementation RapporrAlertView

-(id)init{
    self = [super init];
    if (self) {
        
        [_btnOK setTag:OK_BUTTON_TAG];
        [_btnCANCEL setTag:CANCEL_BUTTON_TAG];
        
        [_btnOK2 setTag:OK_BUTTON_TAG];
        [_btnCANCEL2 setTag:CANCEL_BUTTON_TAG];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)okPressed:(id)sender {
    if(!self.isButtonSwitch){
        [self.delegate RapporrAlertOK:sender];
    }else{
        [self.delegate RapporrAlertCancel];
    }
}

- (IBAction)cancelPressed:(id)sender {

    if(self.isButtonSwitch){
        [self.delegate RapporrAlertOK:sender];
    }
    else{
        [self.delegate RapporrAlertCancel];
    }

}


-(void)showCustomAlertInView:(UIView *)targetView withMessage:(NSString *)message andDescription:(NSString*)desc {
    CGFloat statusBarOffset;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapGestureRecognizer.delegate = (id)self;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];

    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        // If the status bar is not hidden then we get its height and keep it to the statusBarOffset variable.
        // However, there is a small trick here that needs to be done.
        // In portrait orientation the status bar size is 320.0 x 20.0 pixels.
        // In landscape orientation the status bar size is 20.0 x 480.0 pixels (or 20.0 x 568.0 pixels on iPhone 5).
        // We need to check which is the smallest value (width or height). This is the value that will be kept.
        // At first we get the status bar size.
        CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
        if (statusBarSize.width < statusBarSize.height) {
            // If the width is smaller than the height then this is the value we need.
            statusBarOffset = statusBarSize.width;
        }
        else{
            // Otherwise the height is the desired value that we want to keep.
            statusBarOffset = statusBarSize.height;
        }
    }
    else{
        // Otherwise set it to 0.0.
        statusBarOffset = 0.0;
    }
    
    
    // Declare the following variables that will take their values
    // depending on the orientation.
    CGFloat width, height, offsetX, offsetY;
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ||
        [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        // If the orientation is landscape then the width
        // gets the targetView's height value and the height gets
        // the targetView's width value.
        width = targetView.frame.size.height;
        height = targetView.frame.size.width;
        
//        offsetX = -statusBarOffset;
//        offsetY = 0.0;
    }
    else{
        // Otherwise the width is width and the height is height.
        width = targetView.frame.size.width;
        height = targetView.frame.size.height;
        
//        offsetX = 0.0;
//        offsetY = -statusBarOffset;
    }
    
    // Set the view's frame and add it to the target view.
    [self.view setFrame:CGRectMake(targetView.frame.origin.x, targetView.frame.origin.y, width, height)];
    //[self.view setFrame:CGRectOffset(self.view.frame, offsetX, offsetY)];
    [targetView addSubview:self.view];
    
    /*
     // Set the initial frame of the message view.
     // It should be out of the visible area of the screen.
     [_viewMessage setFrame:CGRectMake(0.0, -_viewMessage.frame.size.height, _viewMessage.frame.size.width, _viewMessage.frame.size.height)];
     
     // Animate the display of the message view.
     // We change the y point of its origin by setting it to 0 from the -height value point we previously set it.
     [UIView beginAnimations:@"" context:nil];
     [UIView setAnimationDuration:ANIMATION_DURATION];
     [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
     [_viewMessage setFrame:CGRectMake(0.0, 0.0, _viewMessage.frame.size.width, _viewMessage.frame.size.height)];
     [UIView commitAnimations];*/
    [self.bgView setBackgroundColor:[UIColor colorFromHexCode:@"#E5E5E5"]];
    self.viewMessage.hidden = NO;
    
    
    
    self.viewMessageType2.hidden = YES;
    [_titleLbl setText:message];
    [_descLbl setText:desc];
    
    CGSize size = [_descLbl sizeOfMultiLineLabel];
    CGRect viewRect = self.viewMessage.frame;
    viewRect.size.height = 136 + size.height;
    self.viewMessage.frame = viewRect;
    
}

-(void)showCustomAlertInView:(UIView *)targetView withMessage:(NSString *)message andDescription:(NSString*)desc setOkTitle:(NSString *)okTitle setCancelTitle:(NSString *)cancelTitle;
{
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapGestureRecognizer.delegate = (id)self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    CGFloat statusBarOffset;
    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        // If the status bar is not hidden then we get its height and keep it to the statusBarOffset variable.
        // However, there is a small trick here that needs to be done.
        // In portrait orientation the status bar size is 320.0 x 20.0 pixels.
        // In landscape orientation the status bar size is 20.0 x 480.0 pixels (or 20.0 x 568.0 pixels on iPhone 5).
        // We need to check which is the smallest value (width or height). This is the value that will be kept.
        // At first we get the status bar size.
        CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
        if (statusBarSize.width < statusBarSize.height) {
            // If the width is smaller than the height then this is the value we need.
            statusBarOffset = statusBarSize.width;
        }
        else{
            // Otherwise the height is the desired value that we want to keep.
            statusBarOffset = statusBarSize.height;
        }
    }
    else{
        // Otherwise set it to 0.0.
        statusBarOffset = 0.0;
    }
    
    
    // Declare the following variables that will take their values
    // depending on the orientation.
    CGFloat width, height, offsetX, offsetY;
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ||
        [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        // If the orientation is landscape then the width
        // gets the targetView's height value and the height gets
        // the targetView's width value.
        width = targetView.frame.size.height;
        height = targetView.frame.size.width;
        
//        offsetX = -statusBarOffset;
//        offsetY = 0.0;
    }
    else{
        // Otherwise the width is width and the height is height.
        width = targetView.frame.size.width;
        height = targetView.frame.size.height;
        
//        offsetX = 0.0;
//        offsetY = -statusBarOffset;
    }
    
    // Set the view's frame and add it to the target view.
    [self.view setFrame:CGRectMake(targetView.frame.origin.x, targetView.frame.origin.y, width, height)];
    //[self.view setFrame:CGRectOffset(self.view.frame, offsetX, offsetY)];
    [targetView addSubview:self.view];
    
    /*
     // Set the initial frame of the message view.
     // It should be out of the visible area of the screen.
     [_viewMessage setFrame:CGRectMake(0.0, -_viewMessage.frame.size.height, _viewMessage.frame.size.width, _viewMessage.frame.size.height)];
     
     // Animate the display of the message view.
     // We change the y point of its origin by setting it to 0 from the -height value point we previously set it.
     [UIView beginAnimations:@"" context:nil];
     [UIView setAnimationDuration:ANIMATION_DURATION];
     [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
     [_viewMessage setFrame:CGRectMake(0.0, 0.0, _viewMessage.frame.size.width, _viewMessage.frame.size.height)];
     [UIView commitAnimations];*/
   
    if(okTitle != nil){
        [self.btnOK setTitle:okTitle forState:UIControlStateNormal];
    }
    if(cancelTitle != nil){
        [self.btnCANCEL setTitle:cancelTitle forState:UIControlStateNormal];
    }
    
    

    [self.bgView setBackgroundColor:[UIColor colorFromHexCode:@"#E5E5E5"]];
    self.viewMessage.hidden = NO;
    self.popUpView.hidden = YES;
    self.viewMessageType2.hidden = YES;
    [_titleLbl setText:message];
    [_descLbl setText:desc];
    
    CGSize size = [_descLbl sizeOfMultiLineLabel];
    CGRect viewRect = self.viewMessage.frame;
    viewRect.size.height = 136 + size.height;
    self.viewMessage.frame = viewRect;
    
}

-(void)showCustomAlertInView2:(UIView *)targetView withMessage:(NSString *)message andDescription:(NSString*)desc detailHead:(NSString*)detailHead andName:(NSString*)name andPhone:(NSString*)phone{
    CGFloat statusBarOffset;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapGestureRecognizer.delegate = (id)self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        // If the status bar is not hidden then we get its height and keep it to the statusBarOffset variable.
        // However, there is a small trick here that needs to be done.
        // In portrait orientation the status bar size is 320.0 x 20.0 pixels.
        // In landscape orientation the status bar size is 20.0 x 480.0 pixels (or 20.0 x 568.0 pixels on iPhone 5).
        // We need to check which is the smallest value (width or height). This is the value that will be kept.
        // At first we get the status bar size.
        CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
        if (statusBarSize.width < statusBarSize.height) {
            // If the width is smaller than the height then this is the value we need.
            statusBarOffset = statusBarSize.width;
        }
        else{
            // Otherwise the height is the desired value that we want to keep.
            statusBarOffset = statusBarSize.height;
        }
    }
    else{
        // Otherwise set it to 0.0.
        statusBarOffset = 0.0;
    }
    
    
    // Declare the following variables that will take their values
    // depending on the orientation.
    CGFloat width, height, offsetX, offsetY;
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ||
        [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        // If the orientation is landscape then the width
        // gets the targetView's height value and the height gets
        // the targetView's width value.
        width = targetView.frame.size.height;
        height = targetView.frame.size.width;
        
//        offsetX = -statusBarOffset;
//        offsetY = 0.0;
    }
    else{
        // Otherwise the width is width and the height is height.
        width = targetView.frame.size.width;
        height = targetView.frame.size.height;
        
//        offsetX = 0.0;
//        offsetY = -statusBarOffset;
    }
    
    // Set the view's frame and add it to the target view.
    [self.view setFrame:CGRectMake(targetView.frame.origin.x, targetView.frame.origin.y, width, height)];
    //[self.view setFrame:CGRectOffset(self.view.frame, offsetX, offsetY)];
    [targetView addSubview:self.view];
    
    /*
     // Set the initial frame of the message view.
     // It should be out of the visible area of the screen.
     [_viewMessage setFrame:CGRectMake(0.0, -_viewMessage.frame.size.height, _viewMessage.frame.size.width, _viewMessage.frame.size.height)];
     
     // Animate the display of the message view.
     // We change the y point of its origin by setting it to 0 from the -height value point we previously set it.
     [UIView beginAnimations:@"" context:nil];
     [UIView setAnimationDuration:ANIMATION_DURATION];
     [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
     [_viewMessage setFrame:CGRectMake(0.0, 0.0, _viewMessage.frame.size.width, _viewMessage.frame.size.height)];
     [UIView commitAnimations];*/
    if(self.alertType == kAlertTypeDetail){
        self.viewMessage.hidden = YES;
        self.popUpView.hidden = YES;

        self.viewMessageType2.hidden = NO;
        [_viewTitle2 setText:message];
        [_viewMessage2 setText:desc];
        
        [_lblDetailsHead setText:detailHead];
        [_lblName setText:name];
        [_lblPhone setText:phone];
        [_bgView setBackgroundColor:[UIColor blackColor]];
        
    }
    
    // Set the message that will be displayed.
    
}


-(void)removeCustomAlertFromView{
    // Animate the message view dissapearing.
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    if(self.alertType == kAlertTypeDetail){
        [_viewMessageType2 setFrame:CGRectMake(0.0, -_viewMessageType2.frame.size.height, _viewMessageType2.frame.size.width, _viewMessageType2.frame.size.height)];
    }else if(self.alertType == kAlertTypeMessage){
        [_viewMessage setFrame:CGRectMake(0.0, -_viewMessage.frame.size.height, _viewMessage.frame.size.width, _viewMessage.frame.size.height)];
    }else{
    
    }
    
    [UIView commitAnimations];
    
    // Remove the main view from the super view as well after the animation is finished.
    [self.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:ANIMATION_DURATION];
}


-(void)removeCustomAlertFromViewInstantly{
    [self.view removeFromSuperview];
}


-(void)showPopUpInView:(UIView *)targetView withMessage:(NSString *)message andDescription:(NSString*)desc;
{
    CGFloat statusBarOffset;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapGestureRecognizer.delegate = (id)self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        // If the status bar is not hidden then we get its height and keep it to the statusBarOffset variable.
        // However, there is a small trick here that needs to be done.
        // In portrait orientation the status bar size is 320.0 x 20.0 pixels.
        // In landscape orientation the status bar size is 20.0 x 480.0 pixels (or 20.0 x 568.0 pixels on iPhone 5).
        // We need to check which is the smallest value (width or height). This is the value that will be kept.
        // At first we get the status bar size.
        CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
        if (statusBarSize.width < statusBarSize.height) {
            // If the width is smaller than the height then this is the value we need.
            statusBarOffset = statusBarSize.width;
        }
        else{
            // Otherwise the height is the desired value that we want to keep.
            statusBarOffset = statusBarSize.height;
        }
    }
    else{
        // Otherwise set it to 0.0.
        statusBarOffset = 0.0;
    }
    
    // Declare the following variables that will take their values
    // depending on the orientation.
    CGFloat width, height, offsetX, offsetY;
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ||
        [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        // If the orientation is landscape then the width
        // gets the targetView's height value and the height gets
        // the targetView's width value.
        width = targetView.frame.size.height;
        height = targetView.frame.size.width;
        
//        offsetX = -statusBarOffset;
//        offsetY = 0.0;
    }
    else{
        // Otherwise the width is width and the height is height.
        width = targetView.frame.size.width;
        height = targetView.frame.size.height;
        
//        offsetX = 0.0;
//        offsetY = -statusBarOffset;
    }
    
    // Set the view's frame and add it to the target view.
    [self.view setFrame:CGRectMake(targetView.frame.origin.x, targetView.frame.origin.y, width, height)];
    //[self.view setFrame:CGRectOffset(self.view.frame, offsetX, offsetY)];
    [targetView addSubview:self.view];
    
    /*
     // Set the initial frame of the message view.
     // It should be out of the visible area of the screen.
     [_viewMessage setFrame:CGRectMake(0.0, -_viewMessage.frame.size.height, _viewMessage.frame.size.width, _viewMessage.frame.size.height)];
     
     // Animate the display of the message view.
     // We change the y point of its origin by setting it to 0 from the -height value point we previously set it.
     [UIView beginAnimations:@"" context:nil];
     [UIView setAnimationDuration:ANIMATION_DURATION];
     [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
     [_viewMessage setFrame:CGRectMake(0.0, 0.0, _viewMessage.frame.size.width, _viewMessage.frame.size.height)];
     [UIView commitAnimations];*/
    [self.bgView setBackgroundColor:[UIColor colorFromHexCode:@"#E5E5E5"]];
    self.viewMessage.hidden = YES;
    self.viewMessageType2.hidden = YES;
    self.popUpView.hidden = NO;
    
  
    [_popUpTitle setText:message];
    [_popUpMessage setText:desc];
    
    CGSize size =  [desc sizeWithFont:ROBOTO_LIGHT(16)
                             constrainedToSize:CGSizeMake(500, CGFLOAT_MAX)
                                 lineBreakMode:_popUpMessage.lineBreakMode];
    
    //CGSize size = [_popUpMessage sizeOfMultiLineLabel];
    CGRect viewRect = self.popUpView.frame;
    //CGFloat calculatedHeight = [UILabel CalculateHeightForFullDisplayText:desc Font:16 textWidth:viewRect.size.width];
    viewRect.size.height = 136 + size.height;
    self.popUpView.frame = viewRect;
    
}

#pragma mark - Private methods

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    [self.view removeFromSuperview];
}


@end
