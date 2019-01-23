//
//  Utils.h
//  SendBird-iOS
//
//  Created by SendBird on 2/20/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface Utils : NSObject

+ (NSString *)getMessageDateStringFromTimestamp:(long long)timestamp;
+ (NSString *)getDateStringForDateSeperatorFromTimestamp:(long long)timestamp;
+ (BOOL)checkDayChangeDayBetweenOldTimestamp:(long long)oldTimestamp newTimestamp:(long long)newTimestamp;
+ (NSString *)createGroupChannelName:(SBDGroupChannel *)channel;
+ (NSString *)createGroupChannelNameFromMembers:(SBDGroupChannel *)channel;
+ (void)showAlertControllerWithError:(SBDError *)error viewController:(UIViewController *)viewController;
+ (void)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewController;
+ (NSString *)buildTypingIndicatorLabel:(SBDGroupChannel *)channel;
+ (NSString *)transformUserProfileImage:(SBDUser *)user;
+ (UIImage *)getDefaultUserProfileImage:(SBDUser *)user;

@end
