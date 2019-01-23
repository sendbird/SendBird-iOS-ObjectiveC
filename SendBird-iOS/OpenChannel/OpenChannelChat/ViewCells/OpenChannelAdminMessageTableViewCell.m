//
//  OpenChannelAdminMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 1/23/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "OpenChannelAdminMessageTableViewCell.h"

@interface OpenChannelAdminMessageTableViewCell()

@property (strong) SBDAdminMessage *msg;

@end

@implementation OpenChannelAdminMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessage:(SBDAdminMessage *)message {
    self.msg = message;
    
    UILongPressGestureRecognizer *longClickMessageGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickMessage:)];
    [self.messageContainerView addGestureRecognizer:longClickMessageGesture];
    
    self.messageLabel.text = self.msg.message;
}

- (SBDAdminMessage *)getMessage {
    return self.msg;
}

- (void)setPreviousMessage:(SBDBaseMessage *)prevMessage {
    if (prevMessage != nil) {
        self.messageContainerViewTopMargin.constant = 14;
    }
    else {
        self.messageContainerViewTopMargin.constant = 0;
    }
}

- (void)longClickMessage:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didLongClickAdminMessage:)]) {
            [self.delegate didLongClickAdminMessage:self.msg];
        }
    }
}

@end
