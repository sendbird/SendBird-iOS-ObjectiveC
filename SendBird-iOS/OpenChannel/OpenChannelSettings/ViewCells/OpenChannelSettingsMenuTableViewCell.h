//
//  OpenChannelSettingsMenuTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 2/7/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenChannelSettingsMenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *settingMenuIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *settingMenuLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIView *dividerView;

@end
