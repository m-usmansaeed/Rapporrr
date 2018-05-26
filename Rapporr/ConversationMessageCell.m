//
//  ConversationMessageCell.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 17/04/2017.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "ConversationMessageCell.h"


@implementation ConversationMessageCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [_seenByProgress1 setProgressBarWidth:(4.0f)];
    [_seenByProgress1 setProgressBarProgressColor:([UIColor colorFromHexCode:@"#18B264"])];
    [_seenByProgress1 setProgressBarTrackColor:([UIColor colorFromHexCode:@"#CCCCCC"])];
    // Hint View Customization
    [_seenByProgress1 setHintViewSpacing:(4.0f)];
    [_seenByProgress1 setHintViewBackgroundColor:([UIColor clearColor])];
    [_seenByProgress1 setHintTextFont:(ROBOTO_LIGHT(8))];
    [_seenByProgress1 setHintTextColor:([UIColor blackColor])];
    
}

-(void)layoutSubviews{

}

-(void)prepareForReuse{

    [super prepareForReuse];
    self.lblMeggage.text = nil;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)configureCell:(ConversationMessageCell *)cell;
{
    
    RPConverstionMessage *message = (RPConverstionMessage *)self.objc;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        tapGestureRecognizer.delegate = self;
        
        [self.messageImageView addGestureRecognizer:tapGestureRecognizer];
        
        
        if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPE_TEXT]) {
            self.contactView.hidden = YES;
            [self.lblMeggage setHidden:NO];
            [self.messageImageView setHidden:YES];
            self.eventView.hidden = YES;
        }else{
            //            self.contactView.hidden = NO;
            [self.lblMeggage setHidden:YES];
            [self.messageImageView setHidden:NO];
        }
        
        if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
            //            self.rightSeparator.hidden = NO;
            //            self.leftSeparator.hidden = YES;
        }
        
        if ([message.userId isEqualToString:[RapporrManager sharedManager].vcModel.userId] ) {
            
            if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
                
                self.messageContainer.backgroundColor = App_LightYellowColor;
                self.rightSeparator.backgroundColor   = App_DarkYellowColor;
                self.buttonViewContainer.backgroundColor = App_DarkYellowColor;
                
            }else{
                self.messageContainer.backgroundColor = [UIColor whiteColor];
                self.buttonViewContainer.backgroundColor = App_OrangeColor;
            }
            
            self.rightSeparator.hidden = NO;
            self.leftSeparator.hidden = YES;
            
        }else{
            
            if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
                
                self.messageContainer.backgroundColor = App_LightYellowColor;
                self.leftSeparator.backgroundColor   = App_DarkYellowColor;
                self.buttonViewContainer.backgroundColor = App_DarkYellowColor;
                
            }else{
                self.messageContainer.backgroundColor = [UIColor whiteColor];
                self.buttonViewContainer.backgroundColor = App_BlueColor;
            }
            
            self.rightSeparator.hidden = YES;
            self.leftSeparator.hidden = NO;
        }
        
        
        [self.avtarImgView setImage:SET_IMAGE(@"")];
        [self.lblMeggage setText:@""];
        [self.messageImageView setImage:SET_IMAGE(@"")];
        [self.successImageView setImage:SET_IMAGE(@"")];
        [self.messageImageView setHidden:YES];
        self.lblTitle.text   = message.senderName;
        
        self.lblMeggage.text = message.message;
        
        CGSize newSize = CGSizeZero;
        
        if (![message.message isEqualToString:@""]) {
            if ([cell.lblMeggage.text emo_containsEmoji]) {
                newSize = [cell.lblMeggage heightStringWithEmojis];
            }else{
                newSize = [cell.lblMeggage sizeOfMultiLineLabel];
            }
        }else{
            newSize = CGSizeMake(cell.lblMeggage.frame.size.width, 21);
        }
        
        CGRect rect = self.lblMeggage.frame;
        rect.size.height = newSize.height;
        [self.lblMeggage setFrame:rect];
        
        CGSize translationSize = CGSizeZero;
        
        if (message.translation != nil && ![message.translation isEqualToString:@""]) {
            
            cell.lblTranslation.hidden = NO;
            self.lblTranslation.text = message.translation;
            
            if ([cell.lblTranslation.text emo_containsEmoji]) {
                translationSize = [cell.lblTranslation heightStringWithEmojis];
            }else{
                translationSize = [cell.lblTranslation sizeOfMultiLineLabel];
            }
        }
        
        
        CGRect translationRect = self.lblTranslation.frame;
        translationRect.size.height = translationSize.height;
        translationRect.origin.y = rect.size.height + rect.origin.y;
        [self.lblTranslation setFrame:translationRect];
        
        
        AttachmentModel *attachment = nil;
        if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
            attachment = message.announcement.attachment;
        }
        
        CGRect progressContainerRect = self.prgressViewContainer.frame;
        
        if([message.contentType isEqualToString:MESSAGE_CONTENT_TYPESharePhoto] || [attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_Photo] || [attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_BOTH]) {
            
            progressContainerRect.origin.y = self.messageImageView.frame.origin.y + self.messageImageView.frame.size.height + 5;
            self.contactView.hidden = YES;
            self.eventView.hidden = YES;
            
        }
        else if([attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_URL]) {
            
            progressContainerRect.origin.y = self.eventView.frame.origin.y + self.eventView.frame.size.height + 5;
            self.contactView.hidden = YES;
            self.eventView.hidden = NO;
            
        }
        else{
            if (message.translation != nil && ![message.translation isEqualToString:@""]) {
                progressContainerRect.origin.y = translationRect.origin.y + translationRect.size.height + 5;
            }else{
                progressContainerRect.origin.y = rect.origin.y + rect.size.height + 5;
            }
        }
        
        if([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEShareContact]) {
            self.contactView.hidden = NO;
            progressContainerRect.origin.y = self.contactView.frame.origin.y + self.contactView.frame.size.height + 5;
        }else{
            self.contactView.hidden = YES;
        }
        
        self.prgressViewContainer.frame = progressContainerRect;
        
        CGRect buttonContainerRect = self.buttonViewContainer.frame;
        buttonContainerRect.origin.y = progressContainerRect.origin.y + progressContainerRect.size.height;
        self.buttonViewContainer.frame = buttonContainerRect;
        
        ConversationUser *user = message.user;
        if (message.timeStamp) {
            self.lblDate.text = [NSDate dateTimeForRapporr:message.timeStamp];
        }
        
        
        if ([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
            self.avtarImgView.image = SET_IMAGE(@"announcement_org");
        }else{
            if(user.avatarUrl.length > 1) {
                NSURL *imageUrl = [NSURL URLWithString:user.avatarUrl];
                [self.avtarImgView setImageWithURL:imageUrl placeholderImage:nil options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

            }
            else {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self.avtarImgView setImageWithString:user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
//                });
            }
        }
        
        
        if([message.contentType isEqualToString:MESSAGE_CONTENT_TYPESharePhoto] || [attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_Photo] || [attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_BOTH]) {
            
            NSURL *imageUrl = [NSURL URLWithString:message.thumbImage];
            
            if([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement] && ([attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_Photo] || [attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_BOTH])) {
                
                imageUrl = [NSURL URLWithString:attachment.thumbnail];
            }
            
            [self.lblMeggage setHidden:YES];
            [self.messageImageView setHidden:NO];
            [self.messageImageView setUserInteractionEnabled:YES];
            
            UIImage *placeHolderImage = message.placeHolderImage;
            
            if (!placeHolderImage) {
                placeHolderImage = SET_IMAGE(@"placeholder_message");
            }
            
            
            [self.messageImageView setImageWithURL:imageUrl placeholderImage:placeHolderImage usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            self.contactView.hidden = YES;
            self.eventView.hidden = YES;
            
        }else{
            
            [self.lblMeggage setHidden:NO];
            [self.messageImageView setHidden:YES];
            [self.messageImageView setUserInteractionEnabled:NO];
            
        }
        
        if ([attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_URL]) {
            
            self.eventView.hidden = NO;
            self.lblMeggage.hidden = YES;
            self.contactView.hidden = YES;
            
            UITapGestureRecognizer *hypertextLable = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
            hypertextLable.delegate = self;
            [self.eventUrl addGestureRecognizer:hypertextLable];
            self.eventUrl.url = attachment.url;
            self.lblEventTitle.text = message.announcement.title;
            
            self.eventUrl.text = [NSString stringWithFormat:@"%@ - %@",attachment.title,attachment.url];
            
            self.eventUrl.attributedText = [self.eventUrl.attributedText mutableCopy];
            
            void(^handler)(FRHyperLabel *label, NSString *substring) = ^(FRHyperLabel *label, NSString *substring){
            };
            
            [self.eventUrl setLinksForSubstrings:@[attachment.url] withLinkHandler:handler];
            
        }
        
        if([message.contentType isEqualToString:MESSAGE_CONTENT_TYPEShareContact]) {
            
            self.eventView.hidden = YES;
            self.lblMeggage.hidden = YES;
            self.contactView.hidden = NO;
            
            self.lblContactTitle.text = message.contactModel.title;
            self.lblContactNumber.text = message.contactModel.phone;
            
            UITapGestureRecognizer *hypertextLable = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
            hypertextLable.delegate = self;
            [self.lblContactNumber addGestureRecognizer:hypertextLable];
        }
        
        if (!message.isSentMessage) {
            self.successImageView.image = SET_IMAGE(@"failure_state");
            [self.messageImageView setHidden:NO];
            self.seenByProgress1.hidden = YES;
        }else{
            self.successImageView.image = SET_IMAGE(@"delivered_state");
            [self.messageImageView setHidden:NO];
            self.seenByProgress1.hidden = YES;
        }
        
        [self updateSeenStatusForMessage];
        [cell layoutIfNeeded];

    });
    
    
    
//    [message addObserver:self forKeyPath:@"isSentMessage" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
//    [message addObserver:self forKeyPath:@"seenByCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
}

