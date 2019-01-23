//
//  GroupChannelOutgoingImageVideoFileMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 2/20/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelOutgoingImageVideoFileMessageTableViewCell.h"
#import "Utils.h"

#define kDateSeperatorContainerViewTopMargin 3
#define kDateSeperatorContainerViewHeight 65
#define kMessageContainerViewTopMarginNormal 6
#define kMessageContainerViewTopMarginReduced 3
#define kMessageContainerViewBottomMarginNormal 14

@interface GroupChannelOutgoingImageVideoFileMessageTableViewCell()

@property (atomic) BOOL hideDateSeperator;
@property (atomic) BOOL hideMessageStatus;
@property (atomic) BOOL decreaseTopMargin;
@property (atomic) BOOL hideReadCount;

@end

@implementation GroupChannelOutgoingImageVideoFileMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imageHash = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurrentMessage:(SBDFileMessage *)message previousMessage:(SBDBaseMessage *)prevMessage nextMessage:(SBDBaseMessage *)nextMessage {
    self.hideDateSeperator = NO;
    self.hideMessageStatus = NO;
    self.decreaseTopMargin = NO;
    self.hideReadCount = NO;
    
    self.msg = message;
    
    UITapGestureRecognizer *clickMessageContainteGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageVideoFileMessage:)];
    [self.messageContainerView addGestureRecognizer:clickMessageContainteGesture];
    
    UILongPressGestureRecognizer *longClickMessageContainerGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickImageVideoFileMessage:)];
    [self.messageContainerView addGestureRecognizer:longClickMessageContainerGesture];
    
    [self.resendButton addTarget:self action:@selector(clickResendImageVideoFileMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    SBDUser *prevMessageSender = nil;
    SBDUser *nextMessageSender = nil;
    
    if (prevMessage != nil) {
        if ([prevMessage isKindOfClass:[SBDUserMessage class]]) {
            prevMessageSender = ((SBDUserMessage *)prevMessage).sender;
        }
        else if ([prevMessage isKindOfClass:[SBDFileMessage class]]) {
            prevMessageSender = ((SBDFileMessage *)prevMessage).sender;
        }
    }
    
    if (nextMessage != nil) {
        if ([nextMessage isKindOfClass:[SBDUserMessage class]]) {
            nextMessageSender = ((SBDUserMessage *)nextMessage).sender;
        }
        else if ([nextMessage isKindOfClass:[SBDFileMessage class]]) {
            nextMessageSender = ((SBDFileMessage *)nextMessage).sender;
        }
        
        if (nextMessageSender != nil && [nextMessageSender.userId isEqualToString:self.msg.sender.userId]) {
            NSUInteger nextReadCount = [self.channel getReadMembersWithMessage:nextMessage includeAllMembers:NO].count;
            NSUInteger currReadCount = [self.channel getReadMembersWithMessage:self.msg includeAllMembers:NO].count;
            if (nextReadCount == currReadCount || nextMessage.messageId != 0) {
                self.hideReadCount = YES;
            }
        }
    }
    
    if (prevMessage != nil && [Utils checkDayChangeDayBetweenOldTimestamp:prevMessage.createdAt newTimestamp:self.msg.createdAt]) {
        self.hideDateSeperator = NO;
    }
    else {
        self.hideDateSeperator = YES;
    }
    
    if (prevMessageSender != nil && [prevMessageSender.userId isEqualToString:self.msg.sender.userId]) {
        if (self.hideDateSeperator) {
            self.decreaseTopMargin = YES;
        }
        else {
            self.decreaseTopMargin = NO;
        }
    }
    else {
        self.decreaseTopMargin = NO;
    }
    
    if (nextMessageSender != nil && [nextMessageSender.userId isEqualToString:self.msg.sender.userId]) {
        if ([Utils checkDayChangeDayBetweenOldTimestamp:self.msg.createdAt newTimestamp:nextMessage.createdAt]) {
            self.hideMessageStatus = NO;
        }
        else {
            self.hideMessageStatus = YES;
        }
    }
    else {
        self.hideMessageStatus = NO;
    }
    
    if (self.hideDateSeperator) {
        self.dateSeperatorContainerView.hidden = YES;
        self.dateSeperatorContainerViewHeight.constant = 0;
        self.dateSeperatorContainerViewTopMargin.constant = 0;
    }
    else {
        self.dateSeperatorContainerView.hidden = NO;
        self.dateSeperatorLabel.text = [Utils getDateStringForDateSeperatorFromTimestamp:self.msg.createdAt];
        self.dateSeperatorContainerViewHeight.constant = kDateSeperatorContainerViewHeight;
        self.dateSeperatorContainerViewTopMargin.constant = kDateSeperatorContainerViewTopMargin;
    }

    if (self.decreaseTopMargin) {
        self.messageContainerViewTopMargin.constant = kMessageContainerViewTopMarginReduced;
    }
    else {
        self.messageContainerViewTopMargin.constant = kMessageContainerViewTopMarginNormal;
    }

    if (self.hideMessageStatus && self.hideReadCount) {
        self.messageDateLabel.text = @"";
        self.messageStatusContainerView.hidden = YES;
        self.readStatusContainerView.hidden = YES;
        [self hideBottomMargin];
    }
    else {
        if (!self.hideReadCount) {
            self.messageDateLabel.text = [Utils getMessageDateStringFromTimestamp:self.msg.createdAt];
            self.messageStatusContainerView.hidden = NO;
            self.readStatusContainerView.hidden = NO;
            [self showReadStatusWithReadCount:[self.channel getReadMembersWithMessage:self.msg includeAllMembers:NO].count];
            [self hideProgress];
            [self showBottomMargin];
        }
        else {
            self.messageStatusContainerView.hidden = YES;
            self.readStatusContainerView.hidden = YES;
            [self hideReadStatus];
            [self hideBottomMargin];
        }
    }
}

- (SBDFileMessage *)getMessage {
    return self.msg;
}

- (void)showProgress:(CGFloat)progress {
    self.fileTransferProgressViewContainerView.hidden = NO;
    self.sendingFailureContainerView.hidden = YES;
    self.readStatusContainerView.hidden = YES;
    
    [self.fileTransferProgressCircleView drawCircleWithProgress:progress];
    self.fileTransferProgressLabel.text = [NSString stringWithFormat:@"%.2lf%%", (progress * 100.0)];
}

- (void)hideProgress {
    self.fileTransferProgressViewContainerView.hidden = YES;
    self.sendingFailureContainerView.hidden = YES;
}

- (void)hideElementsForFailure {
    self.fileTransferProgressViewContainerView.hidden = YES;
    self.resendButtonContainerView.hidden = YES;
    self.resendButton.enabled = NO;
    self.sendingFailureContainerView.hidden = YES;
}

- (void)showElementsForFailure {
    self.fileTransferProgressViewContainerView.hidden = YES;
    self.resendButtonContainerView.hidden = NO;
    self.resendButton.enabled = YES;
    self.sendingFailureContainerView.hidden = NO;
    self.messageDateLabel.hidden = YES;
}

- (void)showReadStatusWithReadCount:(NSUInteger)readCount {
    self.sendingFlagImageView.hidden = YES;
    self.readStatusContainerView.hidden = NO;
    self.readStatusLabel.text = [NSString stringWithFormat:@"Read %lu ∙", readCount];
    self.messageDateLabel.hidden = NO;
}

- (void)hideReadStatus {
    self.sendingFlagImageView.hidden = YES;
    self.readStatusContainerView.hidden = YES;
}

- (void)showBottomMargin {
    self.messageContainerViewBottomMargin.constant = kMessageContainerViewBottomMarginNormal;
}

- (void)hideBottomMargin {
    self.messageContainerViewBottomMargin.constant = 0;
}

- (void)hideAllPlaceholders {
    self.videoPlayIconImageView.hidden = YES;
    self.imageMessagePlaceholderImageView.hidden = YES;
    self.videoMessagePlaceholderImageView.hidden = YES;
}

- (void)clickImageVideoFileMessage:(UITapGestureRecognizer *)recognizer {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickImageVideoFileMessage:)]) {
        [self.delegate didClickImageVideoFileMessage:self.msg];
    }
}

