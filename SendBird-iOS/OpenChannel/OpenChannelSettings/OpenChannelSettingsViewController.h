//
//  OpenChannelSettingsViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 2/7/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <RSKImageCropper/RSKImageCropper.h>

#import "OpenChannelSettingsChannelNameTableViewCell.h"
#import "OpenChannelSettingsSeperatorTableViewCell.h"
#import "OpenChannelSettingsMenuTableViewCell.h"
#import "OpenChannelSettingsMeTableViewCell.h"
#import "OpenChannelSettingsOperatorTableViewCell.h"
#import "CustomActivityIndicatorView.h"
#import "SelectOperatorsViewController.h"
#import "OpenChannelCoverImageNameSettingViewController.h"
#import "OpenChannelOperatorSectionTableViewCell.h"
#import "NotificationDelegate.h"

@protocol OpenChannelSettingsDelegate<NSObject>

@optional
- (void)didUpdateOpenChannel;

@end

@interface OpenChannelSettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, OpenChannelSettingsChannelNameTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, SelectOperatorsDelegate, OpenChannelCoverImageNameSettingDelegate, NotificationDelegate, SBDChannelDelegate>

@property (weak, nonatomic) id<OpenChannelSettingsDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet CustomActivityIndicatorView *loadingIndicatorView;

@property (strong) SBDOpenChannel *channel;

@end
