//
//  OpenChannelBannedUserListViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 2/8/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "NotificationDelegate.h"

@interface OpenChannelBannedUserListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, NotificationDelegate>

@property (strong) SBDOpenChannel *channel;
@property (weak, nonatomic) IBOutlet UITableView *bannedUsersTableView;

@end
