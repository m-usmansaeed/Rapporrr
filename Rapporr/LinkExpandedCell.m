//
//  LinkExpandedCell.m
//  Rapporr
//
//  Created by Rapporr-Dev-MUS on 6/3/17.
//  Copyright © 2017 Rapporr. All rights reserved.
//

#import "LinkExpandedCell.h"

@implementation LinkExpandedCell

static void *MessageISSENTKVOContext = &MessageISSENTKVOContext;
static void *MessageISSEENKVOContext = &MessageISSEENKVOContext;


- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.detailTxt setContentOffset:CGPointZero animated:NO];
    
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
    [_seenByProgress setBackgroundColor:[UIColor clearColor]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    self.profileImg.image = NULL;
    [self.profileImg sd_cancelCurrentImageLoad];
    self.linkLbl.text = @"";

}


- (void) customizeCell : (RPConverstionMessage*)message andIndexPath :(NSIndexPath*)indexPath andTimeStr : (NSString*)string {
//    if(message.user.avatarUrl.length > 1) {
//        NSURL *imageUrl = [NSURL URLWithString:message.user.avatarUrl];
//        [self.profileImg sd_setImageWithURLWithProgress:imageUrl];
//    }
//    else {
//            [self.profileImg setImageWithString:message.user.name color:[UIColor colorFromHexCode:@"#FF9433"] circular:NO];
//    }
    
    self.announcementTitle.text = message.announcement.title;
    self.titleLbl.text = message.user.fName;
    self.detailTxt.text = message.message;
    self.profileImg.layer.cornerRadius = 5.0;
    self.profileImg.clipsToBounds = YES;
    self.dateLbl.text = [NSDate dateTimeForRapporr:message.timeStamp];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _detailTxt.contentInset = UIEdgeInsetsMake(-7.0,0.0,0,0.0);
    
    self.downArrowImg.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
    
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:message.announcement.attachment.url];
    [str addAttribute: NSLinkAttributeName value: message.announcement.attachment.url range: NSMakeRange(0, str.length)];
    self.linkLbl.attributedText = str;
    
    if ([message.userId isEqualToString:[RapporrManager sharedManager].vcModel.userId] ) {
        
        self.orangeBar.hidden = false;
        self.blueBar.hidden = true;
        
    }else{
        
        self.orangeBar.hidden = true;
        self.blueBar.hidden = false;
    }
    
    if(indexPath.row == 0) {
        
        self.topView.hidden = false;
        self.headerTitle.text = string;
        self.sepratorView.hidden = true;
    }
    else {
        self.topView.hidden = true;
        self.sepratorView.hidden = false;
    }
//    if(!toShowLine){
//        self.sepratorView.hidden = true;
//    }
//    [self.message addObserver:self forKeyPath:@"isSentMessage" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&MessageISSENTKVOContext];
    
//    [self.message addObserver:self forKeyPath:@"seenByCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&MessageISSEENKVOContext];
    
    

    [self updateSeenStatusForMessage];
    
    UITapGestureRecognizer *hypertextLable = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    hypertextLable.delegate = self;
    [self.linkLbl addGestureRecognizer:hypertextLable];
    self.linkLbl.url = message.announcement.attachment.url;
    self.linkLbl.text = message.announcement.title;
    
    self.linkLbl.text = [NSString stringWithFormat:@"%@ - %@",message.announcement.attachment.title,message.announcement.attachment.url];
    
    self.linkLbl.attributedText = [self.linkLbl.attributedText mutableCopy];
    
    void(^handler)(FRHyperLabel *label, NSString *substring) = ^(FRHyperLabel *label, NSString *substring){
    };
    
    [self.linkLbl setLinksForSubstrings:@[message.announcement.attachment.url] withLinkHandler:handler];
    
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


- (IBAction)linkClicked:(id)sender {
    NSURL *url = [NSURL URLWithString:_message.announcement.attachment.url];
    
    if (url.scheme.length == 0)
    {
        _message.announcement.attachment.url = [@"http://" stringByAppendingString:_message.announcement.attachment.url];
        url  = [[NSURL alloc] initWithString:_message.announcement.attachment.url];
    }
    
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }else{
        NSLog(@"url not working");
    }
}


@end
