//
//  SettingsViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 3/1/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "SettingsViewController.h"
#import <Photos/Photos.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "Constants.h"
#import "SettingsProfileTableViewCell.h"
#import "SettingsSectionTableViewCell.h"
#import "SettingsSwitchTableViewCell.h"
#import "SettingsTimeTableViewCell.h"
#import "SettingsGeneralTableViewCell.h"
#import "SettingsSignOutTableViewCell.h"
#import "SettingsVersionTableViewCell.h"
#import "SettingsDescriptionTableViewCell.h"
#import "SettingsBlockedUserListViewController.h"
#import "Utils.h"
#import "UIViewController+Utils.h"
#import "MainTabBarController.h"
#import "GroupChannelsViewController.h"

//#import <KSCrash/KSCrash.h> // TODO: Remove this
//#import <KSCrash/KSCrashInstallation+Alert.h>
//#import <KSCrash/KSCrashInstallationStandard.h>
//#import <KSCrash/KSCrashInstallationQuincyHockey.h>
//#import <KSCrash/KSCrashInstallationEmail.h>
//#import <KSCrash/KSCrashInstallationVictory.h>

@interface SettingsViewController ()

@property (atomic) BOOL isDoNotDisturbOn;

@property (atomic) int startHour;
@property (atomic) int startMin;
@property (atomic) NSString *startAmPm;

@property (atomic) int endHour;
@property (atomic) int endMin;
@property (atomic) NSString *endAmPm;

@property (atomic) BOOL startTimeShown;
@property (atomic) BOOL endTimeShown;

@property (atomic) BOOL showPreview;
@property (atomic) BOOL createDistinctChannel;

