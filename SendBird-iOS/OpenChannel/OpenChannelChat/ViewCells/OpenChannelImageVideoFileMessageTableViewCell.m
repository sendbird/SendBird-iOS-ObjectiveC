//
//  OpenChannelImageVideoFileMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 1/23/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "OpenChannelImageVideoFileMessageTableViewCell.h"

#define kMessageContainerViewBottomMarginNormal 14

@interface OpenChannelImageVideoFileMessageTableViewCell()

@property (strong) SBDFileMessage *msg;

@end

@implementation OpenChannelImageVideoFileMessageTableViewCell

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
    
    [self.resendButton addTarget:self action:@selector(clickResendImageFileMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *longClickMessageGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickMessage:)];
    [self.messageContainerView addGestureRecognizer:longClickMessageGesture];
    
    UITapGestureRecognizer *clickMessageContainterGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageVideoFileMessage:)];
    [self.messageContainerView addGestureRecognizer:clickMessageContainterGesture];
    
    UILongPressGestureRecognizer *longClickProfileGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickProfile:)];
    [self.profileContainerView addGestureRecognizer:longClickProfileGesture];
    
    UITapGestureRecognizer *clickProfileGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProfile:)];
    [self.profileContainerView addGestureRecognizer:clickProfileGesture];
    
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

- (void)hideAllPlaceholders {
    self.videoPlayIconImageView.hidden = YES;
    self.imageMessagePlaceholderImageView.hidden = YES;
    self.videoMessagePlaceholderImageView.hidden = YES;
}

- (void)clickResendImageFileMessage:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickResendImageFileMessageButton:)]) {
        [self.delegate didClickResendImageFileMessageButton:self.msg];
    }
}

- (void)clickImageVideoFileMessage:(UITapGestureRecognizer *)recognizer {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickImageVideoFileMessage:)]) {
        [self.delegate didClickImageVideoFileMessage:self.msg];
    }
}

- (void)longClickMessage:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didLongClickImageVideoFileMessage:)]) {
            [self.delegate didLongClickImageVideoFileMessage:self.msg];
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

- (void)setAnimatedImage:(FLAnimatedImage *)image hash:(NSUInteger)hash {
    if (image == nil || hash == 0) {
        self.imageHash = 0;
        self.fileImageView.animatedImage = nil;
        self.fileImageView.image = nil;
    }
    else {
        if (self.imageHash == 0 || self.imageHash != hash) {
            self.fileImageView.image = nil;
            [self.fileImageView setAnimatedImage:image];
            self.imageHash = hash;
        }
    }
}

- (void)setImage:(UIImage *)image {
    if (image == nil) {
        self.imageHash = 0;
        self.fileImageView.animatedImage = nil;
        self.fileImageView.image = nil;
    }
    else {
        NSUInteger newImageHash = UIImageJPEGRepresentation(image, 0.5).hash;
        if (self.imageHash == 0 || self.imageHash != newImageHash) {
            self.fileImageView.animatedImage = nil;
            [self.fileImageView setImage:image];
            self.imageHash = newImageHash;
        }
    }
}

@end
