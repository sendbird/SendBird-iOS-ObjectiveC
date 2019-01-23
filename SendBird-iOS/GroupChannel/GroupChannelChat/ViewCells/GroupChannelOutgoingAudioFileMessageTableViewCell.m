//
//  GroupChannelOutgoingAudioFileMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/7/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import "GroupChannelOutgoingAudioFileMessageTableViewCell.h"
#import "Utils.h"

#define kDateSeperatorContainerViewTopMargin 3
#define kDateSeperatorContainerViewHeight 65
#define kMessageContainerViewTopMarginNormal 6
#define kMessageContainerViewTopMarginReduced 3
#define kMessageContainerViewBottomMarginNormal 14

@interface GroupChannelOutgoingAudioFileMessageTableViewCell()

@property (strong) SBDFileMessage *msg;
@property (atomic) BOOL hideMessageStatus;
@property (atomic) BOOL hideReadCount;

@end

@implementation GroupChannelOutgoingAudioFileMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setCurrentMessage:(SBDFileMessage *)message previousMessage:(SBDBaseMessage *)prevMessage nextMessage:(SBDBaseMessage *)nextMessage failed:(BOOL)failed {
    BOOL hideDateSeperator = NO;
    self.hideMessageStatus = NO;
    BOOL decreaseTopMargin = NO;
    self.hideReadCount = NO;
    
    self.msg = message;
    
    [self.resendButton addTarget:self action:@selector(clickResendAudioFileMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *longClickMessageContainerGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickAudioFileMessage:)];
    [self.messageContainerView addGestureRecognizer:longClickMessageContainerGesture];
    
    UITapGestureRecognizer *clickMessageContainteGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAudioFileMessage:)];
    [self.messageContainerView addGestureRecognizer:clickMessageContainteGesture];
    
    NSAttributedString *filename = [[NSAttributedString alloc] initWithString:self.msg.name attributes:@{
                                                                                                         NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                         NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightRegular],
                                                                                                         }];
    self.fileNameLabel.attributedText = filename;
    
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
            if (nextReadCount == currReadCount) {
                self.hideReadCount = YES;
            }
        }
    }
    
    if (prevMessage != nil && [Utils checkDayChangeDayBetweenOldTimestamp:prevMessage.createdAt newTimestamp:self.msg.createdAt]) {
        hideDateSeperator = NO;
    }
    else {
        hideDateSeperator = YES;
    }
    
    if (prevMessageSender != nil && [prevMessageSender.userId isEqualToString:self.msg.sender.userId]) {
        if (hideDateSeperator) {
            decreaseTopMargin = YES;
        }
        else {
            decreaseTopMargin = NO;
        }
    }
    else {
        decreaseTopMargin = NO;
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
    
    if (hideDateSeperator) {
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
    
    if (decreaseTopMargin) {
        self.messageContainerViewTopMargin.constant = kMessageContainerViewTopMarginReduced;
    }
    else {
        self.messageContainerViewTopMargin.constant = kMessageContainerViewTopMarginNormal;
    }
    
    if (self.hideMessageStatus && self.hideReadCount && !failed) {
        self.messageDateLabel.text = @"";
        self.messageStatusContainerView.hidden = YES;
        self.messageContainerViewBottomMargin.constant = 0;
        self.readStatusContainerView.hidden = YES;
    }
    else {
        self.messageStatusContainerView.hidden = NO;
        
        if (failed) {
            self.messageDateLabel.text = @"";
            self.readStatusContainerView.hidden = YES;
            
            self.resendButtonContainerView.hidden = NO;
            self.resendButton.enabled = YES;
            self.sendingFailureContainerView.hidden = NO;
            
            self.sendingFlagImageView.hidden = YES;
        }
        else {
            self.messageDateLabel.text = [Utils getMessageDateStringFromTimestamp:self.msg.createdAt];
            self.readStatusContainerView.hidden = NO;
            [self showReadStatusWithReadCount:[self.channel getReadMembersWithMessage:self.msg includeAllMembers:NO].count];
            
            self.resendButtonContainerView.hidden = YES;
            self.resendButton.enabled = NO;
            self.sendingFailureContainerView.hidden = YES;
            
            self.sendingFlagImageView.hidden = YES;
        }
        
        self.messageContainerViewBottomMargin.constant = kMessageContainerViewBottomMarginNormal;
    }
}

- (SBDFileMessage *)getMessage {
    return self.msg;
}

- (void)showProgress:(CGFloat)progress {
    if (progress < 1.0) {
        self.fileTransferProgressViewContainerView.hidden = NO;
        self.sendingFailureContainerView.hidden = YES;
        self.readStatusContainerView.hidden = YES;
        
        [self.fileTransferProgressCircleView drawCircleWithProgress:progress];
        self.fileTransferProgressLabel.text = [NSString stringWithFormat:@"%.2lf%%", (progress * 100.0)];
        
        self.messageContainerViewBottomMargin.constant = kMessageContainerViewBottomMarginNormal;
    }
    else {
        self.fileTransferProgressViewContainerView.hidden = YES;
        self.sendingFailureContainerView.hidden = YES;
        self.readStatusContainerView.hidden = NO;
        
        if (self.hideMessageStatus && self.hideReadCount) {
            self.messageContainerViewBottomMargin.constant = 0;
        }
        else {
            self.messageContainerViewBottomMargin.constant = kMessageContainerViewBottomMarginNormal;
        }
    }
}

- (void)hideElementsForFailure {
    self.fileTransferProgressViewContainerView.hidden = YES;
    self.resendButtonContainerView.hidden = YES;
    self.resendButton.enabled = NO;
    self.sendingFailureContainerView.hidden = YES;
    self.messageContainerViewBottomMargin.constant = 0;
}

- (void)showElementsForFailure {
    self.fileTransferProgressViewContainerView.hidden = YES;
    self.resendButtonContainerView.hidden = NO;
    self.resendButton.enabled = YES;
    self.sendingFailureContainerView.hidden = NO;
    self.messageContainerViewBottomMargin.constant = kMessageContainerViewBottomMarginNormal;
}

- (void)showBottomMargin {
    self.messageContainerViewBottomMargin.constant = kMessageContainerViewBottomMarginNormal;
}

- (void)hideBottomMargin {
    self.messageContainerViewBottomMargin.constant = 0;
}

- (void)hideReadStatus {
    self.sendingFlagImageView.hidden = YES;
    self.readStatusContainerView.hidden = YES;
}

- (void)hideProgress {
    self.fileTransferProgressViewContainerView.hidden = YES;
    self.sendingFailureContainerView.hidden = YES;
}

- (void)showReadStatusWithReadCount:(NSUInteger)readCount {
    self.sendingFlagImageView.hidden = YES;
    self.readStatusContainerView.hidden = NO;
    self.readStatusLabel.text = [NSString stringWithFormat:@"Read %lu ∙", readCount];
}

- (void)longClickAudioFileMessage:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didLongClickGeneralFileMessage:)]) {
            [self.delegate didLongClickGeneralFileMessage:self.msg];
        }
    }
}

- (void)clickResendAudioFileMessage:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickResendAudioGeneralFileMessage:)]) {
        [self.delegate didClickResendAudioGeneralFileMessage:self.msg];
    }
}

- (void)clickAudioFileMessage:(UITapGestureRecognizer *)recognizer {
    if ([self.msg.type hasPrefix:@"audio"]) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickAudioFileMessage:)]) {
            [self.delegate didClickAudioFileMessage:self.msg];
        }
    }
}

@end
