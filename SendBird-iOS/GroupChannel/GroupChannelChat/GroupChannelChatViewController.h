//
//  GroupChannelChatViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 2/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <RSKImageCropper/RSKImageCropper.h>
#import "GroupChannelSettingsViewController.h"
#import "GroupChannelMessageTableViewCellDelegate.h"
#import "GroupChannelsUpdateListDelegate.h"
#import "NotificationDelegate.h"

@interface GroupChannelChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, SBDChannelDelegate, GroupChannelMessageTableViewCellDelegate, GroupChannelSettingsDelegate, UIDocumentPickerDelegate, NotificationDelegate, SBDNetworkDelegate, SBDConnectionDelegate>

@property (weak, nonatomic) id<GroupChannelsUpdateListDelegate> delegate;

@property (strong) SBDGroupChannel *channel;
@property (weak, nonatomic) IBOutlet UITextField *inputMessageTextField;

//- (void)openChatWithChannelUrl:(NSString *)channelUrl;

@end