- (void)longClickImageVideoFileMessage:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didLongClickImageVideoFileMessage:)]) {
            [self.delegate didLongClickImageVideoFileMessage:self.msg];
        }
    }
}

- (void)clickResendImageVideoFileMessage:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickResendImageVideoFileMessage:)]) {
        [self.delegate didClickResendImageVideoFileMessage:self.msg];
    }
}

- (void)setAnimatedImage:(FLAnimatedImage *)image hash:(NSUInteger)hash {
    if (image == nil || hash == 0) {
        self.imageHash = 0;
        self.imageFileMessageImageView.animatedImage = nil;
    }
    else {
        if (self.imageHash == 0 || self.imageHash != hash) {
            self.imageFileMessageImageView.image = nil;
            [self.imageFileMessageImageView setAnimatedImage:image];
            self.imageHash = hash;
        }
    }
}

- (void)setImage:(UIImage *)image {
    if (image == nil) {
        self.imageHash = 0;
        self.imageFileMessageImageView.image = nil;
    }
    else {
        NSUInteger newImageHash = UIImageJPEGRepresentation(image, 0.5).hash;
        if (self.imageHash == 0 || self.imageHash != newImageHash) {
            self.imageFileMessageImageView.animatedImage = nil;
            self.imageHash = newImageHash;
        }
        [self.imageFileMessageImageView setImage:image];
    }
}

@end
