//
//  ViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 11/9/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "LoginViewController.h"
#import "MainTabBarController.h"
#import "Utils.h"
#import <Photos/Photos.h>
#import "UIViewController+Utils.h"
#import "GroupChannelsViewController.h"

@interface LoginViewController ()
@property (atomic) BOOL keyboardShown;
@property (atomic) BOOL logoChanged;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIImageView *sendbirdTextLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *versionInfoLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userIdLabelTop;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [SBDConnectionManager setAuthenticateDelegate:nil];

    self.keyboardShown = NO;
    self.logoChanged = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    UITapGestureRecognizer *contentViewTapRecognizer = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(tapContentView)];
    self.contentView.userInteractionEnabled = YES;
    [self.contentView addGestureRecognizer:contentViewTapRecognizer];
    
    [self.connectButton addTarget:self action:@selector(clickConnectButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.userIdTextField.delegate = self;
    self.nicknameTextField.delegate = self;
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_id"];
    NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_nickname"];
    self.userIdTextField.text = userId;
    self.nicknameTextField.text = nickname;
    
    // Version
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    if (path != nil) {
        NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSString *sampleUIVersion = infoDict[@"CFBundleShortVersionString"];
        NSString *version = [NSString stringWithFormat:@"Sample UI v%@ / SDK v%@", sampleUIVersion, [SBDMain getSDKVersion]];
        self.versionInfoLabel.text = version;
    }
    
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
        }];
    }
    
    BOOL autoLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_auto_login"] boolValue];
    if (autoLogin) {
        [self connect];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    if (self.logoChanged == NO && self.keyboardShown == NO) {
        [self.view layoutIfNeeded];

        self.scrollViewBottom.constant = keyboardFrameBeginRect.size.height;
        
        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.3 curve:UIViewAnimationCurveEaseOut animations:^{
            self.userIdLabelTop.constant = 23;
            self.sendbirdTextLogoImageView.alpha = 0;
            [self.view layoutIfNeeded];
        }];
        [animator startAnimation];

        self.logoChanged = YES;
    }
    else if (self.logoChanged == YES && self.keyboardShown == NO) {
        self.scrollViewBottom.constant = keyboardFrameBeginRect.size.height;
    }
    
    self.keyboardShown = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.keyboardShown = NO;
    self.scrollViewBottom.constant = 0;
}

- (void)tapContentView {
    if (self.keyboardShown == YES) {
        [self.view endEditing:YES];
    }
}

- (void)clickConnectButton:(id)sender {
    [self connect];
}

- (void)connect {
    [self.view endEditing:YES];
    if ([SBDMain getConnectState] != SBDWebSocketOpen) {
        NSString *userId = [self.userIdTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *nickname = [self.nicknameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (userId.length == 0 || nickname.length == 0) {
            [Utils showAlertControllerWithTitle:@"Error" message:@"User ID and Nickname are required." viewController:self];
            return;
        }
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:userId forKey:@"sendbird_user_id"];
        [userDefault setObject:nickname forKey:@"sendbird_user_nickname"];
        [userDefault synchronize];
        
        [self setUIsWhileConnecting];
        
        [SBDConnectionManager setAuthenticateDelegate:self];
        [SBDConnectionManager authenticate];
    }
    else {
        [SBDMain disconnectWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setUIsForDefault];
            });
        }];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userIdTextField) {
        [textField resignFirstResponder];
        [self.nicknameTextField becomeFirstResponder];
    }
    else if (textField == self.nicknameTextField) {
        [self connect];
    }
    
    return YES;
}

#pragma mark - SBDAuthenticateDelegate
- (void)shouldHandleAuthInfoWithCompletionHandler:(void (^)(NSString * _Nullable, NSString * _Nullable, NSString * _Nullable, NSString * _Nullable))completionHandler {
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_id"];
    completionHandler(userId, nil, nil, nil);
}

- (void)didFinishAuthenticationWithUser:(SBDUser *)user error:(SBDError *)error {
    if (error != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUIsForDefault];
        });
        [Utils showAlertControllerWithError:[SBDError errorWithNSError:error] viewController:self];
        
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sendbird_auto_login"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUIsForDefault];
        
        MainTabBarController *tabBarVC = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle:nil];
        [self presentViewController:tabBarVC animated:YES completion:nil];
    });

    [SBDMain getDoNotDisturbWithCompletionHandler:^(BOOL isDoNotDisturbOn, int startHour, int startMin, int endHour, int endMin, NSString * _Nonnull timezone, SBDError * _Nullable error) {
        [[NSUserDefaults standardUserDefaults] setInteger:startHour forKey:@"sendbird_dnd_start_hour"];
        [[NSUserDefaults standardUserDefaults] setInteger:startMin forKey:@"sendbird_dnd_start_min"];
        [[NSUserDefaults standardUserDefaults] setInteger:endHour forKey:@"sendbird_dnd_end_hour"];
        [[NSUserDefaults standardUserDefaults] setInteger:endMin forKey:@"sendbird_dnd_end_min"];
        [[NSUserDefaults standardUserDefaults] setBool:isDoNotDisturbOn forKey:@"sendbird_dnd_on"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
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
    
    NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_nickname"];
    [SBDMain updateCurrentUserInfoWithNickname:nickname profileUrl:nil completionHandler:^(SBDError * _Nullable error) {
        if (error != nil) {
            [SBDMain disconnectWithCompletionHandler:^{
                [Utils showAlertControllerWithError:error viewController:self];
            }];
            
            return;
        }
    }];
}

#pragma mark - NotificationDelegate
- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self.navigationController popViewControllerAnimated:NO];
    MainTabBarController *tabBarVC = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle:nil];
    [self presentViewController:tabBarVC animated:NO completion:^{
        UIViewController *vc = [UIViewController currentViewController];
        if ([vc isKindOfClass:[GroupChannelsViewController class]]) {
            [((GroupChannelsViewController *)vc) openChatWithChannelUrl:channelUrl];
        }
    }];
}

- (void)setUIsWhileConnecting {
    [self.userIdTextField setEnabled:NO];
    [self.nicknameTextField setEnabled:NO];
    [self.connectButton setEnabled:NO];
    [self.connectButton setTitle:@"Connecting..." forState:UIControlStateNormal];
}

- (void)setUIsForDefault {
    [self.userIdTextField setEnabled:YES];
    [self.nicknameTextField setEnabled:YES];
    [self.connectButton setEnabled:YES];
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
}

@end
