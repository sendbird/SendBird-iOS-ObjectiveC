//
//  GroupChannelSettingsViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 2/27/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelSettingsViewController.h"
#import <Photos/Photos.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "GroupChannelSettingsChannelCoverNameTableViewCell.h"
#import "GroupChannelSettingsBlankTableViewCell.h"
#import "GroupChannelSettingsNotificationsTableViewCell.h"
#import "GroupChannelSettingsInviteMemberTableViewCell.h"
#import "GroupChannelSettingsMemberTableViewCell.h"
#import "GroupChannelSettingsLeaveChatTableViewCell.h"
#import "GroupChannelSettingsSectionTableViewCell.h"

#import "GroupChannelCoverImageNameSettingViewController.h"
#import "UserProfileViewController.h"
#import "GroupChannelChatViewController.h"

#import "Utils.h"
#import "UIViewController+Utils.h"

#define REGULAR_MEMBER_MENU_COUNT 7

@interface GroupChannelSettingsViewController ()

@property (strong) NSMutableArray<SBDMember *> *members;
@property (strong) NSMutableDictionary<NSString *, SBDUser *> *selectedUsers;

@end

@implementation GroupChannelSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Group Channel Settings";
    
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    
    [SBDMain addChannelDelegate:self identifier:self.description];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"GroupChannelSettingsChannelCoverNameTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelSettingsChannelCoverNameTableViewCell"];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"GroupChannelSettingsBlankTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelSettingsBlankTableViewCell"];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"GroupChannelSettingsNotificationsTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelSettingsNotificationsTableViewCell"];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"GroupChannelSettingsInviteMemberTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelSettingsInviteMemberTableViewCell"];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"GroupChannelSettingsMemberTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelSettingsMemberTableViewCell"];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"GroupChannelSettingsLeaveChatTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelSettingsLeaveChatTableViewCell"];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"GroupChannelSettingsSectionTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelSettingsSectionTableViewCell"];
    
    self.loadingIndicatorView.hidden = YES;
    [self.view bringSubviewToFront:self.loadingIndicatorView];
    
    [self rearrangeMembers];
    
    [self.settingsTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rearrangeMembers {
    self.members = [[NSMutableArray alloc] init];
    
    for (SBDMember *op in self.channel.members) {
        if ([op.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            [self.members insertObject:op atIndex:0];
        }
        else {
            [self.members addObject:op];
        }
    }
}

- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self.navigationController popViewControllerAnimated:NO];
    UIViewController *cvc = [UIViewController currentViewController];
    if ([cvc isKindOfClass:[GroupChannelChatViewController class]]) {
        [((GroupChannelChatViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.members.count + REGULAR_MEMBER_MENU_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        GroupChannelSettingsChannelCoverNameTableViewCell *channelCoverNameCell = [tableView dequeueReusableCellWithIdentifier:@"GroupChannelSettingsChannelCoverNameTableViewCell" forIndexPath:indexPath];
        channelCoverNameCell.channelNameTextField.placeholder = [Utils createGroupChannelNameFromMembers:self.channel];
        channelCoverNameCell.channelNameTextField.text = self.channel.name;
        channelCoverNameCell.delegate = self;
        
        channelCoverNameCell.singleCoverImageContainerView.hidden = YES;
        channelCoverNameCell.doubleCoverImageContainerView.hidden = YES;
        channelCoverNameCell.tripleCoverImageContainerView.hidden = YES;
        channelCoverNameCell.quadrupleCoverImageContainerView.hidden = YES;
        NSMutableArray<SBDMember *> *currentMembers = [[NSMutableArray alloc] init];
        int count = 0;
        for (SBDMember *member in self.channel.members) {
            if ([member.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                continue;
            }
            [currentMembers addObject:member];
            count += 1;
            if (count == 4) {
                break;
            }
        }
        
        if (self.channel.coverUrl.length > 0 && ![self.channel.coverUrl hasPrefix:@"https://sendbird.com/main/img/cover/"]) {
            channelCoverNameCell.singleCoverImageContainerView.hidden = NO;
            [channelCoverNameCell.singleCoverImageView setImageWithURL:[NSURL URLWithString:self.channel.coverUrl] placeholderImage:[UIImage imageNamed:@"img_default_profile_image_1"]];
        }
        else {
            if (currentMembers != nil) {
                if (currentMembers.count == 0) {
                    channelCoverNameCell.singleCoverImageContainerView.hidden = NO;
                    [channelCoverNameCell.singleCoverImageView setImage:[UIImage imageNamed:@"img_default_profile_image_1"]];
                }
                else if (currentMembers.count == 1) {
                    channelCoverNameCell.singleCoverImageContainerView.hidden = NO;
                    [channelCoverNameCell.singleCoverImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[0]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[0]]];
                }
                else if (currentMembers.count == 2) {
                    channelCoverNameCell.doubleCoverImageContainerView.hidden = NO;
                    [channelCoverNameCell.doubleCoverImageView1 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[0]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[0]]];
                    [channelCoverNameCell.doubleCoverImageView2 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[1]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[0]]];
                }
                else if (currentMembers.count == 3) {
                    channelCoverNameCell.tripleCoverImageContainerView.hidden = NO;
                    [channelCoverNameCell.tripleCoverImageView1 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[0]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[0]]];
                    [channelCoverNameCell.tripleCoverImageView2 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[1]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[1]]];
                    [channelCoverNameCell.tripleCoverImageView3 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[2]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[2]]];
                }
                else if (currentMembers.count >= 4) {
                    channelCoverNameCell.quadrupleCoverImageContainerView.hidden = NO;
                    [channelCoverNameCell.quadrupleCoverImageView1 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[0]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[0]]];
                    [channelCoverNameCell.quadrupleCoverImageView2 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[1]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[1]]];
                    [channelCoverNameCell.quadrupleCoverImageView3 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[2]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[2]]];
                    [channelCoverNameCell.quadrupleCoverImageView4 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[3]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[3]]];
                }
            }
        }

        cell = (UITableViewCell *)channelCoverNameCell;
    }
    else if (indexPath.row == 1) {
        GroupChannelSettingsBlankTableViewCell *blankCell = [tableView dequeueReusableCellWithIdentifier:@"GroupChannelSettingsBlankTableViewCell" forIndexPath:indexPath];
        cell = (UITableViewCell *)blankCell;
    }
    else if (indexPath.row == 2) {
        GroupChannelSettingsNotificationsTableViewCell *notiCell = [tableView dequeueReusableCellWithIdentifier:@"GroupChannelSettingsNotificationsTableViewCell" forIndexPath:indexPath];
        [notiCell.notificationSwitch setOn:self.channel.isPushEnabled];
        notiCell.delegate = self;
        cell = (UITableViewCell *)notiCell;
    }
    else if (indexPath.row == 3) {
        GroupChannelSettingsSectionTableViewCell *memberSectionCell = [tableView dequeueReusableCellWithIdentifier:@"GroupChannelSettingsSectionTableViewCell" forIndexPath:indexPath];
        cell = (UITableViewCell *)memberSectionCell;
    }
    else if (indexPath.row == 4) {
        GroupChannelSettingsInviteMemberTableViewCell *inviteCell = [tableView dequeueReusableCellWithIdentifier:@"GroupChannelSettingsInviteMemberTableViewCell" forIndexPath:indexPath];
        cell = (UITableViewCell *)inviteCell;
    }
    else if (indexPath.row >= 5) {
        if (self.members.count > 0) {
            if (indexPath.row > 4 && indexPath.row < self.members.count + 5) {
                GroupChannelSettingsMemberTableViewCell *memberCell = [tableView dequeueReusableCellWithIdentifier:@"GroupChannelSettingsMemberTableViewCell" forIndexPath:indexPath];
                
                SBDMember *member = self.members[indexPath.row - 5];
                memberCell.nicknameLabel.text = member.nickname;
                if ([member isBlockedByMe]) {
                    memberCell.blockedUserCoverImageView.hidden = NO;
                    memberCell.statusLabel.hidden = NO;
                    memberCell.statusLabel.text = @"Blocked";
                }
                else {
                    memberCell.blockedUserCoverImageView.hidden = YES;
                    memberCell.statusLabel.hidden = YES;
                    memberCell.statusLabel.text = @"";
                }
                
                if ([member.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                    memberCell.accessoryType = UITableViewCellAccessoryNone;
                }
                else {
                    memberCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    GroupChannelSettingsMemberTableViewCell *updateCell = (GroupChannelSettingsMemberTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];

                    if (updateCell) {
                        [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:member]] placeholderImage:[Utils getDefaultUserProfileImage:member]];
                        
                        if ([member.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                            updateCell.myProfileImageCoverView.hidden = NO;
                            updateCell.topBorderView.hidden = NO;
                        }
                        else {
                            updateCell.myProfileImageCoverView.hidden = YES;
                            updateCell.topBorderView.hidden = YES;
                        }
                    }
                });

                cell = (UITableViewCell *)memberCell;
            }
            else if (indexPath.row == self.members.count + 5) {
                GroupChannelSettingsBlankTableViewCell *blankCell = [tableView dequeueReusableCellWithIdentifier:@"GroupChannelSettingsBlankTableViewCell" forIndexPath:indexPath];
                cell = (UITableViewCell *)blankCell;
            }
            else if (indexPath.row == self.members.count + 6) {
                GroupChannelSettingsLeaveChatTableViewCell *leaveChannelCell = [tableView dequeueReusableCellWithIdentifier:@"GroupChannelSettingsLeaveChatTableViewCell" forIndexPath:indexPath];
                cell = (UITableViewCell *)leaveChannelCell;
            }
        }
        else {
            if (indexPath.row == 5) {
                GroupChannelSettingsBlankTableViewCell *blankCell = [tableView dequeueReusableCellWithIdentifier:@"GroupChannelSettingsBlankTableViewCell" forIndexPath:indexPath];
                cell = (UITableViewCell *)blankCell;
            }
            else if (indexPath.row == 6) {
                GroupChannelSettingsLeaveChatTableViewCell *leaveChannelCell = [tableView dequeueReusableCellWithIdentifier:@"GroupChannelSettingsLeaveChatTableViewCell" forIndexPath:indexPath];
                cell = (UITableViewCell *)leaveChannelCell;
            }
        }
    }

    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 121;
    }
    else if (indexPath.row == 1) {
        return 34;
    }
    else if (indexPath.row == 2) {
        return 44;
    }
    else if (indexPath.row == 3) {
        return 56;
    }
    else if (indexPath.row == 4) {
        return 44;
    }
    else if (indexPath.row >= 5) {
        if (self.members.count > 0) {
            if (indexPath.row > 4 && indexPath.row < self.members.count + 5) {
                return 48;
            }
            else if (indexPath.row == self.members.count + 5) {
                return 34;
            }
            else if (indexPath.row == self.members.count + 6) {
                return 44;
            }
        }
        else {
            if (indexPath.row == 5) {
                return 34;
            }
            else if (indexPath.row == 6) {
                return 44;
            }
        }
    }
    
    return 0;
}

