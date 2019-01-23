//
//  SettingsSwitchTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 3/1/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsTableViewCellDelegate.h"

@interface SettingsSwitchTableViewCell : UITableViewCell

@property (weak, nonatomic) id<SettingsTableViewCellDelegate> delegate;

@property (strong) NSString *switchIdentifier;
@property (weak, nonatomic) IBOutlet UIView *bottomBorderView;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;

@end
