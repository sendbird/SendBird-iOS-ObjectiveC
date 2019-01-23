//
//  CreateGroupChannelNavigationController.h
//  SendBird-iOS
//
//  Created by SendBird on 2/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@protocol CreateGroupChannelViewControllerDelegate<NSObject>

@optional
- (void)didCreateGroupChannel:(SBDGroupChannel *)channel;

@end

@interface CreateGroupChannelNavigationController : UINavigationController

@property (weak, nonatomic) id<CreateGroupChannelViewControllerDelegate> channelCreationDelegate;

@end
