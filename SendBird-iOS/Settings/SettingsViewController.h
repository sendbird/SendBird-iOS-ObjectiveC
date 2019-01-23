//
//  SettingsViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 3/1/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "CustomActivityIndicatorView.h"
#import "SettingsTableViewCellDelegate.h"
#import "SettingsTimePickerTableViewCell.h"
#import "UpdateUserProfileViewController.h"
#import "NotificationDelegate.h"

@interface SettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SettingsTableViewCellDelegate, SettingsTimePickerDelegate, UserProfileImageNameSettingDelegate, NotificationDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CustomActivityIndicatorView *loadingIndicatorView;

@end
