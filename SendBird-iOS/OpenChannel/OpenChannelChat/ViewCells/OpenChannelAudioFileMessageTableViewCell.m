//
//  OpenChannelAudioFileMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/8/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import "OpenChannelAudioFileMessageTableViewCell.h"

#define kMessageContainerViewBottomMarginNormal 14

@interface OpenChannelAudioFileMessageTableViewCell()

@property (strong) SBDFileMessage *msg;

@end

@implementation OpenChannelAudioFileMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessage:(SBDFileMessage *)message {
    self.msg = message;
    
    UITapGestureRecognizer *clickMessageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMessage)];
    [self.messageContainerView addGestureRecognizer:clickMessageGesture];
    
    UILongPressGestureRecognizer *longClickMessageGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickMessage:)];
    [self.messageContainerView addGestureRecognizer:longClickMessageGesture];
    
    UILongPressGestureRecognizer *longClickProfileGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickProfile:)];
    [self.profileContainerView addGestureRecognizer:longClickProfileGesture];
    
    UITapGestureRecognizer *clickProfileGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProfile)];
    [self.profileContainerView addGestureRecognizer:clickProfileGesture];

    self.filenameLabel.text = self.msg.name;
    
    if (self.msg.sender.nickname.length == 0) {
        self.nicknameLabel.text = @" ";
    }
    else {
        self.nicknameLabel.text = self.msg.sender.nickname;
    }
}

- (SBDFileMessage *)getMessage {
    return self.msg;
}

- (void)showProgress:(CGFloat)progress {
    self.fileTransferProgressViewContainerView.hidden = NO;
    self.sendingFailureContainerView.hidden = YES;
    
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
}

- (void)showBottomMargin {
    self.messageContainerViewBottomMargin.constant = kMessageContainerViewBottomMarginNormal;
}

- (void)hideBottomMargin {
    self.messageContainerViewBottomMargin.constant = 0;
}

- (void)clickMessage {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickGeneralFileMessage:)]) {
        [self.delegate didClickGeneralFileMessage:self.msg];
    }
}

- (void)longClickMessage:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didLongClickGeneralFileMessage:)]) {
            [self.delegate didLongClickGeneralFileMessage:self.msg];
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

- (void)clickProfile {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickUserProfile:)]) {
        [self.delegate didClickUserProfile:self.msg.sender];
    }
}

@end
