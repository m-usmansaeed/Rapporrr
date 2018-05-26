//
//  FileAttachmentCell.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 5/31/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "FileAttachmentCell.h"
#import "FRHyperLabel.h"
#import "TGRImageViewController.h"

@implementation FileAttachmentCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    /*[_seenByProgress setProgressBarWidth:(4.0f)];
    [_seenByProgress setProgressBarProgressColor:([UIColor colorFromHexCode:@"#18B264"])];
    [_seenByProgress setProgressBarTrackColor:([UIColor colorFromHexCode:@"#CCCCCC"])];
    // Hint View Customization
    [_seenByProgress setHintViewSpacing:(4.0f)];
    [_seenByProgress setHintViewBackgroundColor:([UIColor clearColor])];
    [_seenByProgress setHintTextFont:(ROBOTO_LIGHT(8))];
    [_seenByProgress setHintTextColor:([UIColor blackColor])];
    
    
    self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallClipRotate  tintColor:[UIColor lightGrayColor]];
    self.activityIndicatorView.frame = CGRectMake(0, 0, 39, 39);
    [self.spinner addSubview:self.activityIndicatorView];*/
       
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)configureCell:(FileAttachmentCell *)cell;
{
    
    RPConverstionMessage *message = (RPConverstionMessage *)self.objc;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([message.userId isEqualToString:[RapporrManager sharedManager].vcModel.userId] ) {
            
            self.messageContainer.backgroundColor = [UIColor whiteColor];
            self.buttonViewContainer.backgroundColor = App_OrangeColor;
            self.rightSeparator.hidden = NO;
            self.leftSeparator.hidden = YES;
            
        }else{
            
            self.messageContainer.backgroundColor = [UIColor whiteColor];
            self.buttonViewContainer.backgroundColor = App_BlueColor;
            self.rightSeparator.hidden = YES;
            self.leftSeparator.hidden = NO;
        }
        
        [self.avtarImgView setImage:SET_IMAGE(@"")];
        [self.successImageView setImage:SET_IMAGE(@"")];
        self.lblTitle.text   = message.senderName;
        
        
        NSString *fileUrl = [message.attachment.url pathExtension];
        NSArray *tempArray = [fileUrl componentsSeparatedByString:@"?"];
        NSString *fileExt = [tempArray objectAtIndex:0];
        self.fileTitle.text = [NSString stringWithFormat:@"%@.%@",message.attachment.title,fileExt];
        

        
        ConversationUser *user = message.user;
        if (message.timeStamp) {
            self.lblDate.text = [NSDate dateTimeForRapporr:message.timeStamp];
        }
        
        if(user.avatarUrl.length > 1) {
            NSURL *imageUrl = [NSURL URLWithString:user.avatarUrl];
            
            [self.avtarImgView setImageWithURL:imageUrl placeholderImage:message.placeHolderImage options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        }
        else {
//            [self.avtarImgView setImageWithString:user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
        }
        
        
        if (!message.isSentMessage) {
            self.successImageView.image = SET_IMAGE(@"failure_state");
            self.seenByProgress.hidden = YES;
        }else{
            self.successImageView.image = SET_IMAGE(@"delivered_state");
            self.seenByProgress.hidden = YES;
        }
        
        if (message.attachment.localUrl) {
            [self setFileImage];
        }
        
        [self updateSeenStatusForMessage];
        
        if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEFileAdded]) {
            [message.attachment addObserver:self forKeyPath:@"localUrl" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        }        
    });
    
    
    
    [message addObserver:self forKeyPath:@"isSentMessage" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [message addObserver:self forKeyPath:@"seenByCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    }

-(void)updateSeenStatusForMessage
{
    __weak __typeof(self)weakSelf = self;
    RPConverstionMessage *message = (RPConverstionMessage *)self.objc;
    
    CGFloat totalMembers  = [self.conversation.members count];
    CGFloat messageSeenBy = [message.seenByCount floatValue];
    
    if (messageSeenBy > 0) {
        
        [self.seenByProgress setHintTextGenerationBlock:^NSString *(CGFloat progress) {
            weakSelf.seenByProgress.hidden = NO;
            weakSelf.successImageView.image  = SET_IMAGE(@"sent_state");
            weakSelf.successImageView.hidden = YES;
            
            NSLog(@"%f",progress * messageSeenBy+1);
            NSLog(@"%f",progress * messageSeenBy);
            
            return [NSString stringWithFormat:@"%.0f / %.0f", progress * totalMembers , totalMembers];
        }];
        
        [self.seenByProgress setProgress:(messageSeenBy/totalMembers) animated:NO duration:0.2f];
        self.lblSeenBy.text = [self getSeenBy:message];
    }
}

-(NSString *)getSeenBy:(RPConverstionMessage *)message{
    
    NSString *seenText = @"";
    
    if ([message.seenByUsers count] == 1) {
        seenText = [NSString stringWithFormat:@"%@ have seen this message", (ConversationUser *)[message.seenByUsers objectAtIndex:0].fName];
    }else if ([message.seenByUsers count] == 2) {
        seenText = [NSString stringWithFormat:@"%@ and %@ have seen this message", (ConversationUser *)[message.seenByUsers objectAtIndex:0].fName,(ConversationUser *)[message.seenByUsers objectAtIndex:1].fName];
    }else if ([message.seenByUsers count] == 3) {
        seenText = [NSString stringWithFormat:@"%@ and %@ and %@ have seen this message", (ConversationUser *)[message.seenByUsers objectAtIndex:0].fName,(ConversationUser *)[message.seenByUsers objectAtIndex:1].fName,(ConversationUser *)[message.seenByUsers objectAtIndex:2].fName];
    }
    else{
        seenText = [NSString stringWithFormat:@"%@ and %lu others have seen this message", (ConversationUser *)[message.seenByUsers objectAtIndex:0].fName,[message.seenByUsers count]-1];
        
    }
    return seenText;
}

-(void)setFileImage
{
    self.imgViewfile.image  = SET_IMAGE(@"file");
}


-(void)setImage
{
    self.successImageView.image  = SET_IMAGE(@"sent_state");
    self.successImageView.animationDuration = 0.2f;
    self.successImageView.animationRepeatCount = 0;
    [self.successImageView startAnimatingWithCompletionBlock:^(BOOL success) {
        self.successImageView.image = SET_IMAGE(@"delivered_state");
    }];
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    
    UIGestureRecognizer *rec = (UIGestureRecognizer *)recognizer;
    
    if ([rec.view isKindOfClass:[FRHyperLabel class]]) {
        
        FRHyperLabel *lable = (FRHyperLabel *)rec.view;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:lable.url]];
        
    }else if ([rec.view isKindOfClass:[UILabel class]]) {
        
        UILabel *lable = (UILabel *)rec.view;
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:lable.text];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        
    }
    else if ([rec.view isKindOfClass:[UIImageView class]]) {
        
        RPConverstionMessage *message = (RPConverstionMessage *)self.objc;
        NSURL *imageUrl = nil;
        
        if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPESharePhoto]) {
            imageUrl = [NSURL URLWithString:message.imageUrl];
        }else if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
            if ([message.announcement.attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_Photo]) {
                imageUrl = [NSURL URLWithString:message.announcement.attachment.image];
            }
        }
        
        TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImageURL:imageUrl];
        viewController.transitioningDelegate = (id)self;
        [self.context presentViewController:viewController animated:YES completion:nil];
        
    }
}

