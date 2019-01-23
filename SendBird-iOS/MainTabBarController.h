//
//  MainTabBarController.h
//  SendBird-iOS
//
//  Created by SendBird on 11/16/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface MainTabBarController : UITabBarController<SBDConnectionDelegate, SBDChannelDelegate, SBDNetworkDelegate>

@end
