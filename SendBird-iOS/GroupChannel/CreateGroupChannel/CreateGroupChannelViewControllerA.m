//
//  CreateGroupChannelViewControllerA.m
//  SendBird-iOS
//
//  Created by SendBird on 2/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "CreateGroupChannelViewControllerA.h"
#import "SelectGroupChannelMemberTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Utils.h"
#import "UIViewController+Utils.h"
#import "GroupChannelsViewController.h"

@interface CreateGroupChannelViewControllerA ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong) NSMutableArray<SBDUser *> *users;
@property (strong) SBDApplicationUserListQuery *userListQuery;
@property (strong) UIRefreshControl *refreshControl;
@property (strong) UISearchController *searchController;

@property (strong, nonatomic) UIBarButtonItem *okButtonItem;
@property (strong, nonatomic) UIBarButtonItem *cancelButtonItem;

@end

@implementation CreateGroupChannelViewControllerA

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Create Group Channel";
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;

    self.okButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK(0)" style:UIBarButtonItemStylePlain target:self action:@selector(clickOkButton:)];
    self.navigationItem.rightBarButtonItem = self.okButtonItem;
    
    self.cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(clickCancelCreateGroupChannel:)];
    self.navigationItem.leftBarButtonItem = self.cancelButtonItem;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"User ID";
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.searchController.searchBar.tintColor = [UIColor colorNamed:@"color_bar_item"];
    
    self.users = [[NSMutableArray alloc] init];
    self.selectedUsers = [[NSMutableDictionary alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SelectGroupChannelMemberTableViewCell" bundle:nil] forCellReuseIdentifier:@"SelectGroupChannelMemberTableViewCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshUserList) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.refreshControl = self.refreshControl;
    
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

- (void)clickCancelCreateGroupChannel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickOkButton:(id)sender {
    CreateGroupChannelViewControllerB *vc = [[CreateGroupChannelViewControllerB alloc] initWithNibName:@"CreateGroupChannelViewControllerB" bundle:nil];
    vc.members = self.selectedUsers.allValues;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NotificationDelegate
- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self dismissViewControllerAnimated:NO completion:^{
        UIViewController *cvc = [UIViewController currentViewController];
        if ([cvc isKindOfClass:[GroupChannelsViewController class]]) {
            [((GroupChannelsViewController *)cvc) openChatWithChannelUrl:channelUrl];
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

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

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectGroupChannelMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectGroupChannelMemberTableViewCell"];
    cell.user = self.users[indexPath.row];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SelectGroupChannelMemberTableViewCell *updateCell = (SelectGroupChannelMemberTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
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
