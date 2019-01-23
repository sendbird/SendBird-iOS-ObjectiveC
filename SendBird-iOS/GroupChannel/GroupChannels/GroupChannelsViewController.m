//
//  GroupChannelsViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 2/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelsViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "AppDelegate.h"

#import "GroupChannelChatViewController.h"
#import "GroupChannelsNavigationController.h"

#import "GroupChannelTableViewCell.h"
#import "CustomActivityIndicatorView.h"

#import "Utils.h"

@interface GroupChannelsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *groupChannelsTableView;
@property (weak, nonatomic) IBOutlet CustomActivityIndicatorView *loadingIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *toastView;
@property (weak, nonatomic) IBOutlet UILabel *toastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;

@property (strong) UIRefreshControl *refreshControl;
@property (strong) NSMutableDictionary<NSString *, NSTimer *> *typingIndicatorTimer;
@property (strong) UIBarButtonItem *createChannelBarButton;

@property (strong) SBDGroupChannelListQuery *channelListQuery;
@property (strong) NSMutableArray<SBDGroupChannel *> *channels;
@property (atomic) BOOL toastCompleted;

@end

@implementation GroupChannelsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Group Channels";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    
    self.createChannelBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"img_btn_create_group_channel"] style:UIBarButtonItemStylePlain target:self action:@selector(clickCreateGroupChannel:)];
    self.navigationItem.rightBarButtonItem = self.createChannelBarButton;
    
    self.typingIndicatorTimer = [[NSMutableDictionary alloc] init];
    self.groupChannelsTableView.delegate = self;
    self.groupChannelsTableView.dataSource = self;
    self.toastCompleted = YES;
    
    [self.groupChannelsTableView registerNib:[UINib nibWithNibName:@"GroupChannelTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelTableViewCell"];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressChannel:)];
    longPressGesture.minimumPressDuration = 1.0;
    [self.groupChannelsTableView addGestureRecognizer:longPressGesture];
    
    self.channels = [[NSMutableArray alloc] init];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshChannelList) forControlEvents:UIControlEventValueChanged];
    
    self.groupChannelsTableView.refreshControl = self.refreshControl;
    
    self.loadingIndicatorView.hidden = YES;
    [self.view bringSubviewToFront:self.loadingIndicatorView];
    
    [self updateTotalUnreadMessageCountBadge];
    
    [self loadChannelListNextPage:YES];
    
    [SBDMain addChannelDelegate:self identifier:self.description];
    [SBDMain addConnectionDelegate:self identifier:self.description];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showToast:(NSString *)message completion:(void (^)(void))completion {
    self.toastCompleted = NO;
    self.toastView.alpha = 1;
    self.toastMessageLabel.text = message;
    self.toastView.hidden = NO;
    
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.toastView.alpha = 0;
    } completion:^(BOOL finished) {
        self.toastView.hidden = YES;
        self.toastCompleted = YES;
        if (completion != nil) {
            completion();
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *vc = [segue destinationViewController];
    if ([vc isKindOfClass:[CreateGroupChannelNavigationController class]]) {
        ((CreateGroupChannelNavigationController *)vc).channelCreationDelegate = self;
    }
}

- (void)clickCreateGroupChannel:(id)sender {
    CreateGroupChannelNavigationController *vc = [[CreateGroupChannelNavigationController alloc] init];
    vc.channelCreationDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)longPressChannel:(UILongPressGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.groupChannelsTableView];
    NSIndexPath *indexPath = [self.groupChannelsTableView indexPathForRowAtPoint:point];
    if (indexPath != nil && recognizer.state == UIGestureRecognizerStateBegan) {
        SBDGroupChannel *channel = self.channels[indexPath.row];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[Utils createGroupChannelName:channel] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *actionHide = [UIAlertAction actionWithTitle:@"Hide Channel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [channel hideChannelWithHidePreviousMessages:YES completionHandler:^(SBDError * _Nullable error) {
                if (error != nil) {
                    [Utils showAlertControllerWithError:error viewController:self];
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showToast:@"Hidden" completion:^{
                        if (self.channels.count == 0 && self.toastCompleted) {
                            self.emptyLabel.hidden = NO;
                        }
                        else {
                            self.emptyLabel.hidden = YES;
                        }
                    }];
                    
                    [self.channels removeObjectAtIndex:indexPath.row];
                    [self.groupChannelsTableView reloadData];
                });
            }];
        }];
        UIAlertAction *actionLeave = [UIAlertAction actionWithTitle:@"Leave Channel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [channel leaveChannelWithCompletionHandler:^(SBDError * _Nullable error) {
                if (error != nil) {
                    [Utils showAlertControllerWithError:error viewController:self];
                    return;
                }
            }];
        }];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:actionHide];
        [alertController addAction:actionLeave];
        [alertController addAction:actionCancel];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)updateTotalUnreadMessageCountBadge {
    [SBDMain getTotalUnreadMessageCountWithCompletionHandler:^(NSUInteger unreadCount, SBDError * _Nullable error) {
        if (error != nil) {
            [self.navigationController tabBarItem].badgeValue = nil;
            return;
        }
        
        if (unreadCount > 0) {
            [self.navigationController tabBarItem].badgeValue = [NSString stringWithFormat:@"%lu", unreadCount];
        }
        else {
            [self.navigationController tabBarItem].badgeValue = nil;
        }
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SBDMain getTotalUnreadMessageCountWithCompletionHandler:^(NSUInteger unreadCount, SBDError * _Nullable error) {
            if (error != nil) {
                [self.navigationController tabBarItem].badgeValue = nil;
                return;
            }
            
            if (unreadCount > 0) {
                [self.navigationController tabBarItem].badgeValue = [NSString stringWithFormat:@"%lu", unreadCount];
            }
            else {
                [self.navigationController tabBarItem].badgeValue = nil;
            }
        }];
    });
}

