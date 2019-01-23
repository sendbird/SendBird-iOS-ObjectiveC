//
//  NotificationDelegate.h
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/29/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NotificationDelegate<NSObject>

- (void)openChatWithChannelUrl:(NSString *)channelUrl;

@end