#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self clickSettingsMenuTableView];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 4) {
        // Invite member
        GroupChannelInviteMemberViewController *vc = [[GroupChannelInviteMemberViewController alloc] initWithNibName:@"GroupChannelInviteMemberViewController" bundle:nil];
        vc.channel = self.channel;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row >= 5) {
        if (self.members.count > 0) {
            // User Profile
            if (indexPath.row >= 6 && indexPath.row < self.members.count + 5) {
                UserProfileViewController *vc = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
                vc.user = self.members[indexPath.row - 5];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if (indexPath.row == self.members.count + 6) {
                // Leave channel
                [self.channel leaveChannelWithCompletionHandler:^(SBDError * _Nullable error) {
                    if (error != nil) {
                        return;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:NO];
                        if (self.delegate != nil && [self.delegate respondsToSelector:@selector
                                                     (didLeaveChannel)]) {
                            [self.delegate didLeaveChannel];
                        }
                    });
                }];
                
            }
        }
        else {
            if (indexPath.row == 6) {
                [self.channel leaveChannelWithCompletionHandler:^(SBDError * _Nullable error) {
                    if (error != nil) {
                        return;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:NO];
                        if (self.delegate != nil && [self.delegate respondsToSelector:@selector
                                                     (didLeaveChannel)]) {
                            [self.delegate didLeaveChannel];
                        }
                    });
                }];
            }
        }
    }
}

