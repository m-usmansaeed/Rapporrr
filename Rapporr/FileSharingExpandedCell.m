//
//  FileSharingExpandedCell.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/4/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "FileSharingExpandedCell.h"

@implementation FileSharingExpandedCell

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
    //
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    self.profileImg.image = NULL;
    [self.profileImg sd_cancelCurrentImageLoad];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void) customizeCell : (RPConverstionMessage*)message andIndexPath :(NSIndexPath*)indexPath andTimeStr : (NSString*)string {
    if(message.user.avatarUrl.length > 1) {
        NSURL *imageUrl = [NSURL URLWithString:message.user.avatarUrl];
        [self.profileImg setImageWithURL:imageUrl placeholderImage:message.placeHolderImage options:SDWebImageRetryFailed usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    }
    else {
//        [self.profileImg setImageWithString:message.user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
        self.contactTxtLbl.text = [Utils getInitialsFromString:message.user.name];
        self.contactTxtLbl.hidden = false;
        self.contactTxtLbl.backgroundColor = [UIColor colorFromHexCode:@"#FF9433"];

    }
    
    self.downArrowImg.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));

    NSString *fileUrl = [message.attachment.url pathExtension];
    NSArray *tempArray = [fileUrl componentsSeparatedByString:@"?"];
    NSString *fileExt = [tempArray objectAtIndex:0];
    self.contactTitle.text = [NSString stringWithFormat:@"%@.%@",message.attachment.title,fileExt];
    self.announcementTitle.text = message.senderName;
    
    
    self.profileImg.layer.cornerRadius = 5.0;
    self.profileImg.clipsToBounds = YES;
    self.dateLbl.text = [NSDate dateTimeForRapporr:message.timeStamp];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([message.userId isEqualToString:[RapporrManager sharedManager].vcModel.userId] ) {
        self.orangeBar.hidden = false;
        self.blueBar.hidden = true;
        self.orangeBar.backgroundColor = App_OrangeColor;
        self.bottomView.backgroundColor = App_OrangeColor;
    }else{
        self.orangeBar.hidden = true;
        self.blueBar.hidden = false;
        self.bottomView.backgroundColor = App_BlueColor;
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


-(void)setFileImage
{
    self.fileImage.image  = SET_IMAGE(@"file");
    [self.downloadActivityIndicator stopAnimating];
    
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

- (IBAction)btnDownloadFile:(id)sender {
    
    if (self.message.attachment.localUrl) {}
    else{
        [self.downloadActivityIndicator startAnimating];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didCallDownloadFile:)]) {
            [self.delegate didCallDownloadFile:self.message];
        }
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




@end
