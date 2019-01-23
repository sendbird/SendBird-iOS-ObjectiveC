//
//  GroupChannelNeutralAdminMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 2/20/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "GroupChannelMessageTableViewCellDelegate.h"

@interface GroupChannelNeutralAdminMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *textMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;

@property (weak, nonatomic) id<GroupChannelMessageTableViewCellDelegate> delegate;

- (void)setCurrentMessage:(SBDAdminMessage *)message previousMessage:(SBDBaseMessage *)prevMessage;
- (SBDAdminMessage *)getMessage;

@end
