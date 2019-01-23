//
//  OpenChannelChatViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 1/23/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <RSKImageCropper/RSKImageCropper.h>
#import "OpenChannelAdminMessageTableViewCell.h"
#import "OpenChannelUserMessageTableViewCell.h"
#import "OpenChannelGeneralFileMessageTableViewCell.h"
#import "OpenChannelImageVideoFileMessageTableViewCell.h"
#import "OpenChannelSettingsViewController.h"
#import "CreateOpenChannelNavigationController.h"
#import "NotificationDelegate.h"

@protocol OpenChanannelChatDelegate<NSObject>

@optional
- (void)didUpdateOpenChannel;

@end

@interface OpenChannelChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, OpenChannelMessageTableViewCellDelegate, SBDChannelDelegate, SBDNetworkDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, OpenChannelSettingsDelegate, UIDocumentPickerDelegate, NotificationDelegate>

@property (weak, nonatomic) id<OpenChanannelChatDelegate> delegate;
@property (nonatomic, weak) id<CreateOpenChannelDelegate> createChannelDelegate;

@property (strong) SBDOpenChannel *channel;
@property (weak, nonatomic) IBOutlet UITextField *inputMessageTextField;

@end
