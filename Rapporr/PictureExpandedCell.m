//
//  PictureExpandedCell.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/4/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "PictureExpandedCell.h"

@implementation PictureExpandedCell

static void *MessageISSENTKVOContext = &MessageISSENTKVOContext;
static void *MessageISSEENKVOContext = &MessageISSEENKVOContext;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    [_seenByProgress setProgressBarWidth:(3.0f)];
    [_seenByProgress setProgressBarProgressColor:([UIColor colorFromHexCode:@"#18B264"])];
    [_seenByProgress setProgressBarTrackColor:([UIColor colorFromHexCode:@"#CCCCCC"])];
    // Hint View Customization
    [_seenByProgress setHintViewSpacing:(3.0f)];
    [_seenByProgress setHintViewBackgroundColor:([UIColor clearColor])];
    [_seenByProgress setHintTextFont:(ROBOTO_LIGHT(7))];
    [_seenByProgress setHintTextColor:([UIColor blackColor])];
    [_seenByProgress setHintHidden:NO];
    [_seenByProgress setHidden:YES];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    self.announcementImg.image = NULL;
    [self.announcementImg sd_cancelCurrentImageLoad];
    self.profileImg.image = NULL;
    [self.profileImg sd_cancelCurrentImageLoad];
}



- (void) customizeCell : (RPConverstionMessage*)message andIndexPath :(NSIndexPath*)indexPath andTimeStr : (NSString*)string {
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapGestureRecognizer.delegate = self;
    
        
    NSURL *imageUrl = [NSURL URLWithString:message.thumbImage];
    UIImage *placeHolderImage = message.placeHolderImage;
    
    if (!placeHolderImage) {
        placeHolderImage = SET_IMAGE(@"placeholder_message");
    }
    
    [self.announcementImg setImageWithURL:imageUrl placeholderImage:placeHolderImage options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [self.announcementImg addGestureRecognizer:tapGestureRecognizer];
    
    if(message.user.avatarUrl.length > 1) {
        NSURL *imageUrl = [NSURL URLWithString:message.user.avatarUrl];
        
        UIImage *placeholder = [UIImage imageNamed:@"placeholder_user"];
        if([Utils hasCachedImage]){
            placeholder = [Utils loadImage];
        }
        
        [self.profileImg setImageWithURL:imageUrl placeholderImage:placeholder options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    }
    else {
//            [self.profileImg setImageWithString:message.user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
        self.contactTxtLbl.text = [Utils getInitialsFromString:message.user.name];
        self.contactTxtLbl.hidden = false;
        self.contactTxtLbl.backgroundColor = [UIColor colorFromHexCode:@"#FF9433"];
    }
    
    
    self.titleLbl.text = message.user.fName;
    self.profileImg.layer.cornerRadius = 5.0;
    self.profileImg.clipsToBounds = YES;
    self.dateLbl.text = [NSDate dateTimeForRapporr:message.timeStamp];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.downArrowImg.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
    
    if ([message.userId isEqualToString:[RapporrManager sharedManager].vcModel.userId] ) {
        self.orangeBar.hidden = false;
        self.blueBar.hidden = true;
        self.orangeBar.backgroundColor = App_OrangeColor;
        self.bottomView.backgroundColor = App_OrangeColor;
    }else{
        self.orangeBar.hidden = true;
        self.blueBar.hidden = false;
        self.bottomView.backgroundColor = App_BlueColor;
    }
    
    if(indexPath.row == 0) {
        self.topView.hidden = false;
        self.headerTitle.text = string;
        //self.sepratorView.hidden = true;
    }
    else {
        self.topView.hidden = true;
        self.sepratorView.hidden = false;
    }
    
    
    if (message.isField) {
        self.imgViewMessageStatus.image = SET_IMAGE(@"failure_state");
    }
    
    if (!message.isSentMessage) {
//        self.activityIndicator.hidden = NO;
//        [self.activityIndicator startAnimating];
    }else{
        self.imgViewMessageStatus.image = SET_IMAGE(@"delivered_state");
    }
    [self updateSeenStatusForMessage];
    [self setupKVO];
    
}

- (void)setupKVO
{
    [self.message rz_addTarget:self
                        action:@selector(setImage)
              forKeyPathChange:@"isSentMessage"];
    
    [self.message rz_addTarget:self
                        action:@selector(updateSeenStatusForMessage)
              forKeyPathChange:@"seenByCount"];
    
    [self.message rz_addTarget:self
                        action:@selector(updateSeenStatusForMessage)
              forKeyPathChange:@"isField"];
    
}


-(void)updateSeenStatusForMessage
{
    
    CGFloat totalMembers  = [self.conversation.members count];
    CGFloat messageSeenBy = [self.message.seenByCount floatValue];
    
    if (messageSeenBy >= 2) {
        
        self.seenByLbl.hidden = NO;
        self.seenByProgress.hidden = NO;
        self.imgViewMessageStatus.image  = SET_IMAGE(@"sent_state");
        self.imgViewMessageStatus.hidden = YES;
        
        [self.seenByProgress setHintTextGenerationBlock:^NSString *(CGFloat progress) {
            return [NSString stringWithFormat:@"%.0f / %.0f", progress * totalMembers , totalMembers];
        }];
        
        [self.seenByProgress setProgress:(messageSeenBy/totalMembers) animated:NO duration:0.2f];
        self.seenByLbl.text = [self getSeenBy:self.message];
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
        seenText = [NSString stringWithFormat:@"%@ and %d others have seen this message", (ConversationUser *)[message.seenByUsers objectAtIndex:0].fName,(int)[message.seenByUsers count]-1];
        
    }
    return seenText;
}


-(void)setImage
{
//    self.activityIndicator.hidden = YES;
    
    if (self.message.isSentMessage) {
//        [self.activityIndicator stopAnimating];
        self.imgViewMessageStatus.image  = SET_IMAGE(@"sent_state");
        self.imgViewMessageStatus.animationDuration = 0.2f;
        self.imgViewMessageStatus.animationRepeatCount = 0;
        [self.imgViewMessageStatus startAnimatingWithCompletionBlock:^(BOOL success) {
            self.imgViewMessageStatus.image = SET_IMAGE(@"delivered_state");
        }];
    }else if (self.message.isField){
        self.imgViewMessageStatus.image = SET_IMAGE(@"failure_state");
    }
}


- (IBAction)btnMessageDetails:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didShowMessageDetailsPressed:)]) {
        [self.delegate didShowMessageDetailsPressed:self.message];
    }
}

