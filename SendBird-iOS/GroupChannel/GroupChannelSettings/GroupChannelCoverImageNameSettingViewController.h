//
//  GroupChannelCoverImageNameSettingViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 4/2/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <RSKImageCropper/RSKImageCropper.h>
#import "NotificationDelegate.h"

@protocol GroupChannelCoverImageNameSettingDelegate <NSObject>

@optional
- (void)didUpdateGroupChannel;

@end

@interface GroupChannelCoverImageNameSettingViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, NotificationDelegate>

@property (weak, nonatomic) id<GroupChannelCoverImageNameSettingDelegate> delegate;

@property (strong) SBDGroupChannel *channel;

@end
