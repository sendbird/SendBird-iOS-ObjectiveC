//
//  OpenChannelUserMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 1/23/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "OpenChannelMessageTableViewCellDelegate.h"

@interface OpenChannelUserMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) id <OpenChannelMessageTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *profileImageContainerView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *resendButtonContainerView;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIView *sendingFailureContainerView;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewBottomMargin
;

- (void)setMessage:(SBDUserMessage *)message;
- (SBDUserMessage *)getMessage;
- (void)hideElementsForFailure;
- (void)showElementsForFailure;

@end

