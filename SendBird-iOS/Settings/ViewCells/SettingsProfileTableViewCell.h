//
//  SettingsProfileTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 3/1/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsProfileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;

@end
