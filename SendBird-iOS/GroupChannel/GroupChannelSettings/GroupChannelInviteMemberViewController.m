//
//  GroupChannelInviteMemberViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 2/28/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelInviteMemberViewController.h"
#import "GroupChannelInviteMemberTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "CustomActivityIndicatorView.h"
#import "Utils.h"
#import "UIViewController+Utils.h"
#import "GroupChannelSettingsViewController.h"

@interface GroupChannelInviteMemberViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong) NSMutableArray<SBDUser *> *users;
@property (strong) SBDApplicationUserListQuery *userListQuery;
@property (strong) UIRefreshControl *refreshControl;
@property (strong) UISearchController *searchController;

@property (strong, nonatomic) UIBarButtonItem *okButtonItem;

@property (weak, nonatomic) IBOutlet CustomActivityIndicatorView *updatingIndicatorView;

@end

@implementation GroupChannelInviteMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Invite Members";
    
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    self.okButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK(0)" style:UIBarButtonItemStylePlain target:self action:@selector(clickOkButton:)];
    self.navigationItem.rightBarButtonItem = self.okButtonItem;
    
    [self.view bringSubviewToFront:self.updatingIndicatorView];
    self.updatingIndicatorView.hidden = YES;
    
    self.users = [[NSMutableArray alloc] init];
    self.selectedUsers = [[NSMutableDictionary alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupChannelInviteMemberTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelInviteMemberTableViewCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshUserList) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.refreshControl = self.refreshControl;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"User ID";
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.searchController.searchBar.tintColor = [UIColor colorNamed:@"color_bar_item"];
    
    self.userListQuery = nil;
    
    if (self.selectedUsers.count == 0) {
        self.okButtonItem.enabled = NO;
    }
    else {
        self.okButtonItem.enabled = YES;
    }
    
    self.okButtonItem.title = [NSString stringWithFormat:@"OK(%d)", (int)self.selectedUsers.count];
    
    [self refreshUserList];
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
        self.userListQuery = [SBDMain createApplicationUserListQuery];
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
            
            for (SBDUser *user in users) {
                if ([user.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                    continue;
                }
                [self.users addObject:user];
            }
            
            [self.tableView reloadData];
            
            [self.refreshControl endRefreshing];
        });
    }];
}

- (void)clickOkButton:(id)sender {
    self.updatingIndicatorView.hidden = NO;
    [self.updatingIndicatorView startAnimating];
    
    [self.channel inviteUsers:[self.selectedUsers allValues] completionHandler:^(SBDError * _Nullable error) {
        self.updatingIndicatorView.hidden = YES;
        [self.updatingIndicatorView stopAnimating];
        
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
            
            [vc addAction:closeAction];
            
            [self presentViewController:vc animated:YES completion:nil];
            
            return;
        }

        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didInviteMembers)]) {
            [self.delegate didInviteMembers];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChannelInviteMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupChannelInviteMemberTableViewCell" forIndexPath:indexPath];
    
    cell.user = self.users[indexPath.row];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        GroupChannelInviteMemberTableViewCell *updateCell = (GroupChannelInviteMemberTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (updateCell) {
            updateCell.nicknameLabel.text = self.users[indexPath.row].nickname;
            [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.users[indexPath.row]]] placeholderImage:[Utils getDefaultUserProfileImage:self.users[indexPath.row]]];
            
            if (self.selectedUsers[self.users[indexPath.row].userId] != nil) {
                [updateCell setSelectedUser:YES];
            }
            else {
                [updateCell setSelectedUser:NO];
            }
        }
    });
    
    if (self.users.count > 0 && indexPath.row == self.users.count - 1) {
        [self loadUserListNextPage:NO];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedUsers[self.users[indexPath.row].userId] != nil) {
        [self.selectedUsers removeObjectForKey:self.users[indexPath.row].userId];
    }
    else {
        self.selectedUsers[self.users[indexPath.row].userId] = self.users[indexPath.row];
    }
    
    self.okButtonItem.title = [NSString stringWithFormat:@"OK(%d)", (int)self.selectedUsers.count];
    
    if (self.selectedUsers.count == 0) {
        self.okButtonItem.enabled = NO;
    }
    else {
        self.okButtonItem.enabled = YES;
    }
    
    [tableView reloadData];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self refreshUserList];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        self.userListQuery = [SBDMain createApplicationUserListQuery];
        [self.userListQuery setUserIdsFilter:@[searchText]];
        [self.userListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.refreshControl endRefreshing];
                });
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.users removeAllObjects];
                for (SBDUser *user in users) {
                    if ([user.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                        continue;
                    }
                    [self.users addObject:user];
                }
                
                [self.tableView reloadData];
                
                [self.refreshControl endRefreshing];
            });
        }];
    }
}

@end
