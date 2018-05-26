//
//  RapporrAlertView.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 15/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum AlertType : NSUInteger {
    kAlertTypeMessage,
    kAlertTypeDetail,
    kAlertTypePopup,
    kAlertTypeContact
} AlertType;


@protocol RapporrAlertViewDelegate

-(void)RapporrAlertOK:(id)sender;
-(void)RapporrAlertCancel;
-(void)RapporrAlertCancel:(id)sender;

@end

@interface RapporrAlertView : UIViewController
@property (nonatomic, retain) id<RapporrAlertViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *descLbl;
@property (strong, nonatomic) IBOutlet UIButton *btnCANCEL;
@property (strong, nonatomic) IBOutlet UIButton *btnOK;

@property (nonatomic) NSInteger alertTag;
@property (nonatomic) AlertType alertType;
@property (nonatomic) BOOL isButtonSwitch;

@property (weak, nonatomic) IBOutlet UIView *viewMessage;
@property (weak, nonatomic) IBOutlet UIView *bgView;

- (IBAction)okPressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

-(void)showCustomAlertInView:(UIView *)targetView withMessage:(NSString *)message andDescription:(NSString*)desc setOkTitle:(NSString *)okTitle setCancelTitle:(NSString *)cancelTitle;

-(void)showCustomAlertInView:(UIView *)targetView withMessage:(NSString *)message andDescription:(NSString*)desc;

-(void)showCustomAlertInView2:(UIView *)targetView withMessage:(NSString *)message andDescription:(NSString*)desc detailHead:(NSString*)detailHead andName:(NSString*)name andPhone:(NSString*)phone;

-(void)removeCustomAlertFromView;
-(void)removeCustomAlertFromViewInstantly;
-(void)removeOkayButton:(BOOL)shouldRemove;
-(void)removeCancelButton:(BOOL)shouldRemove;
-(BOOL)isOkayButtonRemoved;
-(BOOL)isCancelButtonRemoved;

@property (weak, nonatomic) IBOutlet UIView *viewMessageType2;
@property (weak, nonatomic) IBOutlet UILabel *viewTitle2;
@property (weak, nonatomic) IBOutlet UILabel *viewMessage2;

@property (strong, nonatomic) IBOutlet UIButton *btnCANCEL2;
@property (strong, nonatomic) IBOutlet UIButton *btnOK2;

@property (weak, nonatomic) IBOutlet UILabel *lblDetailsHead;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;


-(void)showPopUpInView:(UIView *)targetView withMessage:(NSString *)message andDescription:(NSString*)desc;

@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property (weak, nonatomic) IBOutlet UILabel *popUpTitle;
@property (weak, nonatomic) IBOutlet UILabel *popUpMessage;

@property (strong, nonatomic) IBOutlet UIButton *btnpopUpOK;


@end


