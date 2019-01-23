//
//  SettingsSwitchTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 3/1/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "SettingsSwitchTableViewCell.h"

@implementation SettingsSwitchTableViewCell

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
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didChangeSwitchButton:identifier:)]) {
        [self.delegate didChangeSwitchButton:sw.isOn identifier:self.switchIdentifier];
    }
}


@end
