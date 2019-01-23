//
//  BlockedUserTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 3/7/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface BlockedUserTableViewCell : UITableViewCell

@property (strong) SBDUser *user;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@end