- (IBAction)btnMessageDetails:(id)sender {
    
    RPConverstionMessage *message = (RPConverstionMessage *)self.objc;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didShowMessageDetailsPressed:)]) {
        [self.delegate didShowMessageDetailsPressed:message];
    }
}

- (IBAction)btnMakeCall:(id)sender {
    RPConverstionMessage *message = (RPConverstionMessage *)self.objc;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMakeCallPressed:)]) {
        [self.delegate didMakeCallPressed:message];
    }
}



- (IBAction)btnDownloadFile:(id)sender {

    RPConverstionMessage *message = (RPConverstionMessage *)self.objc;
    
    if (message.attachment.localUrl) {
        

//        NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:message.attachment.localUrl]];
//        UIImage *image = [[UIImage alloc] initWithData:imgData];
//        
//        TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:image];
//        viewController.transitioningDelegate = (id)self;
//        [self.context presentViewController:viewController animated:YES completion:nil];
    }else{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCallDownloadFile:)]) {
        [self.activityIndicatorView startAnimating];
        self.spinner.hidden =NO;
        [self.delegate didCallDownloadFile:message];
    }
    }
}

- (IBAction)btnTranslate:(id)sender {
    
    RPConverstionMessage *message = (RPConverstionMessage *)self.objc;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTranslateMessagePressed:atIndexPath:)]) {
        [self.delegate didTranslateMessagePressed:message atIndexPath:self.indexPath];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(isSentMessage))]) {
        if ([object isSentMessage]) {
            [self setImage];
            
            @try {
                [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(isSentMessage))];
            }
            @catch (NSException * __unused exception) {
                
            }
        }
    }else if ([keyPath isEqualToString:NSStringFromSelector(@selector(seenByCount))]) {
        if ([object seenByCount]) {
            [self updateSeenStatusForMessage];
            
            @try {
                [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(seenByCount))];
            }
            @catch (NSException * __unused exception) {
                
            }
        }
    }
    else if ([keyPath isEqualToString:NSStringFromSelector(@selector(localUrl))]) {
        if ([object localUrl]) {

            [self setFileImage];
            [self.activityIndicatorView stopAnimating];
            self.spinner.hidden =YES;

            @try {
                [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(localUrl))];
            }
            @catch (NSException * __unused exception) {
                
            }
        }
    }
}



@end
