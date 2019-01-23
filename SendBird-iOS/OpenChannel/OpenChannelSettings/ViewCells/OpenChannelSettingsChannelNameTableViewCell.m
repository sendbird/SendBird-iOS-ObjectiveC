//
//  OpenChannelSettingsChannelNameTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 2/7/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "OpenChannelSettingsChannelNameTableViewCell.h"

@implementation OpenChannelSettingsChannelNameTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.channelCoverImageView setUserInteractionEnabled:NO];
    self.channelNameTextField.enabled = NO;
    [self.enableEditButton addTarget:self action:@selector(clickEnableEditButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)clickEnableEditButton {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickChannelCoverImageNameEdit)]) {
        [self.delegate didClickChannelCoverImageNameEdit];
    }
}

- (void)setEnableEditing:(BOOL)enable {
    if (enable) {
        self.enableEditButton.hidden = NO;
        self.enableEditButton.enabled = YES;
    }
    else {
        self.enableEditButton.hidden = YES;
        self.enableEditButton.enabled = NO;
    }
}

@end
