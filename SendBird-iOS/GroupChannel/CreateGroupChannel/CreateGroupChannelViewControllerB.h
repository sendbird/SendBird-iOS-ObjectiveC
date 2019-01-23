//
//  CreateGroupChannelViewControllerB.h
//  SendBird-iOS
//
//  Created by SendBird on 2/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <RSKImageCropper/RSKImageCropper.h>
#import "NotificationDelegate.h"

@interface CreateGroupChannelViewControllerB : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, NotificationDelegate>

@property (strong) NSArray<SBDUser *> *members;

@end
