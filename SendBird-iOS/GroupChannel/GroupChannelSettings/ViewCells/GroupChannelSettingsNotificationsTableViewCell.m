//
//  GroupChannelSettingsNotificationsTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 2/27/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelSettingsNotificationsTableViewCell.h"

@implementation GroupChannelSettingsNotificationsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clickSwitch:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didChangeNotificationSwitchButton:)]) {
        [self.delegate didChangeNotificationSwitchButton:sw.isOn];
    }
}

@end
