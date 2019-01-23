//
//  SettingsBlockedUserListViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 3/7/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "SettingsBlockedUserListViewController.h"
#import "BlockedUserTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Utils.h"
#import "UserProfileViewController.h"
#import "UIViewController+Utils.h"
#import "SettingsViewController.h"

@interface SettingsBlockedUserListViewController()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong) NSMutableArray<SBDUser *> *users;
@property (strong) SBDUserListQuery *userListQuery;
@property (strong) UIRefreshControl *refreshControl;
@property (atomic) BOOL tabBarHidden;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;

@end

@implementation SettingsBlockedUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Blocked Users";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    ;
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    self.tabBarHidden = self.tabBarController.tabBar.hidden;
    self.tabBarController.tabBar.hidden = YES;
    
    self.users = [[NSMutableArray alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BlockedUserTableViewCell" bundle:nil] forCellReuseIdentifier:@"BlockedUserTableViewCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshUserList) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.refreshControl = self.refreshControl;
    
    self.userListQuery = nil;
    
    [self refreshUserList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = self.tabBarHidden;
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
    if ([cvc isKindOfClass:[SettingsViewController class]]) {
        [((SettingsViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - Load users
- (void)refreshUserList {
    [self loadUserListNextPage:YES];
}

- (void)loadUserListNextPage:(BOOL)refresh {
    if (refresh) {
        self.userListQuery = nil;
    }
    
    if (self.userListQuery == nil) {
        self.userListQuery = [SBDMain createBlockedUserListQuery];
        self.userListQuery.limit = 20;
    }
    
    if (self.userListQuery.hasNext == NO) {
        return;
    }
    
    [self.userListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (refresh) {
                [self.users removeAllObjects];
            }
            
            [self.users addObjectsFromArray:users];
            [self.tableView reloadData];
            
            [self.refreshControl endRefreshing];
        });
    }];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlockedUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BlockedUserTableViewCell"];
    cell.user = self.users[indexPath.row];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BlockedUserTableViewCell *updateCell = (BlockedUserTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (updateCell) {
            updateCell.nicknameLabel.text = self.users[indexPath.row].nickname;
            [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.users[indexPath.row]]] placeholderImage:[Utils getDefaultUserProfileImage:self.users[indexPath.row]]];
        }
    });
    
    if (self.users.count > 0 && indexPath.row == self.users.count - 1) {
        [self loadUserListNextPage:NO];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.users.count == 0) {
        self.emptyLabel.hidden = NO;
    }
    else {
        self.emptyLabel.hidden = YES;
    }
    return self.users.count;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SBDUser *user = self.users[indexPath.row];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:user.nickname message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionSeeProfile = [UIAlertAction actionWithTitle:@"See profile" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UserProfileViewController *vc = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
        vc.user = user;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
    
    UIAlertAction *actionUnblockUser = [UIAlertAction actionWithTitle:@"Unblock" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SBDMain unblockUser:user completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.users removeObject:user];
                [self.tableView reloadData];
            });
        }];
    }];
    UIAlertAction *actionCancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [ac addAction:actionSeeProfile];
    [ac addAction:actionUnblockUser];
    [ac addAction:actionCancelAction];
    
    [self presentViewController:ac animated:YES completion:nil];
}

@end
