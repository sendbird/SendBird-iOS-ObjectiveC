//
//  GroupChannelSettingsChannelCoverNameTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 2/27/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupChannelSettingsTableViewCellDelegate.h"

@interface GroupChannelSettingsChannelCoverNameTableViewCell : UITableViewCell

@property (weak, nonatomic) id<GroupChannelSettingsTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *coverImageContainerView;
@property (weak, nonatomic) IBOutlet UITextField *channelNameTextField;

@property (weak, nonatomic) IBOutlet UIView *singleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *singleCoverImageView;

@property (weak, nonatomic) IBOutlet UIView *doubleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *doubleCoverImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *doubleCoverImageView2;

@property (weak, nonatomic) IBOutlet UIView *tripleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *tripleCoverImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *tripleCoverImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *tripleCoverImageView3;

@property (weak, nonatomic) IBOutlet UIView *quadrupleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *quadrupleCoverImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *quadrupleCoverImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *quadrupleCoverImageView3;
@property (weak, nonatomic) IBOutlet UIImageView *quadrupleCoverImageView4;

@end
