//
//  CreateOpenChannelOperatorTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 4/6/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface CreateOpenChannelOperatorTableViewCell : UITableViewCell

@property (strong, nonatomic) SBDUser *op;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomBorderView;

@end
