//
//  GroupChannelOutgoingImageVideoFileMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 2/20/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import "CustomProgressCircle.h"
#import "GroupChannelMessageTableViewCellDelegate.h"

@interface GroupChannelOutgoingImageVideoFileMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) id <GroupChannelMessageTableViewCellDelegate> delegate;

@property (strong) SBDGroupChannel *channel;
@property (strong) SBDFileMessage *msg;
@property (atomic) NSUInteger imageHash;

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *imageFileMessageImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIView *messageStatusContainerView;

@property (weak, nonatomic) IBOutlet UIView *fileTransferProgressViewContainerView;
@property (weak, nonatomic) IBOutlet CustomProgressCircle *fileTransferProgressCircleView;
@property (weak, nonatomic) IBOutlet UILabel *fileTransferProgressLabel;
@property (weak, nonatomic) IBOutlet UIView *sendingFailureContainerView;
@property (weak, nonatomic) IBOutlet UIView *readStatusContainerView;
@property (weak, nonatomic) IBOutlet UILabel *readStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sendingFlagImageView;

@property (weak, nonatomic) IBOutlet UIView *resendButtonContainerView;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;

@property (weak, nonatomic) IBOutlet UIImageView *videoPlayIconImageView;

@property (weak, nonatomic) IBOutlet UIImageView *imageMessagePlaceholderImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoMessagePlaceholderImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageStatusContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewBottomMargin;

- (void)setCurrentMessage:(SBDFileMessage *)message previousMessage:(SBDBaseMessage *)prevMessage nextMessage:(SBDBaseMessage *)nextMessage;
- (SBDFileMessage *)getMessage;

- (void)hideReadStatus;
- (void)showProgress:(CGFloat)progress;
- (void)hideProgress;
- (void)hideElementsForFailure;
- (void)showElementsForFailure;

- (void)showBottomMargin;
- (void)hideBottomMargin;

- (void)hideAllPlaceholders;

- (void)setAnimatedImage:(FLAnimatedImage *)image hash:(NSUInteger)hash;
- (void)setImage:(UIImage *)image;

@end
