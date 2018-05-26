//
//  BaseEntity.h
//  LawNote
//
//  Created by Samreen Noor on 22/07/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Constants.h"

@interface BaseEntity : NSObject
-(NSString *) validStringForObject:(NSString *) object;
-(NSString *) completeImageURL:(NSString *) shortURL;
+ (id)entityName;


@end
