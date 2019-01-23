//
//  GroupChannelOutgoingUserMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 2/20/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelOutgoingUserMessageTableViewCell.h"
#import "Utils.h"

#define kDateSeperatorContainerViewTopMargin 0
#define kDateSeperatorContainerViewHeight 65
#define kMessageContainerViewTopMarginNormal 6
#define kMessageContainerViewTopMarginReduced 3
#define kMessageContainerViewBottomMarginNormal 14


@interface GroupChannelOutgoingUserMessageTableViewCell()

@property (strong) SBDUserMessage *msg;

@end

@implementation GroupChannelOutgoingUserMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.resendButton addTarget:self action:@selector(clickResendUserMessage:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurrentMessage:(SBDUserMessage *)message previousMessage:(SBDBaseMessage *)prevMessage nextMessage:(SBDBaseMessage *)nextMessage failed:(BOOL)failed {
    BOOL hideDateSeperator = NO;
    BOOL hideMessageStatus = NO;
    BOOL decreaseTopMargin = NO;
    BOOL hideReadCount = NO;
    
    UILongPressGestureRecognizer *longClickMessageContainerGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickUserMessage:)];
    [self.messageContainerView addGestureRecognizer:longClickMessageContainerGesture];
    
    [self.resendButton addTarget:self action:@selector(clickResendUserMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    self.msg = message;
    
    SBDUser *prevMessageSender = nil;
    SBDUser *nextMessageSender = nil;

    self.textMessageLabel.text = self.msg.message;
    
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
                hideReadCount = YES;
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
            hideMessageStatus = NO;
        }
        else {
            hideMessageStatus = YES;
        }
    }
    else {
        hideMessageStatus = NO;
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
    
    if (hideMessageStatus && hideReadCount && !failed) {
        self.messageDateLabel.text = @"";
        self.messageStatusContainerView.hidden = YES;
        self.readStatusContainerView.hidden = YES;
        
        self.resendButtonContainerView.hidden = YES;
        self.resendButton.enabled = NO;
        self.sendingFailureContainerView.hidden = YES;
        
        self.messageContainerViewBottomMargin.constant = 0;
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

- (SBDUserMessage *)getMessage {
    return self.msg;
}

- (void)showReadStatusWithReadCount:(NSUInteger)readCount {
    self.sendingFlagImageView.hidden = YES;
    self.readStatusContainerView.hidden = NO;
    self.readStatusLabel.text = [NSString stringWithFormat:@"Read %lu ∙", readCount];
}

- (void)clickResendUserMessage:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickResendUserMessage:)]) {
        [self.delegate didClickResendUserMessage:self.msg];
    }
}

- (void)longClickUserMessage:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didLongClickUserMessage:)]) {
            [self.delegate didLongClickUserMessage:self.msg];
        }
    }
}

@end
