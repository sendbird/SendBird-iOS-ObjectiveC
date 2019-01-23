//
//  OpenChannelMutedUserListViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 2/8/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "OpenChannelMutedUserListViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Utils.h"
#import "OpenChannelSettingsUserTableViewCell.h"
#import "UserProfileViewController.h"
#import "UIViewController+Utils.h"
#import "OpenChannelSettingsViewController.h"

@interface OpenChannelMutedUserListViewController ()

@property (strong) SBDUserListQuery *mutedListQuery;
@property (strong) NSMutableArray<SBDUser *> *mutedUsers;
@property (strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;

@end

@implementation OpenChannelMutedUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Muted Users";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    self.mutedUsers = [[NSMutableArray alloc] init];
    self.mutedListQuery = nil;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshMutedUserList) forControlEvents:UIControlEventValueChanged];
    
    [self.mutedUsersTableView registerNib:[UINib nibWithNibName:@"OpenChannelSettingsUserTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelSettingsUserTableViewCell"];
    self.mutedUsersTableView.refreshControl = self.refreshControl;
    
    self.mutedUsersTableView.delegate = self;
    self.mutedUsersTableView.dataSource = self;
    
    [self loadMutedUserListNextPage:YES];
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


- (void)refreshMutedUserList {
    [self loadMutedUserListNextPage:YES];
}

- (void)loadMutedUserListNextPage:(BOOL)refresh {
    if (refresh) {
        self.mutedListQuery = nil;
    }
    
    if (self.mutedListQuery == nil) {
        self.mutedListQuery = [self.channel createMutedUserListQuery];
        self.mutedListQuery.limit = 20;
    }
    
    if (self.mutedListQuery.hasNext == NO) {
        return;
    }
    
    [self.mutedListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (refresh) {
                [self.mutedUsers removeAllObjects];
            }
            
            [self.mutedUsers addObjectsFromArray:users];
            [self.mutedUsersTableView reloadData];
            
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
    
    SBDUser *mutedUser = self.mutedUsers[indexPath.row];
    
    cell.nicknameLabel.text = mutedUser.nickname;
    cell.user = mutedUser;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        OpenChannelSettingsUserTableViewCell *updateCell = (OpenChannelSettingsUserTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (updateCell) {
            [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.mutedUsers[indexPath.row]]] placeholderImage:[Utils getDefaultUserProfileImage:self.mutedUsers[indexPath.row]]];
        }
    });
    
    if (self.mutedUsers.count > 0 && indexPath.row == self.mutedUsers.count - 1) {
        [self loadMutedUserListNextPage:NO];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.mutedUsers.count == 0) {
        self.emptyLabel.hidden = NO;
    }
    else {
        self.emptyLabel.hidden = YES;
    }
    return self.mutedUsers.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    SBDUser *mutedUser = self.mutedUsers[indexPath.row];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionSeeProfile = [UIAlertAction actionWithTitle:@"See profile" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UserProfileViewController *vc = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
        vc.user = mutedUser;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
    
    UIAlertAction *actionUnmuteUser = [UIAlertAction actionWithTitle:@"Unmute user" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.channel unmuteUser:mutedUser completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mutedUsers removeObject:mutedUser];
                [self.mutedUsersTableView reloadData];
            });
        }];
    }];
    UIAlertAction *actionCancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [ac addAction:actionSeeProfile];
    [ac addAction:actionUnmuteUser];
    [ac addAction:actionCancelAction];
    
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

@end
