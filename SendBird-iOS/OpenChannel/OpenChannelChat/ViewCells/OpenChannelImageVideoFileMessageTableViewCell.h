//
//  OpenChannelImageVideoFileMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 1/23/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import "CustomProgressCircle.h"
#import "OpenChannelMessageTableViewCellDelegate.h"

@interface OpenChannelImageVideoFileMessageTableViewCell : UITableViewCell

@property (atomic) NSUInteger imageHash;

@property (weak, nonatomic) id <OpenChannelMessageTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *profileContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (weak, nonatomic) IBOutlet UIView *resendButtonContainerView;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;

@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageMessagePlaceholderImageView;

@property (weak, nonatomic) IBOutlet UIView *fileTransferProgressViewContainerView;
@property (weak, nonatomic) IBOutlet CustomProgressCircle *fileTransferProgressCircleView;
@property (weak, nonatomic) IBOutlet UILabel *fileTransferProgressLabel;
@property (weak, nonatomic) IBOutlet UIView *sendingFailureContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileImageViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *videoPlayIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoMessagePlaceholderImageView;

@property (strong) SBDOpenChannel *channel;

- (void)setMessage:(SBDFileMessage *)message;
- (SBDFileMessage *)getMessage;

- (void)hideProgress;
- (void)showProgress:(CGFloat)progress;
- (void)hideElementsForFailure;
- (void)showElementsForFailure;
- (void)showBottomMargin;
- (void)hideBottomMargin;

- (void)hideAllPlaceholders;

- (void)setAnimatedImage:(FLAnimatedImage *)image hash:(NSUInteger)hash;
- (void)setImage:(UIImage *)image;

@end
