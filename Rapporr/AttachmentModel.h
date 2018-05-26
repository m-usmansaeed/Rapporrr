//
//  AttachmentModel.h
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/22/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ATTACHMENT_CONTENT_TYPE_Photo;
extern NSString * const ATTACHMENT_CONTENT_TYPE_URL;
extern NSString * const ATTACHMENT_CONTENT_TYPE_BOTH;
extern NSString * const ATTACHMENT_CONTENT_TYPE_TEXT;


@interface AttachmentModel : NSObject

@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *localUrl;
@property (strong, nonatomic) NSString *fileExt;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *image;
@property (strong, nonatomic) NSString *thumbnail;
@property (strong, nonatomic) UIImage  *placeHolderImage;
@property (strong, nonatomic) NSString *mimeType;


+ (NSMutableArray *)parseAttachments:(NSArray *)array;
- (id)initWithDictionary:(NSDictionary *) responseData;



@end