- (NSString *)buildTypingIndicatorLabel:(SBDGroupChannel *)channel {
    NSArray<SBDMember *> *typingMembers = [channel getTypingMembers];
    if (typingMembers == nil || typingMembers.count == 0) {
        return @"";
    }
    else {
        if (typingMembers.count == 1) {
            return [NSString stringWithFormat:@"%@ is typing.", typingMembers[0].nickname];
        }
        else if (typingMembers.count == 2) {
            return [NSString stringWithFormat:@"%@ and %@ are typing.", typingMembers[0].nickname, typingMembers[1].nickname];
        }
        else {
            return @"Several people are typing.";
        }
    }
}

- (void)typingIndicatorTimeout:(NSTimer *)timer {
    NSString *channelUrl = (NSString *)timer.userInfo;
    [self.typingIndicatorTimer[timer.userInfo] invalidate];
    [self.typingIndicatorTimer removeObjectForKey:channelUrl];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.groupChannelsTableView reloadData];
    });
}

#pragma mark - NotificationDelegate
- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [SBDGroupChannel getChannelWithUrl:channelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
        if (error != nil) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            GroupChannelChatViewController *vc = [[GroupChannelChatViewController alloc] initWithNibName:@"GroupChannelChatViewController" bundle:nil];
            vc.channel = channel;
            vc.hidesBottomBarWhenPushed = YES;
            vc.delegate = self;
            
            ((AppDelegate *)[UIApplication sharedApplication].delegate).pushReceivedGroupChannel = nil;
            
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupChannelTableViewCell"];
    SBDGroupChannel *channel = self.channels[indexPath.row];
    
    cell.channelNameLabel.text = [Utils createGroupChannelName:channel];
    
    // Last message date time
    NSDateFormatter *lastMessageDateFormatter = [[NSDateFormatter alloc] init];
    
    NSDate *lastMessageDate = nil;
    long long lastUpdateTimestamp = 0;
    if (channel.lastMessage != nil) {
        lastUpdateTimestamp = channel.lastMessage.createdAt;
    }
    else {
        lastUpdateTimestamp = channel.createdAt;
    }
    if ([NSString stringWithFormat:@"%lld", lastUpdateTimestamp].length == 10) {
        lastMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)lastUpdateTimestamp];
    }
    else {
        lastMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)lastUpdateTimestamp / 1000.0];
    }
    NSDate *currDate = [NSDate date];
    
    NSDateComponents *lastMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:lastMessageDate];
    NSDateComponents *currDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currDate];
    
    if (lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day) {
        [lastMessageDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [lastMessageDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        cell.lastUpdatedDateLabel.text = [lastMessageDateFormatter stringFromDate:lastMessageDate];
    }
    else {
        [lastMessageDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [lastMessageDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        cell.lastUpdatedDateLabel.text = [lastMessageDateFormatter stringFromDate:lastMessageDate];
    }
    
    NSString *typingIndicatorText = [self buildTypingIndicatorLabel:channel];
    NSTimer *timer = self.typingIndicatorTimer[channel.channelUrl];
    BOOL showTypingIndicator = NO;
    if (timer != nil && typingIndicatorText.length > 0) {
        showTypingIndicator = YES;
    }
    
    if (showTypingIndicator) {
        cell.lastMessageLabel.hidden = YES;
        cell.typingIndicatorContainerView.hidden = NO;
        cell.typingIndicatorLabel.text = typingIndicatorText;
    }
    else {
        cell.lastMessageLabel.hidden = NO;
        cell.typingIndicatorContainerView.hidden = YES;
        if (channel.lastMessage != nil) {
            if ([channel.lastMessage isKindOfClass:[SBDUserMessage class]]) {
                SBDUserMessage *lastMessage = (SBDUserMessage *)channel.lastMessage;
                cell.lastMessageLabel.text = lastMessage.message;
            }
            else if ([channel.lastMessage isKindOfClass:[SBDFileMessage class]]) {
                SBDFileMessage *lastMessage = (SBDFileMessage *)channel.lastMessage;
                if (lastMessage.type != nil) {
                    if ([lastMessage.type hasPrefix:@"image"]) {
                        cell.lastMessageLabel.text = @"(Image)";
                    }
                    else if ([lastMessage.type hasPrefix:@"video"]) {
                        cell.lastMessageLabel.text = @"(Video)";
                    }
                    else if ([lastMessage.type hasPrefix:@"audio"]) {
                        cell.lastMessageLabel.text = @"(Audio)";
                    }
                    else {
                        cell.lastMessageLabel.text = @"(File)";
                    }
                }
            }
            else {
                cell.lastMessageLabel.text = @"";
            }
        }
        else {
            cell.lastMessageLabel.text = @"";
        }
    }

    cell.unreadMessageCountContainerView.hidden = NO;
    if (channel.unreadMessageCount > 99) {
        cell.unreadMessageCountLabel.text = @"+99";
    }
    else if (channel.unreadMessageCount > 0) {
        cell.unreadMessageCountLabel.text = [NSString stringWithFormat:@"%ld", channel.unreadMessageCount];
    }
    else {
        cell.unreadMessageCountContainerView.hidden = YES;
    }
    
    if (channel.memberCount <= 2) {
        cell.memberCountContainerView.hidden = YES;
    }
    else {
        cell.memberCountContainerView.hidden = NO;
        cell.memberCountLabel.text = [NSString stringWithFormat:@"%ld", channel.memberCount];
    }
    
    if (channel.isPushEnabled) {
        cell.notiOffIconImageView.hidden = YES;
    }
    else {
        cell.notiOffIconImageView.hidden = NO;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray<SBDUser *> *members = [[NSMutableArray alloc] init];
        int count = 0;
        for (SBDUser *member in channel.members) {
            if ([member.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                continue;
            }
            [members addObject:member];
            count += 1;
            if (count == 4) {
                break;
            }
        }
        GroupChannelTableViewCell *updateCell = (GroupChannelTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (updateCell) {
            updateCell.singleCoverImageContainerView.hidden = YES;
            updateCell.doubleCoverImageContainerView.hidden = YES;
            updateCell.tripleCoverImageContainerView.hidden = YES;
            updateCell.quadrupleCoverImageContainerView.hidden = YES;
            
            if (channel.coverUrl.length > 0 && ![channel.coverUrl hasPrefix:@"https://sendbird.com/main/img/cover/"]) {
                updateCell.singleCoverImageContainerView.hidden = NO;
                [updateCell.singleCoverImageView setImageWithURL:[NSURL URLWithString:channel.coverUrl] placeholderImage:[UIImage imageNamed:@"img_cover_image_placeholder_1"]];
            }
            else {
                if (members.count == 0) {
                    updateCell.singleCoverImageContainerView.hidden = NO;
                    [updateCell.singleCoverImageView setImage:[UIImage imageNamed:@"img_cover_image_placeholder_1"]];
                }
                else if (members.count == 1) {
                    updateCell.singleCoverImageContainerView.hidden = NO;
                    [updateCell.singleCoverImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:members[0]]] placeholderImage:[Utils getDefaultUserProfileImage:members[0]]];
                }
                else if (members.count == 2) {
                    updateCell.doubleCoverImageContainerView.hidden = NO;
                    [updateCell.doubleCoverImageView1 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:members[0]]] placeholderImage:[Utils getDefaultUserProfileImage:members[0]]];
                    [updateCell.doubleCoverImageView2 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:members[1]]] placeholderImage:[Utils getDefaultUserProfileImage:members[1]]];
                }
                else if (members.count == 3) {
                    updateCell.tripleCoverImageContainerView.hidden = NO;
                    [updateCell.tripleCoverImageView1 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:members[0]]] placeholderImage:[Utils getDefaultUserProfileImage:members[0]]];
                    [updateCell.tripleCoverImageView2 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:members[1]]] placeholderImage:[Utils getDefaultUserProfileImage:members[1]]];
                    [updateCell.tripleCoverImageView3 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:members[2]]] placeholderImage:[Utils getDefaultUserProfileImage:members[2]]];
                }
                else if (members.count == 4) {
                    updateCell.quadrupleCoverImageContainerView.hidden = NO;
                    [updateCell.quadrupleCoverImageView1 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:members[0]]] placeholderImage:[Utils getDefaultUserProfileImage:members[0]]];
                    [updateCell.quadrupleCoverImageView2 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:members[1]]] placeholderImage:[Utils getDefaultUserProfileImage:members[1]]];
                    [updateCell.quadrupleCoverImageView3 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:members[2]]] placeholderImage:[Utils getDefaultUserProfileImage:members[2]]];
                    [updateCell.quadrupleCoverImageView4 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:members[3]]] placeholderImage:[Utils getDefaultUserProfileImage:members[3]]];
                }
            }
        }
    });

    if (self.channels.count > 0 && indexPath.row == self.channels.count - 1) {
        [self loadChannelListNextPage:NO];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.channels.count == 0 && self.toastCompleted) {
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    GroupChannelChatViewController *vc = [[GroupChannelChatViewController alloc] initWithNibName:@"GroupChannelChatViewController" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    vc.channel = self.channels[indexPath.row];
    vc.delegate = self;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *leaveAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Leave" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self.channels[indexPath.row] leaveChannelWithCompletionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                [Utils showAlertControllerWithError:error viewController:self];
                return;
            }
        }];
        completionHandler(YES);
    }];
    leaveAction.backgroundColor = [UIColor colorNamed:@"color_leave_group_channel_bg"];
    
    UIContextualAction *hideAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Hide" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self.channels[indexPath.row] hideChannelWithHidePreviousMessages:YES completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                [Utils showAlertControllerWithError:error viewController:self];
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showToast:@"Hidden" completion:^{
                    if (self.channels.count == 0 && self.toastCompleted) {
                        self.emptyLabel.hidden = NO;
                    }
                    else {
                        self.emptyLabel.hidden = YES;
                    }
                }];
                
                [self.channels removeObjectAtIndex:indexPath.row];
                [self.groupChannelsTableView reloadData];
            });
        }];
        completionHandler(YES);
    }];
    hideAction.backgroundColor = [UIColor colorNamed:@"color_hide_group_channel_bg"];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[leaveAction, hideAction]];
}

