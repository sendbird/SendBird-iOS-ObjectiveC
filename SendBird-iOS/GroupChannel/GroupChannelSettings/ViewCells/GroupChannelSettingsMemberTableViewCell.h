//
//  GroupChannelSettingsMemberTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 2/27/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChannelSettingsMemberTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *myProfileImageCoverView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *blockedUserCoverImageView;
@property (weak, nonatomic) IBOutlet UIView *topBorderView;


@end
