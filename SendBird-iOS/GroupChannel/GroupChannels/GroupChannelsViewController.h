//
//  GroupChannelsViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 2/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "CreateGroupChannelNavigationController.h"
#import "GroupChannelsUpdateListDelegate.h"
#import "NotificationDelegate.h"

@interface GroupChannelsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, CreateGroupChannelViewControllerDelegate, GroupChannelsUpdateListDelegate, SBDChannelDelegate, SBDConnectionDelegate, NotificationDelegate>

//- (void)openChatWithChannelUrl:(NSString *)channelUrl;

@end
