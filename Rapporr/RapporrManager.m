//
//  RapporrManager.m
//  Rapporr
//
//  Created by Ahmed Sadiq on 10/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "RapporrManager.h"

@implementation RapporrManager

static RapporrManager *sharedManager;

+ (RapporrManager *) sharedManager
{
    if(sharedManager == nil)
    {
        
        sharedManager = [[RapporrManager alloc] init];
        
    }
    
    return sharedManager;
}

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
