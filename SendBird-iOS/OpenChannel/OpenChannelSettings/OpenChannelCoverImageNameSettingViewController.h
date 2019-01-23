//
//  OpenChannelCoverImageNameSettingViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 4/8/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <RSKImageCropper/RSKImageCropper.h>
#import "NotificationDelegate.h"

@protocol OpenChannelCoverImageNameSettingDelegate <NSObject>

@optional
- (void)didUpdateOpenChannel;

@end

@interface OpenChannelCoverImageNameSettingViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, NotificationDelegate>

@property (weak, nonatomic) id<OpenChannelCoverImageNameSettingDelegate> delegate;

@property (strong) SBDOpenChannel *channel;

@end

