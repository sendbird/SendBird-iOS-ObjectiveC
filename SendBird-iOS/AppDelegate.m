//
//  AppDelegate.m
//  SendBird-iOS
//
//  Created by SendBird on 11/9/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "AppDelegate.h"
#import <SendBirdSDK/SendBirdSDK.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFURLRequestSerialization.h>
#import <AFNetworking/AFImageDownloader.h>
#import <AFNetworking/UIImage+AFNetworking.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MainTabBarController.h"
#import "LoginViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "MainTabBarController.h"
#import "UIViewController+Utils.h"
#import "GroupChannelsViewController.h"
#import "GroupChannelChatViewController.h"
#import "NotificationDelegate.h"
#import "UserProfileViewController.h"
#import "OpenChannelsViewController.h"
#import "CreateGroupChannelViewControllerA.h"
#import "CreateGroupChannelViewControllerB.h"
#import "OpenChannelChatViewController.h"
#import "OpenChannelSettingsViewController.h"
#import "OpenChannelParticipantListViewController.h"
#import "OpenChannelBannedUserListViewController.h"
#import "OpenChannelMutedUserListViewController.h"
#import "SelectOperatorsViewController.h"
#import "OpenChannelCoverImageNameSettingViewController.h"
#import "CreateOpenChannelViewControllerA.h"
#import "CreateOpenChannelViewControllerB.h"
#import "SettingsViewController.h"
#import "UpdateUserProfileViewController.h"
#import "SettingsBlockedUserListViewController.h"
#import "Utils.h"

//#import <KSCrash/KSCrash.h> // TODO: Remove this
//#import <KSCrash/KSCrashInstallation+Alert.h>
//#import <KSCrash/KSCrashInstallationStandard.h>
//#import <KSCrash/KSCrashInstallationQuincyHockey.h>
//#import <KSCrash/KSCrashInstallationEmail.h>
//#import <KSCrash/KSCrashInstallationVictory.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

//- (void) installCrashHandler
//{
//    KSCrashInstallation* installation = [self makeEmailInstallation];
//    [installation install];
//    [KSCrash sharedInstance].deleteBehaviorAfterSendAll = KSCDeleteAlways; // TODO: Remove this
//}
//
//- (KSCrashInstallation*) makeEmailInstallation
//{
//    NSString* emailAddress = @"jed@sendbird.com";
//
//    KSCrashInstallationEmail* email = [KSCrashInstallationEmail sharedInstance];
//    email.recipients = @[emailAddress];
//    email.subject = @"Crash Report";
//    email.message = @"This is a crash report";
//    email.filenameFmt = @"crash-report-%d.txt.gz";
//
//    [email addConditionalAlertWithTitle:@"Crash Detected"
//                                message:@"The app crashed last time it was launched. Send a crash report?"
//                              yesAnswer:@"Sure!"
//                               noAnswer:@"No thanks"];
//
//    // Uncomment to send Apple style reports instead of JSON.
//    [email setReportStyle:KSCrashEmailReportStyleApple useDefaultFilenameFormat:YES];
//
//    return email;
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [self installCrashHandler];
//    [SBDMain setLogLevel:999999999];
    [SBDOptions setConnectionTimeout:5];
    [SBDOptions setAuthenticationTimeout:10];
//    [SBDMain initWithApplicationId:@"E9AFEC82-52BB-4423-861B-1C8E287AAC54"]; // New Sample
    [SBDMain initWithApplicationId:@"9DA1B1F4-0BE6-4DA8-82C5-2E81DAB56F23"]; // Old Sample
//    [SBDMain initWithApplicationId:@"4024FA9A-CD7B-4B1E-99AC-072086688AC9"]; // Intoz

    [self registerForRemoteNotification];
    
    [UINavigationBar appearance].tintColor = [UIColor colorNamed:@"color_navigation_tint"];
    
    // Initialize AFNetworking to download an image that has a binary/octet-stream as a mime type.
    AFImageDownloader *sharedImageDownloader = [UIImageView sharedImageDownloader];
    NSMutableSet *types = [[NSMutableSet alloc] initWithSet:[sharedImageDownloader sessionManager].responseSerializer.acceptableContentTypes];
    [types addObject:@"binary/octet-stream"];
    [sharedImageDownloader sessionManager].responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithSet:types];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (audioSession != nil) {
        NSError *error = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
        
        if (error != nil) {
            NSLog(@"Set Audio Session error: %@", error);
        }
    }
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIStoryboard *launchScreenStoryboard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    UIViewController *launchViewController = [launchScreenStoryboard instantiateViewControllerWithIdentifier:@"LaunchScreenViewController"];
    self.window.rootViewController = launchViewController;
    [self.window makeKeyAndVisible];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    // iOS 10 and later for local notification.
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}

- (void)registerForRemoteNotification {
    float osVersion = [UIDevice currentDevice].systemVersion.floatValue;
    if (osVersion >= 10.0) {
#if !(TARGET_OS_SIMULATOR) && (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0)
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@"Tries to register push token, granted: %d, error: %@", granted, error);
            if (granted) {
                [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
                        return;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                    });
                }];
            }
        }];
        return;
#else
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        UNAuthorizationOptions options = UNAuthorizationOptionAlert;
        [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {

        }];
