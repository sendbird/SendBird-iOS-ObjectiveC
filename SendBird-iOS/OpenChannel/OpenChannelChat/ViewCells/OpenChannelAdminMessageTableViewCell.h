//
//  OpenChannelAdminMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 1/23/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "OpenChannelMessageTableViewCellDelegate.h"

@interface OpenChannelAdminMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;

@property (weak, nonatomic) id<OpenChannelMessageTableViewCellDelegate> delegate;

- (void)setMessage:(SBDAdminMessage *)message;
- (SBDAdminMessage *)getMessage;
- (void)setPreviousMessage:(SBDBaseMessage *)prevMessage;
@end
