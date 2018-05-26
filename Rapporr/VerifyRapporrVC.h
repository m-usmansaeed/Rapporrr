//
//  VerifyRapporrVC.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 22/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanyModel.h"
#import "CoreDataController.h"

@interface VerifyRapporrVC : UIViewController<UITextFieldDelegate> {
    UITapGestureRecognizer *tap;
        
}
    
@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;

@property (strong, nonatomic) CompanyModel *cModel;
@property (strong, nonatomic) IBOutlet UIButton *verifyBtn;
@property (strong, nonatomic) IBOutlet UILabel *companyName;
@property (strong, nonatomic) IBOutlet UITextField *verificationCode;
@property (strong, nonatomic) IBOutlet UIView *invalidCodeView;

- (IBAction)verifyBtnPressed:(id)sender;
- (IBAction)invalidCodeOkPressed:(id)sender;




@end
