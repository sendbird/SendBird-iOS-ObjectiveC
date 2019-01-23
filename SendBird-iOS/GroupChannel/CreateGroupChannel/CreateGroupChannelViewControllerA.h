//
//  CreateGroupChannelViewControllerA.h
//  SendBird-iOS
//
//  Created by SendBird on 2/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "CreateGroupChannelViewControllerB.h"
#import "NotificationDelegate.h"

@interface CreateGroupChannelViewControllerA : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NotificationDelegate>

@property (strong) NSMutableDictionary<NSString *, SBDUser *> *selectedUsers;

@end
