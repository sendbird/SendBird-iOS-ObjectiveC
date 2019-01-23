//
//  MainTabBarController.m
//  SendBird-iOS
//
//  Created by SendBird on 11/16/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "MainTabBarController.h"
#import "AppDelegate.h"
#import "SettingsNavitationViewController.h"
#import "OpenChannelsNavigationController.h"
#import "GroupChannelsNavigationController.h"
#import "OpenChannelsViewController.h"
#import "UIViewController+Utils.h"
#import "GroupChannelsViewController.h"
#import "GroupChannelChatViewController.h"

#define TITLE_GROUP_CHANNELS @"Group Channels"
#define TITLE_OPEN_CHANNELS @"Open Channels"
#define TITLE_SETTINGS @"Settings"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [SBDConnectionManager addNetworkDelegate:self identifier:self.description];
    [SBDMain addChannelDelegate:self identifier:self.description];
    
    GroupChannelsNavigationController *groupChannelsNavigationController = [[GroupChannelsNavigationController alloc] init];
    UITabBarItem *groupChannelsTabBarItem = [[UITabBarItem alloc] initWithTitle:TITLE_GROUP_CHANNELS image:[UIImage imageNamed:@"img_tab_group_channel_normal"] selectedImage:[UIImage imageNamed:@"img_tab_group_channel_selected"]];
    groupChannelsNavigationController.tabBarItem = groupChannelsTabBarItem;
    
    OpenChannelsNavigationController *openChannelsNavigationController = [[OpenChannelsNavigationController alloc] init];
    UITabBarItem *openChannelsTabBarItem = [[UITabBarItem alloc] initWithTitle:TITLE_OPEN_CHANNELS image:[UIImage imageNamed:@"img_tab_open_channel_normal"] selectedImage:[UIImage imageNamed:@"img_tab_open_channel_selected"]];
    openChannelsNavigationController.tabBarItem = openChannelsTabBarItem;
    
    SettingsNavitationViewController *settingsNavigationController = [[SettingsNavitationViewController alloc] init];
    UITabBarItem *settingsTabBarItem = [[UITabBarItem alloc] initWithTitle:TITLE_SETTINGS image:[UIImage imageNamed:@"img_tab_settings_normal"] selectedImage:[UIImage imageNamed:@"img_tab_settings_selected"]];
    settingsNavigationController.tabBarItem = settingsTabBarItem;
    
    [self.tabBar setTintColor:[UIColor colorNamed:@"color_bar_item"]];

    [self addChildViewController:groupChannelsNavigationController];
    [self addChildViewController:openChannelsNavigationController];
    [self addChildViewController:settingsNavigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item.title isEqualToString:TITLE_GROUP_CHANNELS] || [item.title isEqualToString:TITLE_SETTINGS]) {
        for (UIViewController *vc in self.childViewControllers) {
            if ([vc isKindOfClass:[OpenChannelsNavigationController class]]) {
                OpenChannelsNavigationController *openChannelsNavigationController = (OpenChannelsNavigationController *)vc;
                for (UIViewController *openchatvc in openChannelsNavigationController.viewControllers) {
                    if ([openchatvc isKindOfClass:[OpenChannelsViewController class]]) {
                        OpenChannelsViewController *openChannelsViewController = (OpenChannelsViewController *)openchatvc;
                        if (openChannelsViewController.navigationItem.searchController.active == YES) {
                            openChannelsViewController.navigationItem.searchController.active = NO;
                            [openChannelsViewController.navigationItem.searchController dismissViewControllerAnimated:YES completion:nil];
                            [openChannelsViewController clearSearchFilter];
                            [openChannelsViewController refreshChannelList];
                            break;
                        }
                        break;
                    }
                }
                break;
            }
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - SBDNetworkDelegate
- (void)didReconnect {

}

#pragma mark - SBDChannelDelegate
- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    UIViewController *topViewController = [UIViewController currentViewController];
    if ([topViewController isKindOfClass:[GroupChannelsViewController class]]) {
        return;
    }
    
    if ([topViewController isKindOfClass:[GroupChannelChatViewController class]]) {
        GroupChannelChatViewController *vc = (GroupChannelChatViewController *)topViewController;
        if (vc.channel == nil || [vc.channel.channelUrl isEqualToString:sender.channelUrl]) {
            return;
        }
    }
    
    if (![sender isKindOfClass:[SBDGroupChannel class]]) {
        return;
    }
    
    if (!((SBDGroupChannel *)sender).isPushEnabled) {
        return;
    }
    
    // Do not disturb.
    int startHour = 0;
    int startMin = 0;
    int endHour = 0;
    int endMin = 0;
    BOOL isDoNotDisturbOn = NO;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_dnd_start_hour"] != nil) {
        startHour = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_dnd_start_hour"] intValue];
    }
    else {
        startHour = -1;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_dnd_start_min"] != nil) {
        startMin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_dnd_start_min"] intValue];
    }
    else {
        startMin = -1;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_dnd_end_hour"] != nil) {
        endHour = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_dnd_end_hour"] intValue];
    }
    else {
        endHour = -1;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_dnd_end_min"] != nil) {
        endMin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_dnd_end_min"] intValue];
    }
    else {
        endMin = -1;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_dnd_on"] != nil) {
        isDoNotDisturbOn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_dnd_on"] boolValue];
    }
    
    
    if (startHour != -1 && startMin != -1 && endHour != -1 && endMin != -1  && isDoNotDisturbOn) {
        NSDate *date = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        
        NSInteger convertedStartMin = startHour * 60 + startMin;
        NSInteger convertedEndMin = endHour * 60 + endMin;
        NSInteger convertedCurrentMin = hour * 60 + minute;
        
        if (convertedStartMin <= convertedEndMin && convertedStartMin <= convertedCurrentMin && convertedEndMin >= convertedCurrentMin) {
            return;
        }
        else if (convertedStartMin > convertedEndMin && (convertedStartMin < convertedCurrentMin || convertedEndMin > convertedCurrentMin)) {
            return;
        }
    }
    
    NSString *title = @"";
    NSString *body = @"";
    NSString *type = @"";
    NSString *customType = @"";
    if ([message isKindOfClass:[SBDUserMessage class]]) {
        SBDUserMessage *userMessage = (SBDUserMessage *)message;
        SBDUser *sender = userMessage.sender;
        
        type = @"MESG";
        body = [NSString stringWithFormat:@"%@: %@", sender.nickname, userMessage.message];
        customType = userMessage.customType;
    }
    else if ([message isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)message;
        SBDUser *sender = fileMessage.sender;
        
        if ([fileMessage.type hasPrefix:@"image"]) {
            body = [NSString stringWithFormat:@"%@: (Image)", sender.nickname];
        }
        else if ([fileMessage.type hasPrefix:@"video"]) {
            body = [NSString stringWithFormat:@"%@: (Video)", sender.nickname];
        }
        else if ([fileMessage.type hasPrefix:@"audio"]) {
            body = [NSString stringWithFormat:@"%@: (Audio)", sender.nickname];
        }
        else {
            body = [NSString stringWithFormat:@"%@: (File)", sender.nickname];
        }
    }
    else if ([message isKindOfClass:[SBDAdminMessage class]]) {
        SBDAdminMessage *adminMessage = (SBDAdminMessage *)message;

        title = @"";
        body = adminMessage.message;
    }
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:body arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    content.categoryIdentifier = @"SENDBIRD_NEW_MESSAGE";
    content.userInfo = @{
                         @"sendbird": @{
                                 @"type": type,
                                 @"custom_type": customType,
                                 @"channel": @{
                                         @"channel_url": sender.channelUrl,
                                         },
                                 @"data": @"",
                                 },
                         };
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"%@_%@", content.categoryIdentifier, sender.channelUrl] content:content trigger:trigger];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            //                NSLog(@"%@", error.localizedDescription);
        }
    }];
}

@end
