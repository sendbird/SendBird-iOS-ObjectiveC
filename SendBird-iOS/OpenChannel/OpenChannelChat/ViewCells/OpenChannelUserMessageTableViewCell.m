//
//  OpenChannelUserMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 1/23/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "OpenChannelUserMessageTableViewCell.h"

#define kMessageContainerViewBottomMarginNormal 14

@interface OpenChannelUserMessageTableViewCell()

@property (strong) SBDUserMessage *msg;

@end

@implementation OpenChannelUserMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessage:(SBDUserMessage *)message {
    self.msg = message;
    
    [self.resendButton addTarget:self action:@selector(clickResendUserMessageButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *longClickMessageContainerGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickUserMessage:)];
    [self.messageContainerView addGestureRecognizer:longClickMessageContainerGesture];
    
    UILongPressGestureRecognizer *longClickProfileGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickProfile:)];
    [self.profileImageContainerView addGestureRecognizer:longClickProfileGesture];
    
    UITapGestureRecognizer *clickProfileGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProfile:)];
    [self.profileImageContainerView addGestureRecognizer:clickProfileGesture];
    
    self.messageLabel.text = self.msg.message;
    if (self.msg.sender.nickname.length == 0) {
        self.nicknameLabel.text = @" ";
    }
    else {
        self.nicknameLabel.text = self.msg.sender.nickname;
    }
}

- (SBDUserMessage *)getMessage {
    return self.msg;
}

- (void)hideElementsForFailure {
    self.resendButtonContainerView.hidden = YES;
    self.resendButton.enabled = NO;

    self.sendingFailureContainerView.hidden = YES;
    
    self.messageContainerViewBottomMargin.constant = 0;
}

- (void)showElementsForFailure {
    self.resendButtonContainerView.hidden = NO;
    self.resendButton.enabled = YES;
    
    self.sendingFailureContainerView.hidden = NO;
    
    self.messageContainerViewBottomMargin.constant = kMessageContainerViewBottomMarginNormal;
}

- (void)clickResendUserMessageButton:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickResendUserMessageButton:)]) {
        [self.delegate didClickResendUserMessageButton:self.msg];
    }
}

- (void)longClickProfile:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didLongClickUserProfile:)]) {
            [self.delegate didLongClickUserProfile:self.msg.sender];
        }
    }
}

- (void)longClickUserMessage:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didLongClickUserMessage:)]) {
            [self.delegate didLongClickUserMessage:self.msg];
        }
    }
}

- (void)clickProfile:(UITapGestureRecognizer *)recognizer {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickUserProfile:)]) {
        [self.delegate didClickUserProfile:self.msg.sender];
    }
}

@end
