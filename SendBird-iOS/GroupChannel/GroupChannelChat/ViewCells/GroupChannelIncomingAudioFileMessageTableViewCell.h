//
//  GroupChannelIncomingAudioFileMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/8/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import "GroupChannelMessageTableViewCellDelegate.h"

@interface GroupChannelIncomingAudioFileMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UIView *profileContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIView *messageStatusContainerView;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorConatinerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageStatusContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewBottomMargin;

@property (weak, nonatomic) id<GroupChannelMessageTableViewCellDelegate> delegate;

- (void)setCurrentMessage:(SBDFileMessage *)message previousMessage:(SBDBaseMessage *)prevMessage nextMessage:(SBDBaseMessage *)nextMessage;
- (SBDFileMessage *)getMessage;

@end
