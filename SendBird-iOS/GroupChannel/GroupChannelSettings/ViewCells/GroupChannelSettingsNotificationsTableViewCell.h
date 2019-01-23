//
//  GroupChannelSettingsNotificationsTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 2/27/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupChannelSettingsTableViewCellDelegate.h"

@interface GroupChannelSettingsNotificationsTableViewCell : UITableViewCell

@property(weak, nonatomic) id<GroupChannelSettingsTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;

@end
