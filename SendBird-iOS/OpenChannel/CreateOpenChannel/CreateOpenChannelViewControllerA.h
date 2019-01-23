//
//  CreateOpenChannelViewControllerA.h
//  SendBird-iOS
//
//  Created by SendBird on 12/4/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RSKImageCropper/RSKImageCropper.h>
#import "CreateOpenChannelViewControllerB.h"
#import "NotificationDelegate.h"

@interface CreateOpenChannelViewControllerA : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, NotificationDelegate>

@end
