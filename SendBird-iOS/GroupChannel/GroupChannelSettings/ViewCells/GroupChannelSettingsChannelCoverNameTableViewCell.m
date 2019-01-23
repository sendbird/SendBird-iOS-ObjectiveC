//
//  GroupChannelSettingsChannelCoverNameTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 2/27/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelSettingsChannelCoverNameTableViewCell.h"

@implementation GroupChannelSettingsChannelCoverNameTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clickEnableEditButton:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(willUpdateChannelNameAndCoverImage)]) {
        [self.delegate willUpdateChannelNameAndCoverImage];
    }
}

@end