-(void)updateSeenStatusForMessage
{
    __weak __typeof(self)weakSelf = self;
    RPConverstionMessage *message = (RPConverstionMessage *)self.objc;
    
    CGFloat totalMembers  = [self.conversation.members count];
    CGFloat messageSeenBy = [message.seenByCount floatValue];
    
    if (messageSeenBy > 0) {
        
        [self.seenByProgress1 setHintTextGenerationBlock:^NSString *(CGFloat progress) {
            weakSelf.seenByProgress1.hidden = NO;
            weakSelf.successImageView.image  = SET_IMAGE(@"sent_state");
            weakSelf.successImageView.hidden = YES;
            
            return [NSString stringWithFormat:@"%.0f / %.0f", progress * totalMembers , totalMembers];
        }];
        
        [self.seenByProgress1 setProgress:(messageSeenBy/totalMembers) animated:YES duration:0.2f];
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


-(void)setImage
{
    self.successImageView.image  = SET_IMAGE(@"sent_state");
    self.successImageView.animationDuration = 0.2f;
    self.successImageView.animationRepeatCount = 0;
    [self.successImageView startAnimatingWithCompletionBlock:^(BOOL success) {
        self.successImageView.image = SET_IMAGE(@"delivered_state");
    }];
}


#pragma mark - UIViewControllerTransitioningDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.messageImageView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.messageImageView];
    }
    return nil;
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
}



@end
