//
//  GroupChannelOutgoingAudioFileMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/7/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "CustomProgressCircle.h"
#import "GroupChannelMessageTableViewCellDelegate.h"

@interface GroupChannelOutgoingAudioFileMessageTableViewCell : UITableViewCell

@property (strong) SBDGroupChannel *channel;
@property (weak, nonatomic) id<GroupChannelMessageTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIView *messageStatusContainerView;
@property (weak, nonatomic) IBOutlet UIView *resendButtonContainerView;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;

@property (weak, nonatomic) IBOutlet UIView *fileTransferProgressViewContainerView;
@property (weak, nonatomic) IBOutlet CustomProgressCircle *fileTransferProgressCircleView;
@property (weak, nonatomic) IBOutlet UILabel *fileTransferProgressLabel;
@property (weak, nonatomic) IBOutlet UIView *sendingFailureContainerView;
@property (weak, nonatomic) IBOutlet UIView *readStatusContainerView;
@property (weak, nonatomic) IBOutlet UILabel *readStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sendingFlagImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageStatusContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewBottomMargin;

- (void)setCurrentMessage:(SBDFileMessage *)message previousMessage:(SBDBaseMessage *)prevMessage nextMessage:(SBDBaseMessage *)nextMessage failed:(BOOL)failed;
- (SBDFileMessage *)getMessage;

- (void)showProgress:(CGFloat)progress;
- (void)hideElementsForFailure;
- (void)showElementsForFailure;
- (void)hideReadStatus;
- (void)hideProgress;
- (void)showBottomMargin;
- (void)hideBottomMargin;

@end
