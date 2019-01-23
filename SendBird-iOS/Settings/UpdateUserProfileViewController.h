//
//  UpdateUserProfileViewController.h
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/3/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RSKImageCropper/RSKImageCropper.h>
#import "NotificationDelegate.h"

@protocol UserProfileImageNameSettingDelegate <NSObject>

@optional
- (void)didUpdateUserProfile;

@end


@interface UpdateUserProfileViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, NotificationDelegate>

@property (weak, nonatomic) id<UserProfileImageNameSettingDelegate> delegate;

@end