#pragma mark - Load channels
- (void)refreshChannelList {
    [self loadChannelListNextPage:YES];
}

- (void)loadChannelListNextPage:(BOOL)refresh {
    if (refresh) {
        self.channelListQuery = nil;
    }
    
    if (self.channelListQuery == nil) {
        self.channelListQuery = [SBDGroupChannel createMyGroupChannelListQuery];
        [self.channelListQuery setOrder:SBDGroupChannelListOrderLatestLastMessage];
        self.channelListQuery.limit = 20;
        self.channelListQuery.includeEmptyChannel = YES;
    }
    
    if (self.channelListQuery.hasNext == NO) {
        return;
    }
    
    [self.channelListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (refresh) {
                [self.channels removeAllObjects];
            }
            
            [self.channels addObjectsFromArray:channels];
            [self.groupChannelsTableView reloadData];
            
            [self.refreshControl endRefreshing];
        });
    }];
}

#pragma mark - CreateGroupChannelViewControllerDelegate
- (void)didCreateGroupChannel:(SBDGroupChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.channels indexOfObject:channel] == NSNotFound) {
            [self.channels insertObject:channel atIndex:0];
        }

        [self.groupChannelsTableView reloadData];
    });
}

#pragma mark - GroupChannelsUpdateListDelegate
- (void)updateGroupChannelList {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.groupChannelsTableView reloadData];
    });
    
    [self updateTotalUnreadMessageCountBadge];
}

