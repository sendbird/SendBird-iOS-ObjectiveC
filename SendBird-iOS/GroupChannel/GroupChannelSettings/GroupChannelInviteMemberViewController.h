//
//  GroupChannelInviteMemberViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 2/28/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "NotificationDelegate.h"

@protocol GroupChannelInviteMemberDelegate<NSObject>

@optional
- (void)didInviteMembers;

@end

@interface GroupChannelInviteMemberViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NotificationDelegate>

@property (weak, nonatomic) id<GroupChannelInviteMemberDelegate> delegate;

@property (strong) NSMutableDictionary<NSString *, SBDUser *> *selectedUsers;
@property (strong) SBDGroupChannel *channel;

@end