@property (atomic) BOOL showFromTimePicker;
@property (atomic) BOOL showToTimePicker;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottmMargin;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Settings";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingsSectionTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsProfileTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingsProfileTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSwitchTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingsSwitchTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsTimeTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingsTimeTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsGeneralTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingsGeneralTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSignOutTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingsSignOutTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsVersionTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingsVersionTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsDescriptionTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingsDescriptionTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsTimePickerTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingsTimePickerTableViewCell"];
    
    self.isDoNotDisturbOn = YES;
    self.startTimeShown = NO;
    self.endTimeShown = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 14, 0);
    
    self.showFromTimePicker = NO;
    self.showToTimePicker = NO;
    
    self.showPreview = [[[NSUserDefaults standardUserDefaults] objectForKey:ID_SHOW_PREVIEWS] boolValue];
    self.createDistinctChannel = [[[NSUserDefaults standardUserDefaults] objectForKey:ID_CREATE_DISTINCT_CHANNEL] boolValue];
    
    [self.view bringSubviewToFront:self.loadingIndicatorView];
    self.loadingIndicatorView.hidden = NO;
    [self.loadingIndicatorView startAnimating];
    [SBDMain getDoNotDisturbWithCompletionHandler:^(BOOL isDoNotDisturbOn, int startHour, int startMin, int endHour, int endMin, NSString * _Nonnull timezone, SBDError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadingIndicatorView.hidden = YES;
            [self.loadingIndicatorView stopAnimating];
        });
        
        [[NSUserDefaults standardUserDefaults] setInteger:startHour forKey:@"sendbird_dnd_start_hour"];
        [[NSUserDefaults standardUserDefaults] setInteger:startMin forKey:@"sendbird_dnd_start_min"];
        [[NSUserDefaults standardUserDefaults] setInteger:endHour forKey:@"sendbird_dnd_end_hour"];
        [[NSUserDefaults standardUserDefaults] setInteger:endMin forKey:@"sendbird_dnd_end_min"];
        [[NSUserDefaults standardUserDefaults] setBool:isDoNotDisturbOn forKey:@"sendbird_dnd_on"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        if (error != nil) {
            return;
        }

        self.isDoNotDisturbOn = isDoNotDisturbOn;
        if (startHour < 12) {
            self.startHour = startHour;
            self.startAmPm = @"AM";
        }
        else {
            self.startHour = startHour - 12;
            self.startAmPm = @"PM";
        }
        
        self.startMin = startMin;
        
        if (endHour < 12) {
            self.endHour = endHour;
            self.endAmPm = @"AM";
        }
        else {
            self.endHour = endHour - 12;
            self.endAmPm = @"PM";
        }
        
        self.endMin = endMin;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            SettingsSwitchTableViewCell *switchViewCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
            [switchViewCell.switchButton setOn:isDoNotDisturbOn];
        });
    }];
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
    [((MainTabBarController *)self.navigationController.parentViewController) setSelectedIndex:0];
    UIViewController *cvc = [UIViewController currentViewController];
    if ([cvc isKindOfClass:[GroupChannelsViewController class]]) {
        [((GroupChannelsViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 16;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    switch (indexPath.row) {
        case 0: {
            SettingsSectionTableViewCell *viewCell = (SettingsSectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsSectionTableViewCell"];
            viewCell.sectionLabel.text = @"";
            viewCell.topBorderView.hidden = YES;
            viewCell.bottomBorderView.hidden = NO;
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 1: {
            SettingsProfileTableViewCell *viewCell = (SettingsProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsProfileTableViewCell"];
            viewCell.nicknameLabel.text = [SBDMain getCurrentUser].nickname;
            if ([SBDMain getCurrentUser].nickname.length == 0) {
                viewCell.nicknameLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Please write your nickname" attributes:@{
                                                                                                                                              NSForegroundColorAttributeName: [UIColor grayColor],
                                                                                                                                                     NSFontAttributeName : [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular],
                                                                                                                                                     }];
            }
            viewCell.userIdLabel.text = [SBDMain getCurrentUser].userId;
            dispatch_async(dispatch_get_main_queue(), ^{
                SettingsProfileTableViewCell *updateCell = (SettingsProfileTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                if (updateCell) {
                    [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:[SBDMain getCurrentUser]]] placeholderImage:[Utils getDefaultUserProfileImage:[SBDMain getCurrentUser]]];
                }
            });
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 2: {
            SettingsSectionTableViewCell *viewCell = (SettingsSectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsSectionTableViewCell"];
            viewCell.sectionLabel.text = @"GROUP CHANNEL NOTIFICATIONS";
            viewCell.topBorderView.hidden = NO;
            viewCell.bottomBorderView.hidden = NO;
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 3: {
            SettingsSwitchTableViewCell *viewCell = (SettingsSwitchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsSwitchTableViewCell"];
            viewCell.settingsLabel.text = @"Do Not Disturb";
            if (self.isDoNotDisturbOn) {
                viewCell.bottomBorderView.hidden = NO;
            }
            else {
                viewCell.bottomBorderView.hidden = YES;
            }
            
            viewCell.switchIdentifier = ID_DO_NOT_DISTURB;
            viewCell.delegate = self;
            
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 4: {
            SettingsTimeTableViewCell *viewCell = (SettingsTimeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsTimeTableViewCell"];
            viewCell.settingLabel.text = @"From";
            viewCell.expandedTopBorderView.hidden = YES;
            viewCell.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d %@", self.startHour, self.startMin, self.startAmPm];
            if (self.startTimeShown) {
                viewCell.bottomBorderView.hidden = YES;
                viewCell.expandedBottomBorderView.hidden = NO;
                viewCell.timeLabel.textColor = [UIColor colorNamed:@"color_settings_time_label_highlighted"];
            }
            else {
                viewCell.bottomBorderView.hidden = NO;
                viewCell.expandedBottomBorderView.hidden = YES;
                viewCell.timeLabel.textColor = [UIColor colorNamed:@"color_settings_time_label_normal"];
            }
            if (self.isDoNotDisturbOn) {
                viewCell.hidden = NO;
            }
            else {
                viewCell.hidden = YES;
            }
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 5: {
            SettingsTimePickerTableViewCell *viewCell = (SettingsTimePickerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsTimePickerTableViewCell"];
            
            viewCell.delegate = self;
            viewCell.identifier = @"START";
            [viewCell.timePicker selectRow:self.startHour inComponent:1 animated:NO];
            [viewCell.timePicker selectRow:self.startMin inComponent:2 animated:NO];
            if ([self.startAmPm isEqualToString:@"AM"]) {
                [viewCell.timePicker selectRow:0 inComponent:3 animated:NO];
            }
            else {
                [viewCell.timePicker selectRow:1 inComponent:3 animated:NO];
            }
            
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 6: {
            SettingsTimeTableViewCell *viewCell = (SettingsTimeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsTimeTableViewCell"];
            viewCell.settingLabel.text = @"To";
            viewCell.bottomBorderView.hidden = YES;
            viewCell.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d %@", self.endHour, self.endMin, self.endAmPm];
            
            if (self.startTimeShown) {
                viewCell.expandedTopBorderView.hidden = NO;
            }
            else {
                viewCell.expandedTopBorderView.hidden = YES;
            }
            
            if (self.endTimeShown) {
                viewCell.expandedBottomBorderView.hidden = NO;
                viewCell.timeLabel.textColor = [UIColor colorNamed:@"color_settings_time_label_highlighted"];
            }
            else {
                viewCell.expandedBottomBorderView.hidden = YES;
                viewCell.timeLabel.textColor = [UIColor colorNamed:@"color_settings_time_label_normal"];
            }
            
            if (self.isDoNotDisturbOn) {
                viewCell.hidden = NO;
            }
            else {
                viewCell.hidden = YES;
            }
            cell = (UITableViewCell *)viewCell;
            
        }
            break;
        case 7: {
            SettingsTimePickerTableViewCell *viewCell = (SettingsTimePickerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsTimePickerTableViewCell"];
            viewCell.delegate = self;
            viewCell.identifier = @"END";
            [viewCell.timePicker selectRow:self.endHour inComponent:1 animated:NO];
            [viewCell.timePicker selectRow:self.endMin inComponent:2 animated:NO];
            if ([self.endAmPm isEqualToString:@"AM"]) {
                [viewCell.timePicker selectRow:0 inComponent:3 animated:NO];
            }
            else {
                [viewCell.timePicker selectRow:1 inComponent:3 animated:NO];
            }
            
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 8: {
            SettingsSectionTableViewCell *viewCell = (SettingsSectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsSectionTableViewCell"];
            viewCell.sectionLabel.text = @"DISTINCT GROUP CHANNEL";
            viewCell.topBorderView.hidden = NO;
            viewCell.bottomBorderView.hidden = NO;
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 9: {
            SettingsSwitchTableViewCell *viewCell = (SettingsSwitchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsSwitchTableViewCell"];
            viewCell.settingsLabel.text = @"Create Distinct Channel";
            viewCell.bottomBorderView.hidden = YES;
            viewCell.switchIdentifier = ID_CREATE_DISTINCT_CHANNEL;
            [viewCell.switchButton setOn:self.createDistinctChannel];
            viewCell.delegate = self;
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 10: {
            SettingsDescriptionTableViewCell *viewCell = (SettingsDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsDescriptionTableViewCell"];
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 11: {
            SettingsSectionTableViewCell *viewCell = (SettingsSectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsSectionTableViewCell"];
            viewCell.sectionLabel.text = @"BLOCKED USER LIST";
            viewCell.topBorderView.hidden = YES;
            viewCell.bottomBorderView.hidden = NO;
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 12: {
            SettingsGeneralTableViewCell *viewCell = (SettingsGeneralTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsGeneralTableViewCell"];
            viewCell.settingLabel.text = @"Blocked Users";
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 13: {
            SettingsSectionTableViewCell *viewCell = (SettingsSectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsSectionTableViewCell"];
            viewCell.sectionLabel.text = @"";
            viewCell.topBorderView.hidden = NO;
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 14: {
            SettingsSignOutTableViewCell *viewCell = (SettingsSignOutTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsSignOutTableViewCell"];
            cell = (UITableViewCell *)viewCell;
        }
            break;
        case 15: {
            SettingsVersionTableViewCell *viewCell = (SettingsVersionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SettingsVersionTableViewCell"];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
            if (path != nil) {
                NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
                NSString *sampleUIVersion = infoDict[@"CFBundleShortVersionString"];
                NSString *version = [NSString stringWithFormat:@"Sample UI v%@ / SDK v%@", sampleUIVersion, [SBDMain getSDKVersion]];
                viewCell.versionLabel.text = version;
            }
            else {
                viewCell.versionLabel.text = @"";
            }
            
            cell = (UITableViewCell *)viewCell;
        }
            break;
        default: {
            cell = [[UITableViewCell alloc] init];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return 20;
        case 1:
            return 81;
        case 2:
            return 56;
        case 3:
            return 44;
        case 4:
            if (self.isDoNotDisturbOn) {
                return 44;
            }
            else {
                return 0;
            }
        case 5:
            if (self.isDoNotDisturbOn && self.startTimeShown) {
                return 217;
            }
            else {
                return 0;
            }
        case 6:
            if (self.isDoNotDisturbOn) {
                return 44;
            }
            else {
                return 0;
            }
        case 7:
            if (self.isDoNotDisturbOn && self.endTimeShown) {
                return 217;
            }
            else {
                return 0;
            }
        case 8:
            return 50;
        case 9:
            return 44;
        case 10:
            return UITableViewAutomaticDimension;
        case 11:
            return 50;
        case 12:
            return 44;
        case 13:
            return 36;
        case 14:
            return 44;
        case 15:
            return 44;
        default:
            return UITableViewAutomaticDimension;
    }
}

#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        UpdateUserProfileViewController *vc = [[UpdateUserProfileViewController alloc] initWithNibName:@"UpdateUserProfileViewController" bundle:nil];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 4) {
        self.startTimeShown = !self.startTimeShown;
        self.endTimeShown = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
        if (!self.startTimeShown) {
            [self setDoNotDisturbTime];
        }
    }
    else if (indexPath.row == 6) {
        self.startTimeShown = NO;
        self.endTimeShown = !self.endTimeShown;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
        if (!self.endTimeShown) {
            [self setDoNotDisturbTime];
        }
    }
    else if (indexPath.row == 12) {
        SettingsBlockedUserListViewController *vc = [[SettingsBlockedUserListViewController alloc] initWithNibName:@"SettingsBlockedUserListViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 14) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Sign out" message:@"Do you want to sign out?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionConfirmSignOut = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SBDMain unregisterPushToken:[SBDMain getPendingPushToken] completionHandler:^(NSDictionary * _Nullable response, SBDError * _Nullable error) {
            }];

            [SBDMain disconnectWithCompletionHandler:^{
                [self dismissViewControllerAnimated:YES completion:^{
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sendbird_auto_login"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sendbird_dnd_start_hour"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sendbird_dnd_start_min"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sendbird_dnd_end_hour"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sendbird_dnd_end_min"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sendbird_dnd_on"];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                }];
            }];
        }];
        UIAlertAction *actionCancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }];

        [ac addAction:actionConfirmSignOut];
        [ac addAction:actionCancelAction];

        [self presentViewController:ac animated:YES completion:nil];
    }
    
}

#pragma mark - SettingsTableViewCellDelegate
- (void)didChangeSwitchButton:(BOOL)isOn identifier:(NSString *)identifier {
    NSLog(@"Timezone: %@", [NSTimeZone localTimeZone].name);
    if ([identifier isEqualToString:ID_DO_NOT_DISTURB]) {
        self.isDoNotDisturbOn = isOn;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadingIndicatorView.hidden = NO;
            [self.loadingIndicatorView startAnimating];
            
            [self.tableView reloadData];
            
            int startHour24 = [self.startAmPm isEqualToString:@"AM"] ? self.startHour : self.startHour + 12;
            int endHour24 = [self.endAmPm isEqualToString:@"AM"] ? self.endHour : self.endHour + 12;
            
            [[NSUserDefaults standardUserDefaults] setInteger:startHour24 forKey:@"sendbird_dnd_start_hour"];
            [[NSUserDefaults standardUserDefaults] setInteger:self.startMin forKey:@"sendbird_dnd_start_min"];
            [[NSUserDefaults standardUserDefaults] setInteger:endHour24 forKey:@"sendbird_dnd_end_hour"];
            [[NSUserDefaults standardUserDefaults] setInteger:self.endMin forKey:@"sendbird_dnd_end_min"];
            [[NSUserDefaults standardUserDefaults] setBool:self.isDoNotDisturbOn forKey:@"sendbird_dnd_on"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [SBDMain setDoNotDisturbWithEnable:isOn startHour:startHour24 startMin:self.startMin endHour:endHour24 endMin:self.endMin timezone:[NSTimeZone localTimeZone].name completionHandler:^(SBDError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.loadingIndicatorView.hidden = YES;
                    [self.loadingIndicatorView stopAnimating];
                });
                
                if (error != nil) {
                    return;
                }
                
                
            }];
            
            
        });
    }
    else if ([identifier isEqualToString:ID_SHOW_PREVIEWS]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(isOn) forKey:ID_SHOW_PREVIEWS];
        self.showPreview = isOn;
    }
    else if ([identifier isEqualToString:ID_CREATE_DISTINCT_CHANNEL]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(isOn) forKey:ID_CREATE_DISTINCT_CHANNEL];
        self.createDistinctChannel = isOn;
    }
}
- (void)setDoNotDisturbTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingIndicatorView.hidden = NO;
        [self.loadingIndicatorView startAnimating];
        
        int startHour24 = [self.startAmPm isEqualToString:@"AM"] ? self.startHour : self.startHour + 12;
        int endHour24 = [self.endAmPm isEqualToString:@"AM"] ? self.endHour : self.endHour + 12;
        
        [SBDMain setDoNotDisturbWithEnable:YES startHour:startHour24 startMin:self.startMin endHour:endHour24 endMin:self.endMin timezone:[NSTimeZone localTimeZone].name completionHandler:^(SBDError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loadingIndicatorView.hidden = YES;
                [self.loadingIndicatorView stopAnimating];
            });
            
            if (error != nil) {
                return;
            }
            
            [[NSUserDefaults standardUserDefaults] setInteger:startHour24 forKey:@"sendbird_dnd_start_hour"];
            [[NSUserDefaults standardUserDefaults] setInteger:self.startMin forKey:@"sendbird_dnd_start_min"];
            [[NSUserDefaults standardUserDefaults] setInteger:endHour24 forKey:@"sendbird_dnd_end_hour"];
            [[NSUserDefaults standardUserDefaults] setInteger:self.endMin forKey:@"sendbird_dnd_end_min"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sendbird_dnd_on"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    });
    
}

//#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//    return 1;
//}
//
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//    if (pickerView == self.hourPickerView) {
//        // Hour
//        return 24;
//    }
//    else {
//        // Minute
//        return 60;
//    }
//}
//
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    if (component == 0) {
//        return [NSString stringWithFormat:@"%ld", row];
//    }
//    else {
//        return [NSString stringWithFormat:@"%ld", row];
//    }
//    
//    return @"";
//}
//
#pragma mark - SettingsTimePickerDelegate
- (void)didSetTime:(NSString *)timeValue component:(NSInteger)component identifier:(NSString *)identifier {
    if ([identifier isEqualToString:@"START"]) {
        if (component == 1) {
            self.startHour = [timeValue intValue];
        }
        else if (component == 2) {
            self.startMin = [timeValue intValue];
        }
        else if (component == 3) {
            self.startAmPm = timeValue;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
    else if ([identifier isEqualToString:@"END"]) {
        if (component == 1) {
            self.endHour = [timeValue intValue];
        }
        else if (component == 2) {
            self.endMin = [timeValue intValue];
        }
        else if (component == 3) {
            self.endAmPm = timeValue;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

#pragma mark - UserProfileImageNameSettingDelegate
- (void)didUpdateUserProfile {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
