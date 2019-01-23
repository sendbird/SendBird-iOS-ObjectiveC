//
//  OpenChannelSettingsOperatorTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 2/8/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface OpenChannelSettingsOperatorTableViewCell : UITableViewCell

@property (strong) SBDUser *user;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIView *dividerView;
@property (weak, nonatomic) IBOutlet UIView *bottomBorderView;

@end
