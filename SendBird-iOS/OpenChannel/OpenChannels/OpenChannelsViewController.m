//
//  OpenChannelsViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 12/5/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "OpenChannelsViewController.h"
#import "CreateOpenChannelViewControllerA.h"
#import <SendBirdSDK/SendBirdSDK.h>
#import "OpenChannelTableViewCell.h"
#import "CreateOpenChannelNavigationController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "OpenChannelChatViewController.h"
#import "CustomActivityIndicatorView.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "UIViewController+Utils.h"
#import "GroupChannelsViewController.h"
#import "MainTabBarController.h"

@interface OpenChannelsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *openChannelsTableView;
@property (strong) NSMutableArray<SBDOpenChannel *> *channels;
@property (strong) UIRefreshControl *refreshControl;
@property (strong) UISearchController *searchController;
@property (strong) SBDOpenChannelListQuery *channelListQuery;
@property (strong) NSString *channelNameFilter;
@property (weak, nonatomic) IBOutlet CustomActivityIndicatorView *loadingIndicatorView;
@property (strong, nonatomic) UIBarButtonItem *createChannelBarButton;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;

@end

@implementation OpenChannelsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Open Channels";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    
    self.createChannelBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"img_btn_create_open_channel"] style:UIBarButtonItemStylePlain target:self action:@selector(clickCreateOpenChannel:)];
    self.navigationItem.rightBarButtonItem = self.createChannelBarButton;

    self.openChannelsTableView.delegate = self;
    self.openChannelsTableView.dataSource = self;
    
    [self.openChannelsTableView registerNib:[UINib nibWithNibName:@"OpenChannelTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelTableViewCell"];
    
    self.channels = [[NSMutableArray alloc] init];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshChannelList) forControlEvents:UIControlEventValueChanged];
    
    self.openChannelsTableView.refreshControl = self.refreshControl;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = YES;
    
    self.channelNameFilter = nil;
    
    self.loadingIndicatorView.hidden = YES;
    [self.view bringSubviewToFront:self.loadingIndicatorView];
    
    [self loadChannelListNextPage:YES withChannelNameFilter:self.channelNameFilter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)clickCreateOpenChannel:(id)sender {
    CreateOpenChannelNavigationController *vc  = [[CreateOpenChannelNavigationController alloc] initWithNibName:@"CreateOpenChannelNavigationController" bundle:nil];
    vc.createChannelDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - NotificationDelegate
- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [((MainTabBarController *)self.navigationController.parentViewController) setSelectedIndex:0];
    UIViewController *cvc = [UIViewController currentViewController];
    if ([cvc isKindOfClass:[GroupChannelsViewController class]]) {
        [((GroupChannelsViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OpenChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelTableViewCell"];
    [cell.coverImage setImage:nil];
    
    SBDOpenChannel *channel = self.channels[indexPath.row];
    
    cell.channelNameLabel.text = channel.name;
    
    if (channel.participantCount > 1) {
        cell.participantCountLabel.text = [NSString stringWithFormat:@"%ld participants", channel.participantCount];
    }
    else {
        cell.participantCountLabel.text = [NSString stringWithFormat:@"%ld participant", channel.participantCount];
    }
    
    BOOL asOperator = NO;
    for (SBDUser *op in channel.operators) {
        if ([op.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            asOperator = YES;
            break;
        }
    }
    
    [cell setAsOperator:asOperator];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        OpenChannelTableViewCell *updateCell = (OpenChannelTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (updateCell) {
            NSString *placeholderCoverImage = @"";
            switch (channel.name.length % 3) {
                case 0:
                    placeholderCoverImage = @"img_cover_image_placeholder_1";
                    break;
                case 1:
                    placeholderCoverImage = @"img_cover_image_placeholder_2";
                    break;
                case 2:
                    placeholderCoverImage = @"img_cover_image_placeholder_3";
                    break;
                default:
                    placeholderCoverImage = @"img_cover_image_placeholder_1";
                    break;
            }
            [updateCell.coverImage setImageWithURL:[NSURL URLWithString:channel.coverUrl] placeholderImage:[UIImage imageNamed:placeholderCoverImage]];
        }
    });

    if (self.channels.count > 0 && indexPath.row == self.channels.count - 1) {
        [self loadChannelListNextPage:NO withChannelNameFilter:self.channelNameFilter];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.channels.count == 0) {
        if (self.channelNameFilter == nil) {
            self.emptyLabel.text = @"There are no open channels";
        }
        else {
            self.emptyLabel.text = @"Search results not found";
        }
        self.emptyLabel.hidden = NO;
    }
    else {
        self.emptyLabel.hidden = YES;
    }
    return self.channels.count;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SBDOpenChannel *selectedChannel = self.channels[indexPath.row];
    self.loadingIndicatorView.hidden = NO;
    [self.loadingIndicatorView startAnimating];
    [selectedChannel enterChannelWithCompletionHandler:^(SBDError * _Nullable error) {
        self.loadingIndicatorView.hidden = YES;
        [self.loadingIndicatorView stopAnimating];
        
        if (error != nil) {
            [Utils showAlertControllerWithError:error viewController:self];
            return;
        }
        
        OpenChannelChatViewController *vc = [[OpenChannelChatViewController alloc] initWithNibName:@"OpenChannelChatViewController" bundle:nil];
        vc.channel = selectedChannel;
        vc.hidesBottomBarWhenPushed = YES;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - Load channels
- (void)refreshChannelList {
    [self loadChannelListNextPage:YES withChannelNameFilter:self.channelNameFilter];
}

- (void)clearSearchFilter {
    self.channelNameFilter = nil;
}

- (void)loadChannelListNextPage:(BOOL)refresh withChannelNameFilter:(NSString *)channelNameFilter {
    if (refresh) {
        self.channelListQuery = nil;
    }
    
    if (self.channelListQuery == nil) {
        self.channelListQuery = [SBDOpenChannel createOpenChannelListQuery];
        self.channelListQuery.limit = 20;
        if (channelNameFilter != nil && channelNameFilter.length > 0) {
            [self.channelListQuery setChannelNameFilter:channelNameFilter];
        }
    }
    
    if (self.channelListQuery.hasNext == NO) {
        return;
    }
    
    [self.channelListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDOpenChannel *> * _Nullable channels, SBDError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            
            [Utils showAlertControllerWithError:error viewController:self];
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (refresh) {
                [self.channels removeAllObjects];
            }
            
            [self.channels addObjectsFromArray:channels];
            [self.openChannelsTableView reloadData];
            
            [self.refreshControl endRefreshing];
        });
    }];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.channelNameFilter = nil;
    
    [self refreshChannelList];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.channelNameFilter = searchBar.text;
    
    [self refreshChannelList];
}

#pragma mark - CreateOpenChannelDelegate
- (void)didCreate:(SBDOpenChannel *)channel {
    self.channelNameFilter = nil;
    
    [self refreshChannelList];
}

#pragma mark - OpenChannelChatDelegate
- (void)didUpdateOpenChannel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.openChannelsTableView reloadData];
    });
}

@end

