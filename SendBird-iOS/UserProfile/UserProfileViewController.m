//
//  UserProfileViewController.m
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/2/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import "UserProfileViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Utils.h"
#import "UIViewController+Utils.h"
#import "GroupChannelSettingsViewController.h"
#import "GroupChannelChatViewController.h"
#import "OpenChannelBannedUserListViewController.h"
#import "OpenChannelMutedUserListViewController.h"
#import "OpenChannelParticipantListViewController.h"
#import "OpenChannelSettingsViewController.h"
#import "SettingsBlockedUserListViewController.h"

@interface UserProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineStateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *onlineStateImageView;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Profile";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    [self refreshUserInfo:self.user];
    
    SBDApplicationUserListQuery *query = [SBDMain createApplicationUserListQuery];
    [query setUserIdsFilter:@[self.user.userId]];
    [query loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error) {
        if (error != nil) {
            [Utils showAlertControllerWithError:error viewController:self];
            return;
        }
        
        [self refreshUserInfo:users[0]];
    }];
}

- (void)refreshUserInfo:(SBDUser *)user {
    [self.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:user]] placeholderImage:[Utils getDefaultUserProfileImage:user]];
    
    self.nicknameLabel.text = user.nickname;
    
    if (user.connectionStatus == SBDUserConnectionStatusOnline) {
        self.onlineStateImageView.image = [UIImage imageNamed:@"img_online"];
        self.onlineStateLabel.text = @"Online";
        self.lastUpdatedLabel.hidden = YES;
    }
    else {
        self.onlineStateImageView.image = [UIImage imageNamed:@"img_offline"];
        self.onlineStateLabel.text = @"Offline";
        if (user.lastSeenAt > 0) {
            self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated %@", [Utils getDateStringForDateSeperatorFromTimestamp:user.lastSeenAt]];
            self.lastUpdatedLabel.hidden = NO;
        }
        else {
            self.lastUpdatedLabel.hidden = YES;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - NotificationDelegate
- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self.navigationController popViewControllerAnimated:NO];
    UIViewController *cvc = [UIViewController currentViewController];
    if ([cvc isKindOfClass:[GroupChannelSettingsViewController class]]) {
        [((GroupChannelSettingsViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
    else if ([cvc isKindOfClass:[GroupChannelChatViewController class]]) {
        [((GroupChannelChatViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
    else if ([cvc isKindOfClass:[OpenChannelBannedUserListViewController class]]) {
        [((OpenChannelBannedUserListViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
    else if ([cvc isKindOfClass:[OpenChannelMutedUserListViewController class]]) {
        [((OpenChannelMutedUserListViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
    else if ([cvc isKindOfClass:[OpenChannelParticipantListViewController class]]) {
        [((OpenChannelParticipantListViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
    else if ([cvc isKindOfClass:[OpenChannelSettingsViewController class]]) {
        [((OpenChannelSettingsViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
    else if ([cvc isKindOfClass:[SettingsBlockedUserListViewController class]]) {
        [((SettingsBlockedUserListViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

@end
