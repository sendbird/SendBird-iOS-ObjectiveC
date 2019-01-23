//
//  OpenChannelSettingsChannelNameTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 2/7/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenChannelSettingsChannelNameTableViewCell;

@protocol OpenChannelSettingsChannelNameTableViewCellDelegate <NSObject>

@optional
- (void)didClickChannelCoverImageNameEdit;

@end

@interface OpenChannelSettingsChannelNameTableViewCell : UITableViewCell

@property (weak, nonatomic) id <OpenChannelSettingsChannelNameTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *channelCoverImageView;
@property (weak, nonatomic) IBOutlet UITextField *channelNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *enableEditButton;

- (void)setEnableEditing:(BOOL)enable;

@end
