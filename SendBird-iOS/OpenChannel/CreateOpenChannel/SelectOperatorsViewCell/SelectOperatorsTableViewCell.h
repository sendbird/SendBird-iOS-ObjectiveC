//
//  SelectOperatorsTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 1/9/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface SelectOperatorsTableViewCell : UITableViewCell

@property (strong) SBDUser *user;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (nonatomic, setter=setSelectedOperator:) BOOL selectedOperator;

@end