#endif
    }
    else {
#if !(TARGET_OS_SIMULATOR)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }
#pragma clang diagnostic pop
#endif
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [SBDMain registerDevicePushToken:deviceToken unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
        if (error == nil) {
            if (status == SBDPushTokenRegistrationStatusPending) {
                NSLog(@"Push registration is pending.");
            }
            else {
                NSLog(@"APNS Token is registered.");
            }
        }
        else {
            NSLog(@"APNS registration failed with error: %@", error);
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (userInfo[@"sendbird"] != nil) {
        NSString *channelUrl = userInfo[@"sendbird"][@"channel"][@"channel_url"];
        self.pushReceivedGroupChannel = channelUrl;
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    self.pushReceivedGroupChannel = userInfo[@"sendbird"][@"channel"][@"channel_url"];
    
    [SBDConnectionManager setAuthenticateDelegate:self];
    [SBDConnectionManager authenticate];

    completionHandler();
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(nonnull void (^)(void))completionHandler {
    NSLog(@"method for handling events for background url session is waiting to be process. background session id: %@", identifier);
    if (completionHandler != nil) {
        completionHandler();
    }
}

- (void)jumpToGroupChannel:(NSString *)channelUrl {
    UIViewController *vc = [UIViewController currentViewController];

    if ([vc isKindOfClass:[GroupChannelsViewController class]]) {
        GroupChannelsViewController *cvc = (GroupChannelsViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[GroupChannelChatViewController class]]) {
        GroupChannelChatViewController *cvc = (GroupChannelChatViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[GroupChannelSettingsViewController class]]) {
        GroupChannelSettingsViewController *cvc = (GroupChannelSettingsViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[GroupChannelCoverImageNameSettingViewController class]]) {
        GroupChannelCoverImageNameSettingViewController *cvc = (GroupChannelCoverImageNameSettingViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[GroupChannelInviteMemberViewController class]]) {
        GroupChannelInviteMemberViewController *cvc = (GroupChannelInviteMemberViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[CreateGroupChannelViewControllerA class]]) {
        CreateGroupChannelViewControllerA *cvc = (CreateGroupChannelViewControllerA *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[CreateGroupChannelViewControllerB class]]) {
        CreateGroupChannelViewControllerB *cvc = (CreateGroupChannelViewControllerB *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[UserProfileViewController class]]) {
        UserProfileViewController *cvc = (UserProfileViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[OpenChannelsViewController class]]) {
        OpenChannelsViewController *cvc = (OpenChannelsViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[OpenChannelChatViewController class]]) {
        OpenChannelChatViewController *cvc = (OpenChannelChatViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[OpenChannelSettingsViewController class]]) {
        OpenChannelSettingsViewController *cvc = (OpenChannelSettingsViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[OpenChannelParticipantListViewController class]]) {
        OpenChannelParticipantListViewController *cvc = (OpenChannelParticipantListViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[OpenChannelBannedUserListViewController class]]) {
        OpenChannelBannedUserListViewController *cvc = (OpenChannelBannedUserListViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[OpenChannelMutedUserListViewController class]]) {
        OpenChannelMutedUserListViewController *cvc = (OpenChannelMutedUserListViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[SelectOperatorsViewController class]]) {
        SelectOperatorsViewController *cvc = (SelectOperatorsViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[OpenChannelCoverImageNameSettingViewController class]]) {
        OpenChannelCoverImageNameSettingViewController *cvc = (OpenChannelCoverImageNameSettingViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[CreateOpenChannelViewControllerA class]]) {
        CreateOpenChannelViewControllerA *cvc = (CreateOpenChannelViewControllerA *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[CreateOpenChannelViewControllerB class]]) {
        CreateOpenChannelViewControllerB *cvc = (CreateOpenChannelViewControllerB *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[SettingsViewController class]]) {
        SettingsViewController *cvc = (SettingsViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[UpdateUserProfileViewController class]]) {
        UpdateUserProfileViewController *cvc = (UpdateUserProfileViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[SettingsBlockedUserListViewController class]]) {
        SettingsBlockedUserListViewController *cvc = (SettingsBlockedUserListViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
    else if ([vc isKindOfClass:[LoginViewController class]]) {
        LoginViewController *cvc = (LoginViewController *)vc;
        [cvc openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - SBDAuthenticateDelegate
- (void)shouldHandleAuthInfoWithCompletionHandler:(void (^)(NSString * _Nullable, NSString * _Nullable, NSString * _Nullable, NSString * _Nullable))completionHandler {
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_id"];
    completionHandler(userId, nil, nil, nil);
}

- (void)didFinishAuthenticationWithUser:(SBDUser *)user error:(SBDError *)error {
    if (error == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sendbird_auto_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [SBDMain registerDevicePushToken:[SBDMain getPendingPushToken] unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
            if (error != nil) {
                NSLog(@"APNS registration failed.");
                return;
            }
            
            if (status == SBDPushTokenRegistrationStatusPending) {
                NSLog(@"Push registration is pending.");
            }
            else {
                NSLog(@"APNS Token is registered.");
            }
        }];
        
        if (self.pushReceivedGroupChannel != nil) {
            UIViewController *vc = [UIViewController currentViewController];
            if ([vc isKindOfClass:[UIAlertController class]]) {
                [vc dismissViewControllerAnimated:NO completion:^{
                    [self jumpToGroupChannel:self.pushReceivedGroupChannel];
                }];
            }
            else {
                [self jumpToGroupChannel:self.pushReceivedGroupChannel];
            }
            
            self.pushReceivedGroupChannel = nil;
        }
        else {
            MainTabBarController *mainTabBarController = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle:nil];
            [[UIViewController currentViewController] presentViewController:mainTabBarController animated:NO completion:nil];
        }
    }
}

@end
