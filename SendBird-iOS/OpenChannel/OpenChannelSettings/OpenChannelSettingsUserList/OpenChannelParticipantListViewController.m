//
//  OpenChannelParticipantListViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 2/8/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "OpenChannelParticipantListViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Utils.h"
#import "OpenChannelSettingsUserTableViewCell.h"
#import "UserProfileViewController.h"
#import "OpenChannelSettingsViewController.h"
#import "UIViewController+Utils.h"

@interface OpenChannelParticipantListViewController ()

@property (strong) SBDUserListQuery *participantListQuery;
@property (strong) NSMutableArray<SBDUser *> *participants;
@property (strong) UIRefreshControl *refreshControl;

@end

@implementation OpenChannelParticipantListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Participants";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    self.participants = [[NSMutableArray alloc] init];
    self.participantListQuery = nil;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshParticipantList) forControlEvents:UIControlEventValueChanged];
    
    [self.participantsTableView registerNib:[UINib nibWithNibName:@"OpenChannelSettingsUserTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelSettingsUserTableViewCell"];
    self.participantsTableView.refreshControl = self.refreshControl;
    
    self.participantsTableView.delegate = self;
    self.participantsTableView.dataSource = self;
    
    [self loadParticipantListNextPage:YES];
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

- (void)refreshParticipantList {
    [self loadParticipantListNextPage:YES];
}

- (void)loadParticipantListNextPage:(BOOL)refresh {
    if (refresh) {
        self.participantListQuery = nil;
    }
    
    if (self.participantListQuery == nil) {
        self.participantListQuery = [self.channel createParticipantListQuery];
        self.participantListQuery.limit = 20;
    }
    
    if (self.participantListQuery.hasNext == NO) {
        return;
    }
    
    [self.participantListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (refresh) {
                [self.participants removeAllObjects];
            }
            
            [self.participants addObjectsFromArray:users];
            [self.participantsTableView reloadData];
            
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
    
    SBDUser *participant = self.participants[indexPath.row];
    
    cell.nicknameLabel.text = participant.nickname;

    dispatch_async(dispatch_get_main_queue(), ^{
        OpenChannelSettingsUserTableViewCell *updateCell = (OpenChannelSettingsUserTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (updateCell) {
            [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.participants[indexPath.row]]] placeholderImage:[Utils getDefaultUserProfileImage:self.participants[indexPath.row]]];
        }
    });
    
    if (self.participants.count > 0 && indexPath.row == self.participants.count - 1) {
        [self loadParticipantListNextPage:NO];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.participants.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UserProfileViewController *vc = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
    vc.user = self.participants[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

@end