#pragma mark - SBDChannelDelegate
- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([sender isKindOfClass:[SBDGroupChannel class]]) {
            BOOL hasChannelInList = NO;
            for (SBDGroupChannel *ch in self.channels) {
                if ([ch.channelUrl isEqualToString:sender.channelUrl]) {
                    [self.channels removeObject:ch];
                    [self.channels insertObject:ch atIndex:0];
                    [self.groupChannelsTableView reloadData];
                    [self updateTotalUnreadMessageCountBadge];
                    
                    hasChannelInList = YES;
                    break;
                }
            }
            
            if (hasChannelInList == NO) {
                [self.channels insertObject:(SBDGroupChannel *)sender atIndex:0];
                [self.groupChannelsTableView reloadData];
                [self updateTotalUnreadMessageCountBadge];
            }
        }
    });
}

- (void)channelDidUpdateTypingStatus:(SBDGroupChannel * _Nonnull)sender {
    NSTimer *timer = self.typingIndicatorTimer[sender.channelUrl];
    if (timer != nil) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(typingIndicatorTimeout:) userInfo:sender.channelUrl repeats:NO];
    self.typingIndicatorTimer[sender.channelUrl] = timer;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.groupChannelsTableView reloadData];
    });
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidJoin:(SBDUser * _Nonnull)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.channels indexOfObject:sender] == NSNotFound) {
            [self.channels insertObject:sender atIndex:0];
        }
        [self.groupChannelsTableView reloadData];
    });
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidLeave:(SBDUser * _Nonnull)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.channels indexOfObject:sender] != NSNotFound) {
            [self.channels removeObject:sender];
        }

        [self.groupChannelsTableView reloadData];
    });
}

