//
//  OpenChannelsViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 12/5/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateOpenChannelNavigationController.h"
#import "OpenChannelChatViewController.h"
#import "NotificationDelegate.h"

@interface OpenChannelsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CreateOpenChannelDelegate, OpenChanannelChatDelegate, NotificationDelegate>

- (void)refreshChannelList;
- (void)clearSearchFilter;

@end
