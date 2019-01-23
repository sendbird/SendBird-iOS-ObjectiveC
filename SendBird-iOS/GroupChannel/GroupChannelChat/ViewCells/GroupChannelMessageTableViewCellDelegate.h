//
//  GroupChannelMessageTableViewCellDelegate.h
//  SendBird-iOS
//
//  Created by SendBird on 2/27/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#ifndef GroupChannelMessageTableViewCellDelegate_h
#define GroupChannelMessageTableViewCellDelegate_h

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@protocol GroupChannelMessageTableViewCellDelegate <NSObject>

@optional
- (void)didClickResendUserMessage:(SBDUserMessage *)message;
- (void)didClickResendImageVideoFileMessage:(SBDFileMessage *)message;
- (void)didClickResendAudioGeneralFileMessage:(SBDFileMessage *)message;
- (void)didLongClickAdminMessage:(SBDAdminMessage *)message;
- (void)didLongClickUserMessage:(SBDUserMessage *)message;
- (void)didLongClickUserProfile:(SBDUser *)user;
- (void)didClickImageVideoFileMessage:(SBDFileMessage *)message;
- (void)didLongClickImageVideoFileMessage:(SBDFileMessage *)message;
- (void)didLongClickGeneralFileMessage:(SBDFileMessage *)message;
- (void)didClickAudioFileMessage:(SBDFileMessage *)message;
- (void)didClickVideoFileMessage:(SBDFileMessage *)message;
- (void)didClickUserProfile:(SBDUser *)user;

@end

#endif /* GroupChannelMessageTableViewCellDelegate_h */
