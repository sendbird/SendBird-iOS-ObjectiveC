//
//  GroupChannelSettingsTableViewCellDelegate.h
//  SendBird-iOS
//
//  Created by SendBird on 3/4/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SendBirdSDK/SendBirdSDK.h>

@protocol GroupChannelSettingsTableViewCellDelegate<NSObject>

@optional
- (void)willUpdateChannelNameAndCoverImage;
- (void)didChangeNotificationSwitchButton:(BOOL)isOn;

@end
