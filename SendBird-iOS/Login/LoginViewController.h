//
//  ViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 11/9/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "NotificationDelegate.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate, SBDAuthenticateDelegate, NotificationDelegate>

@end

