//
//  GroupChannelOutgoingUserMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 2/20/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "GroupChannelMessageTableViewCellDelegate.h"

@interface GroupChannelOutgoingUserMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) id <GroupChannelMessageTableViewCellDelegate> delegate;

@property (strong) SBDGroupChannel *channel;

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *textMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIView *messageStatusContainerView;
@property (weak, nonatomic) IBOutlet UIView *resendButtonContainerView;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIView *sendingFailureContainerView;
@property (weak, nonatomic) IBOutlet UIView *readStatusContainerView;
@property (weak, nonatomic) IBOutlet UILabel *readStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sendingFlagImageView;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageStatusContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewBottomMargin;

- (void)setCurrentMessage:(SBDUserMessage *)message previousMessage:(SBDBaseMessage *)prevMessage nextMessage:(SBDBaseMessage *)nextMessage failed:(BOOL)failed;
- (SBDUserMessage *)getMessage;

@end
