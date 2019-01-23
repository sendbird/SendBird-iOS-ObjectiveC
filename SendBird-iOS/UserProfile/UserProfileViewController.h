//
//  UserProfileViewController.h
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/2/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "NotificationDelegate.h"

@interface UserProfileViewController : UIViewController<NotificationDelegate>

@property (strong) SBDUser *user;

@end
