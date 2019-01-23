//
//  OpenChannelTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 12/5/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenChannelTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *channelNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *participantCountLabel;
@property (nonatomic, setter=setAsOperator:) BOOL asOperator;

@end
