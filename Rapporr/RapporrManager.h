//
//  RapporrManager.h
//  Rapporr
//
//  Created by Ahmed Sadiq on 10/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VerifiedCompanyModel.h"

@interface RapporrManager : NSObject

@property (strong, nonatomic) VerifiedCompanyModel *vcModel;


+ (RapporrManager *) sharedManager;
+ (UIImage*) drawText:(NSString*) text inImage:(UIImage*)  image atPoint:(CGPoint)   point;
@end