- (void)channelWasChanged:(SBDBaseChannel * _Nonnull)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.groupChannelsTableView reloadData];
    });
}

- (void)channel:(SBDBaseChannel * _Nonnull)sender messageWasDeleted:(long long)messageId {
    if ([sender isKindOfClass:[SBDGroupChannel class]]) {
        BOOL hasChannelInList = NO;
        for (SBDGroupChannel *ch in self.channels) {
            if ([ch.channelUrl isEqualToString:sender.channelUrl]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.channels removeObject:ch];
                    [self.channels insertObject:ch atIndex:0];
                    [self.groupChannelsTableView reloadData];
                    [self updateTotalUnreadMessageCountBadge];
                });
                
                hasChannelInList = YES;
            }
        }
        
        if (hasChannelInList == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.channels insertObject:(SBDGroupChannel *)sender atIndex:0];
                [self.groupChannelsTableView reloadData];
                [self updateTotalUnreadMessageCountBadge];
            });
        }
    }
}

#pragma mark - Utilities
- (void)showLoadingIndicatorView {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingIndicatorView.hidden = NO;
        [self.loadingIndicatorView startAnimating];
    });
}

- (void)hideLoadingIndicatorView {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingIndicatorView.hidden = YES;
        [self.loadingIndicatorView stopAnimating];
    });
}

@end