- (IBAction)btnMakeCall:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMakeCallPressed:)]) {
        [self.delegate didMakeCallPressed:self.message];
    }
}

- (IBAction)btnTranslate:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTranslateMessagePressed:atIndexPath:)]) {
        [self.delegate didTranslateMessagePressed:self.message atIndexPath:self.indexPath];
    }
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
        
        NSURL *imageUrl = nil;
        
        if ([self.message.contentType isEqualToString:MESSAGE_CONTENT_TYPESharePhoto]) {
            imageUrl = [NSURL URLWithString:self.message.imageUrl];
        }else if ([self.message.contentType isEqualToString:MESSAGE_CONTENT_TYPEAnnouncement]) {
            if ([self.message.announcement.attachment.contentType isEqualToString:ATTACHMENT_CONTENT_TYPE_Photo]) {
                imageUrl = [NSURL URLWithString:self.message.announcement.attachment.image];
            }
        }
        
        TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImageURL:imageUrl];
        viewController.transitioningDelegate = (id)self;
        [self.context presentViewController:viewController animated:YES completion:nil];
        
    }
}


//- (void)dealloc
//{
//    @try{
//        
//        [self.message removeObserver:self forKeyPath:@"isSentMessage" context:&MessageISSENTKVOContext];
//    }@catch(id anException){
//        NSLog(@"%@",anException);
//    }
//    @try{
//        
//        [self.message removeObserver:self forKeyPath:@"seenByCount" context:&MessageISSEENKVOContext];
//        NSLog(@"DEALLOC CELL");
//    }@catch(id anException){
//        NSLog(@"%@",anException);
//    }
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    if (context == &MessageISSENTKVOContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(isSentMessage))]) {
            if ([object isSentMessage]) {
                [self setImage];
                
                @try {
                    [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(isSentMessage))];
                }
                @catch (NSException * __unused exception) {
                    
                }
            }
        }
    }
    else if (context == &MessageISSEENKVOContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(seenByCount))]) {
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
}


@end
