//
//  AppDelegate.h
//  SendBird-iOS
//
//  Created by SendBird on 11/9/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, SBDAuthenticateDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, nullable) NSString *receivedPushChannelUrl;
@property (strong) NSString *pushReceivedGroupChannel;

@end

