//
//  OpenChannelBannedUserListViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 2/8/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "OpenChannelBannedUserListViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Utils.h"
#import "OpenChannelSettingsUserTableViewCell.h"
#import "UserProfileViewController.h"
#import "UIViewController+Utils.h"
#import "OpenChannelSettingsViewController.h"

@interface OpenChannelBannedUserListViewController ()

@property (strong) SBDUserListQuery *bannedListQuery;
@property (strong) NSMutableArray<SBDUser *> *bannedUsers;
@property (strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;

@end

@implementation OpenChannelBannedUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Banned Users";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    self.bannedUsers = [[NSMutableArray alloc] init];
    self.bannedListQuery = nil;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshBannedUserList) forControlEvents:UIControlEventValueChanged];
    
    [self.bannedUsersTableView registerNib:[UINib nibWithNibName:@"OpenChannelSettingsUserTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelSettingsUserTableViewCell"];
    self.bannedUsersTableView.refreshControl = self.refreshControl;
    
    self.bannedUsersTableView.delegate = self;
    self.bannedUsersTableView.dataSource = self;
    
    [self loadBannedUserListNextPage:YES];
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

- (void)refreshBannedUserList {
    [self loadBannedUserListNextPage:YES];
}

- (void)loadBannedUserListNextPage:(BOOL)refresh {
    if (refresh) {
        self.bannedListQuery = nil;
    }
    
    if (self.bannedListQuery == nil) {
        self.bannedListQuery = [self.channel createBannedUserListQuery];
        self.bannedListQuery.limit = 20;
    }
    
    if (self.bannedListQuery.hasNext == NO) {
        return;
    }
    
    [self.bannedListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (refresh) {
                [self.bannedUsers removeAllObjects];
            }
            
            [self.bannedUsers addObjectsFromArray:users];
            [self.bannedUsersTableView reloadData];
            
            [self.refreshControl endRefreshing];
        });
    }];
}

#pragma mark - NotificationDelegate
- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self.navigationController popViewControllerAnimated:NO];
    UIViewController *cvc = [UIViewController currentViewController];
    if ([cvc isKindOfClass:[OpenChannelSettingsViewController class]]) {
        [((OpenChannelSettingsViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OpenChannelSettingsUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelSettingsUserTableViewCell"];
    [cell.profileImageView setImage:nil];

    SBDUser *bannedUser = self.bannedUsers[indexPath.row];
    
    cell.nicknameLabel.text = bannedUser.nickname;
    cell.user = bannedUser;

    dispatch_async(dispatch_get_main_queue(), ^{
        OpenChannelSettingsUserTableViewCell *updateCell = (OpenChannelSettingsUserTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (updateCell) {
            [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:self.bannedUsers[indexPath.row].profileUrl] placeholderImage:[UIImage imageNamed:@"img_default_profile_image_1"]];
            [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.bannedUsers[indexPath.row]]] placeholderImage:[Utils getDefaultUserProfileImage:self.bannedUsers[indexPath.row]]];
        }
    });
    
    if (self.bannedUsers.count > 0 && indexPath.row == self.bannedUsers.count - 1) {
        [self loadBannedUserListNextPage:NO];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.bannedUsers.count == 0) {
        self.emptyLabel.hidden = NO;
    }
    else {
        self.emptyLabel.hidden = YES;
    }
    return self.bannedUsers.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    SBDUser *bannedUser = self.bannedUsers[indexPath.row];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionSeeProfile = [UIAlertAction actionWithTitle:@"See profile" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UserProfileViewController *vc = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
        vc.user = bannedUser;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
    
    UIAlertAction *actionUnbanUser = [UIAlertAction actionWithTitle:@"Unban user" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.channel unbanUser:bannedUser completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.bannedUsers removeObject:bannedUser];
                [self.bannedUsersTableView reloadData];
            });
        }];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [ac addAction:actionSeeProfile];
    [ac addAction:actionUnbanUser];
    [ac addAction:actionCancel];
    
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

@end