#pragma mark - GroupChannelInviteMemberDelegate
- (void)didInviteMembers {
    [self rearrangeMembers];
    [self.settingsTableView reloadData];
}

#pragma mark - GroupChannelSettingsTableViewCellDelegate
- (void)willUpdateChannelNameAndCoverImage {
    GroupChannelCoverImageNameSettingViewController *vc = [[GroupChannelCoverImageNameSettingViewController alloc] initWithNibName:@"GroupChannelCoverImageNameSettingViewController" bundle:nil];

    vc.channel = self.channel;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didChangeNotificationSwitchButton:(BOOL)isOn {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingIndicatorView.hidden = NO;
        [self.loadingIndicatorView startAnimating];
    });
    
    __weak GroupChannelSettingsViewController *weakSelf = self;
    [self.channel setPushPreferenceWithPushOn:isOn completionHandler:^(SBDError * _Nullable error) {
        GroupChannelSettingsViewController *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.loadingIndicatorView.hidden = YES;
            [strongSelf.loadingIndicatorView stopAnimating];
            
            [strongSelf.settingsTableView reloadData];
        });
    }];
}

#pragma mark - GroupChannelCoverImageNameSettingDelegate
- (void)didUpdateGroupChannel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.settingsTableView reloadData];
    });
}

#pragma mark - SBDChannelDelegate
- (void)channelWasChanged:(SBDBaseChannel *)sender {
    if ([sender.channelUrl isEqualToString:self.channel.channelUrl]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rearrangeMembers];
            [self.settingsTableView reloadData];
        });
    }
}

- (void)channel:(SBDGroupChannel *)sender userDidJoin:(SBDUser *)user {
    if ([sender.channelUrl isEqualToString:self.channel.channelUrl]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rearrangeMembers];
            [self.settingsTableView reloadData];
        });
    }
}

- (void)channel:(SBDGroupChannel *)sender userDidLeave:(SBDUser *)user {
    if ([sender.channelUrl isEqualToString:self.channel.channelUrl]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rearrangeMembers];
            [self.settingsTableView reloadData];
        });
    }
}
@end
