//
//  AnnouncementModel.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/23/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttachmentModel.h"

@interface AnnouncementModel : NSObject

@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *photoId;
@property (strong, nonatomic) NSString *announcement;

@property (strong, nonatomic) AttachmentModel *attachment;
- (id)initWithDictionary:(NSDictionary *)responseData;


+ (NSMutableArray *)parseAttachments:(NSArray *)array;



@end
