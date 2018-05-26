//
//  AnnouncementModel.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/23/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "AnnouncementModel.h"

@implementation AnnouncementModel


- (id)initWithDictionary:(NSDictionary *) responseData;
{    
    self = [super init];
    if (self) {
        
        self.contentType    = [NSString validStringForObject:responseData[@"contentType"]];
        self.content        = [NSString validStringForObject:responseData[@"content"]];
        self.title          = [NSString validStringForObject:responseData[@"title"]];
        self.announcement   = [NSString validStringForObject:responseData[@"announcement"]];
        self.attachment     = [[AttachmentModel alloc] initWithDictionary:responseData];
    }
    
    return self;
}

+ (NSMutableArray *)parseAttachments:(NSArray *)array;
{
    //    https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/ClassMethod.html
    
    NSMutableArray *attachments = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in array) {
    }
    return attachments;
}

@end
