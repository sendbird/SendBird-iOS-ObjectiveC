//
//  GroupChannelSettingsViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 2/27/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "CustomActivityIndicatorView.h"
#import "GroupChannelInviteMemberViewController.h"
#import "GroupChannelSettingsTableViewCellDelegate.h"
#import "GroupChannelCoverImageNameSettingViewController.h"
#import "NotificationDelegate.h"

@protocol GroupChannelSettingsDelegate <NSObject>

@optional
- (void)didLeaveChannel;

@end

@interface GroupChannelSettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, GroupChannelInviteMemberDelegate, GroupChannelSettingsTableViewCellDelegate, GroupChannelCoverImageNameSettingDelegate, NotificationDelegate, SBDChannelDelegate>

@property (weak, nonatomic) id<GroupChannelSettingsDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet CustomActivityIndicatorView *loadingIndicatorView;

@property (strong) SBDGroupChannel *channel;

@end
