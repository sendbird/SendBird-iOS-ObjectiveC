//
//  OpenChannelMessageTableViewCellDelegate.h
//  SendBird-iOS
//
//  Created by SendBird on 3/8/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#ifndef OpenChannelMessageTableViewCellDelegate_h
#define OpenChannelMessageTableViewCellDelegate_h

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@protocol OpenChannelMessageTableViewCellDelegate<NSObject>

@optional
- (void)didClickUserProfile:(SBDUser *)user;
- (void)didLongClickUserProfile:(SBDUser *)user;

- (void)didClickResendUserMessageButton:(SBDUserMessage *)message;
- (void)didClickResendImageFileMessageButton:(SBDFileMessage *)message;
- (void)didClickResendGeneralFileMessageButton:(SBDFileMessage *)message;

- (void)didClickImageVideoFileMessage:(SBDFileMessage *)message;
- (void)didClickGeneralFileMessage:(SBDFileMessage *)message;

- (void)didLongClickAdminMessage:(SBDAdminMessage *)message;
- (void)didLongClickUserMessage:(SBDUserMessage *)message;
- (void)didLongClickImageVideoFileMessage:(SBDFileMessage *)message;
- (void)didLongClickGeneralFileMessage:(SBDFileMessage *)message;

@end

#endif /* OpenChannelMessageTableViewCellDelegate_h */
