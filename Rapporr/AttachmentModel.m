//
//  AttachmentModel.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/22/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "AttachmentModel.h"

NSString * const ATTACHMENT_CONTENT_TYPE_Photo   = @"photo";
NSString * const ATTACHMENT_CONTENT_TYPE_URL     = @"link";
NSString * const ATTACHMENT_CONTENT_TYPE_BOTH    = @"both";
NSString * const ATTACHMENT_CONTENT_TYPE_TEXT    = @"text";


@implementation AttachmentModel

- (id)initWithDictionary:(NSDictionary *) responseData;
{
    
    self = [super init];
   
    if (self) {
        
        NSDictionary *dict = nil;
        if(responseData[@"attachments"]){
            dict = responseData[@"attachments"];
        }else{
            dict = responseData;
        }
        
            self.category      = [NSString validStringForObject:dict[@"category"]];
            self.title         = [NSString validStringForObject:dict[@"title"]];
            self.url           = [NSString validStringForObject:dict[@"url"]];
            self.email         = [NSString validStringForObject:dict[@"email"]];
            self.phone         = [NSString validStringForObject:dict[@"phone"]];
            self.mimeType      = [NSString validStringForObject:dict[@"mimeType"]];
        
        
        if (![[NSString validStringForObject:dict[@"url"]] isEqualToString:@""] && [[NSString validStringForObject:responseData[@"photoID"]] isEqualToString:@""]) {
            self.contentType   = ATTACHMENT_CONTENT_TYPE_URL;
        }
        else if ([[NSString validStringForObject:dict[@"url"]] isEqualToString:@""] && ![[NSString validStringForObject:responseData[@"photoID"]] isEqualToString:@""])
        {
            self.contentType   = ATTACHMENT_CONTENT_TYPE_Photo;
            self.image         = [NSString stringWithFormat:@"https://images.rapporrapp.com/%@/original",responseData[@"photoID"]];
            self.thumbnail     = [NSString stringWithFormat:@"https://images.rapporrapp.com/%@/thumbnail",responseData[@"photoID"]];
            
        }
        
        
//        else if (![[NSString validStringForObject:dict[@"url"]] isEqualToString:@""] && ![[NSString validStringForObject:responseData[@"photoID"]] isEqualToString:@""]) {
//            
//            self.contentType   = ATTACHMENT_CONTENT_TYPE_BOTH;
//            self.image         = [NSString stringWithFormat:@"https://images.rapporrapp.com/%@/original",responseData[@"photoID"]];
//            self.thumbnail     = [NSString stringWithFormat:@"https://images.rapporrapp.com/%@/thumbnail",responseData[@"photoID"]];
//        }
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



