//
//  GroupChannelIncomingUserMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 2/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelIncomingUserMessageTableViewCell.h"
#import "Utils.h"

#define kDateSeperatorConatinerViewTopMargin 3
#define kDateSeperatorContainerViewHeight 65
#define kNicknameContainerViewTopMargin 3
#define kMessageContainerViewTopMarginNormal 6
#define kMessageContainerViewTopMarginNoNickname 3
#define kMessageContainerViewBottomMarginNormal 14

@interface GroupChannelIncomingUserMessageTableViewCell()

@property (strong) SBDUserMessage *msg;

@end

@implementation GroupChannelIncomingUserMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurrentMessage:(SBDUserMessage *)message previousMessage:(SBDBaseMessage *)prevMessage nextMessage:(SBDBaseMessage *)nextMessage {
    BOOL hideDateSeperator = NO;
    BOOL hideProfileImage = NO;
    BOOL hideNickname = NO;
    
    UILongPressGestureRecognizer *longClickMessageContainerGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickUserMessage:)];
    [self.messageContainerView addGestureRecognizer:longClickMessageContainerGesture];
    
    UILongPressGestureRecognizer *longClickProfileGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickProfile:)];
    [self.profileContainerView addGestureRecognizer:longClickProfileGesture];

    UITapGestureRecognizer *clickProfileGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProfile:)];
    [self.profileContainerView addGestureRecognizer:clickProfileGesture];
    
    SBDUser *prevMessageSender = nil;
    SBDUser *nextMessageSender = nil;
    self.msg = message;
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
    }
    
    if (prevMessage != nil && [Utils checkDayChangeDayBetweenOldTimestamp:prevMessage.createdAt newTimestamp:self.msg.createdAt]) {
        hideDateSeperator = NO;
    }
    else {
        hideDateSeperator = YES;
    }
    
    if (prevMessageSender != nil && [prevMessageSender.userId isEqualToString:self.msg.sender.userId]) {
        if (hideDateSeperator) {
            hideNickname = YES;
        }
        else {
            hideNickname = NO;
        }
    }
    else {
        hideNickname = NO;
    }
    
    if (nextMessageSender != nil && [nextMessageSender.userId isEqualToString:self.msg.sender.userId]) {
        if ([Utils checkDayChangeDayBetweenOldTimestamp:self.msg.createdAt newTimestamp:nextMessage.createdAt]) {
            hideProfileImage = NO;
        }
        else {
            hideProfileImage = YES;
        }
    }
    else {
        hideProfileImage = NO;
    }

    if (hideDateSeperator) {
        self.dateSeperatorContainerView.hidden = YES;
        self.dateSeperatorLabel.text = @"";
        self.dateSeperatorContainerViewHeight.constant = 0;
        self.dateSeperatorConatinerViewTopMargin.constant = 0;
        self.nicknameContainerViewTopMargin.constant = 0;
    }
    else {
        self.dateSeperatorContainerView.hidden = NO;
        self.dateSeperatorLabel.text = [Utils getDateStringForDateSeperatorFromTimestamp:self.msg.createdAt];
        self.dateSeperatorContainerViewHeight.constant = kDateSeperatorContainerViewHeight;
        self.dateSeperatorConatinerViewTopMargin.constant = kDateSeperatorConatinerViewTopMargin;
        self.nicknameContainerViewTopMargin.constant = kNicknameContainerViewTopMargin;
    }

    if (hideNickname) {
        self.nicknameLabel.text = @"";

        self.nicknameContainerViewTopMargin.constant = 0;
        self.messageContainerViewTopMargin.constant = kMessageContainerViewTopMarginNoNickname;
    }
    else {
        if (self.msg.sender.nickname.length == 0) {
            self.nicknameLabel.text = @" ";
        }
        else {
            self.nicknameLabel.text = self.msg.sender.nickname;
        }

        self.nicknameContainerViewTopMargin.constant = kNicknameContainerViewTopMargin;
        self.messageContainerViewTopMargin.constant = kMessageContainerViewTopMarginNormal;
    }

    if (hideProfileImage) {
        self.messageDateLabel.text = @"";

        self.profileContainerView.hidden = YES;
        self.messageStatusContainerView.hidden = YES;
        self.messageContainerViewBottomMargin.constant = 0;
    }
    else {
        self.messageDateLabel.text = [Utils getMessageDateStringFromTimestamp:self.msg.createdAt];

        self.profileContainerView.hidden = NO;
        self.messageStatusContainerView.hidden = NO;
        self.messageContainerViewBottomMargin.constant = kMessageContainerViewBottomMarginNormal;
    }
}

- (SBDUserMessage *)getMessage {
    return self.msg;
}

- (void)longClickUserMessage:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didLongClickUserMessage:)]) {
            [self.delegate didLongClickUserMessage:self.msg];
        }
    }
}

- (void)longClickProfile:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didLongClickUserProfile:)]) {
            [self.delegate didLongClickUserProfile:self.msg.sender];
        }
    }
}

- (void)clickProfile:(UITapGestureRecognizer *)recognizer {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickUserProfile:)]) {
        [self.delegate didClickUserProfile:self.msg.sender];
    }
}

@end
