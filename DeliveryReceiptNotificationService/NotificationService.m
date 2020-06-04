//
//  NotificationService.m
//  DeliveryReceiptNotificationService
//
//  Created by Jed Gyeong on 6/4/20.
//  Copyright © 2020 Jed Gyeong. All rights reserved.
//

#import <SendBirdSDK/SendBirdSDK.h>
#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    [SBDMain setAppGroup:@"group.com.sendbird.sample4"];
    // Delivery receipt is a premium feature.
    [SBDMain markAsDeliveredWithRemoteNotificationPayload:self.bestAttemptContent.userInfo completionHandler:^(SBDError * _Nullable error) {
        
    }];
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
