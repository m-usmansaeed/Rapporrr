//
//  SuccessRapporVC.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 27/03/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuccessRapporVC : UIViewController
{

}

@property (nonatomic) AFNetworkReachabilityStatus seachabilityStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *successMessageView;

@end
