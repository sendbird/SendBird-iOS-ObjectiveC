//
//  OpenChannelSettingsViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 2/7/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "OpenChannelSettingsViewController.h"
#import <Photos/Photos.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utils.h"

#import "OpenChannelParticipantListViewController.h"
#import "OpenChannelBannedUserListViewController.h"
#import "OpenChannelMutedUserListViewController.h"
#import "UserProfileViewController.h"
#import "UIViewController+Utils.h"
#import "OpenChannelChatViewController.h"

#define OPERATOR_MENU_COUNT 7
#define REGULAR_PARTICIPANT_MENU_COUNT 4

@interface OpenChannelSettingsViewController ()

@property (strong) NSMutableArray<SBDUser *> *operators;
@property (strong) NSMutableDictionary<NSString *, SBDUser *> *selectedUsers;

@end

@implementation OpenChannelSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Open Channel Settings";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    [SBDMain addChannelDelegate:self identifier:self.description];
    
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"OpenChannelSettingsChannelNameTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelSettingsChannelNameTableViewCell"];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"OpenChannelSettingsSeperatorTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelSettingsSeperatorTableViewCell"];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"OpenChannelSettingsMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelSettingsMenuTableViewCell"];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"OpenChannelSettingsMeTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelSettingsMeTableViewCell"];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"OpenChannelSettingsOperatorTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelSettingsOperatorTableViewCell"];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"OpenChannelOperatorSectionTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelOperatorSectionTableViewCell"];
    
    self.loadingIndicatorView.hidden = YES;
    [self.view bringSubviewToFront:self.loadingIndicatorView];

    [self refreshOperators];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didUpdateOpenChannel)]) {
            [self.delegate didUpdateOpenChannel];
        }
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark - NotificationDelegate
- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self.navigationController popViewControllerAnimated:NO];
    UIViewController *cvc = [UIViewController currentViewController];
    if ([cvc isKindOfClass:[OpenChannelChatViewController class]]) {
        [((OpenChannelChatViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}

- (void)clickSettingsMenuTableView {
    OpenChannelSettingsChannelNameTableViewCell *channelNameCell = [self.settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [channelNameCell.channelNameTextField resignFirstResponder];
    channelNameCell.channelNameTextField.enabled = NO;
    channelNameCell.channelNameTextField.text = self.channel.name;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.channel isOperatorWithUser:[SBDMain getCurrentUser]]) {
        return self.operators.count + OPERATOR_MENU_COUNT;
    }
    else {
        return self.operators.count + REGULAR_PARTICIPANT_MENU_COUNT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        OpenChannelSettingsChannelNameTableViewCell *channelNameCell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelSettingsChannelNameTableViewCell" forIndexPath:indexPath];
        channelNameCell.delegate = self;
        channelNameCell.channelNameTextField.text = self.channel.name;
        [channelNameCell setEnableEditing:[self.channel isOperatorWithUser:[SBDMain getCurrentUser]]];
        
        [channelNameCell.channelCoverImageView setImageWithURL:[NSURL URLWithString:self.channel.coverUrl] placeholderImage:[UIImage imageNamed:@"img_cover_image_placeholder_1"]];
        cell = (UITableViewCell *)channelNameCell;
    }
    else if (indexPath.row == 1) {
        OpenChannelSettingsSeperatorTableViewCell *seperatorCell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelSettingsSeperatorTableViewCell" forIndexPath:indexPath];
        seperatorCell.bottomBorderLineView.hidden = NO;
        cell = (UITableViewCell *)seperatorCell;
    }
    else if (indexPath.row == 2) {
        OpenChannelSettingsMenuTableViewCell *participantCell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelSettingsMenuTableViewCell" forIndexPath:indexPath];
        
        participantCell.settingMenuLabel.text = @"Participants";
        [participantCell.settingMenuIconImageView setImage:[UIImage imageNamed:@"img_icon_participant"]];
        participantCell.countLabel.text = [NSString stringWithFormat:@"%ld", self.channel.participantCount];
        cell = (UITableViewCell *)participantCell;
        
        if ([self.channel isOperatorWithUser:[SBDMain getCurrentUser]]) {
            participantCell.dividerView.hidden = NO;
        }
        else {
            participantCell.dividerView.hidden = YES;
        }
    }
    else {
        if ([self.channel isOperatorWithUser:[SBDMain getCurrentUser]]) {
            if (indexPath.row == 3) {
                OpenChannelSettingsMenuTableViewCell *muteCell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelSettingsMenuTableViewCell" forIndexPath:indexPath];
                muteCell.dividerView.hidden = NO;
                muteCell.settingMenuLabel.text = @"Muted Users";
                [muteCell.settingMenuIconImageView setImage:[UIImage imageNamed:@"img_icon_mute"]];
                muteCell.countLabel.hidden = YES;
                cell = (UITableViewCell *)muteCell;
            }
            else if (indexPath.row == 4) {
                OpenChannelSettingsMenuTableViewCell *banCell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelSettingsMenuTableViewCell" forIndexPath:indexPath];
                banCell.dividerView.hidden = YES;
                banCell.settingMenuLabel.text = @"Banned Users";
                [banCell.settingMenuIconImageView setImage:[UIImage imageNamed:@"img_icon_ban"]];
                banCell.countLabel.hidden = YES;
                cell = (UITableViewCell *)banCell;
            }
            else if (indexPath.row == 5) {
                OpenChannelOperatorSectionTableViewCell *seperatorCell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelOperatorSectionTableViewCell" forIndexPath:indexPath];
                cell = (UITableViewCell *)seperatorCell;
            }
            else if (indexPath.row == 6) {
                OpenChannelSettingsMenuTableViewCell *addOperatorCell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelSettingsMenuTableViewCell" forIndexPath:indexPath];
                addOperatorCell.dividerView.hidden = YES;
                addOperatorCell.settingMenuLabel.text = @"Add an operator";
                addOperatorCell.settingMenuLabel.textColor = [UIColor colorNamed:@"color_settings_menu_add_operator"];
                [addOperatorCell.settingMenuIconImageView setImage:[UIImage imageNamed:@"img_icon_add_operator"]];
                addOperatorCell.accessoryType = UITableViewCellAccessoryNone;
                addOperatorCell.countLabel.hidden = YES;
                cell = (UITableViewCell *)addOperatorCell;
            }
            else {
                NSInteger opIndex = indexPath.row - OPERATOR_MENU_COUNT;
                if ([self.operators[opIndex].userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                    OpenChannelSettingsMeTableViewCell *meOperatorCell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelSettingsMeTableViewCell" forIndexPath:indexPath];
                    meOperatorCell.nicknameLabel.text = self.operators[opIndex].nickname;
                    [meOperatorCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.operators[opIndex]]] placeholderImage:[Utils getDefaultUserProfileImage:self.operators[opIndex]]];
                    
                    if (self.operators.count == 1) {
                        meOperatorCell.bottomBorderView.hidden = NO;
                    }
                    else {
                        meOperatorCell.bottomBorderView.hidden = YES;
                    }
                    
                    cell = (UITableViewCell *)meOperatorCell;
                }
                else {
                    OpenChannelSettingsOperatorTableViewCell *operatorCell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelSettingsOperatorTableViewCell" forIndexPath:indexPath];
                    operatorCell.user = self.operators[opIndex];
                    operatorCell.nicknameLabel.text = self.operators[opIndex].nickname;
                    [operatorCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.operators[opIndex]]] placeholderImage:[Utils getDefaultUserProfileImage:self.operators[opIndex]]];
                    operatorCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    cell = (UITableViewCell *)operatorCell;
                    
                    if (self.channel.operators.count - 1 == opIndex) {
                        operatorCell.dividerView.hidden = YES;
                        operatorCell.bottomBorderView.hidden = NO;
                    }
                    else {
                        operatorCell.dividerView.hidden = NO;
                        operatorCell.bottomBorderView.hidden = YES;
                    }
                    
                    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
                    [cell addGestureRecognizer:longPressGesture];
                }
            }
        }
        else {
            if (indexPath.row >= 3) {
                if (self.channel.operators != nil && self.channel.operators.count > 0) {
                    if (indexPath.row == 3) {
                        OpenChannelOperatorSectionTableViewCell *seperatorCell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelOperatorSectionTableViewCell" forIndexPath:indexPath];
                        cell = (UITableViewCell *)seperatorCell;
                    }
                    else {
                        OpenChannelSettingsOperatorTableViewCell *operatorCell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelSettingsOperatorTableViewCell" forIndexPath:indexPath];
                        operatorCell.nicknameLabel.text = self.channel.operators[indexPath.row - REGULAR_PARTICIPANT_MENU_COUNT].nickname;
                        [operatorCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.operators[indexPath.row - REGULAR_PARTICIPANT_MENU_COUNT]]] placeholderImage:[Utils getDefaultUserProfileImage:self.operators[indexPath.row - REGULAR_PARTICIPANT_MENU_COUNT]]];
                        operatorCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                        if (self.channel.operators.count - 1 == indexPath.row - REGULAR_PARTICIPANT_MENU_COUNT) {
                            operatorCell.dividerView.hidden = YES;
                            operatorCell.bottomBorderView.hidden = NO;
                        }
                        else {
                            operatorCell.dividerView.hidden = NO;
                            operatorCell.bottomBorderView.hidden = YES;
                        }
                        
                        cell = (UITableViewCell *)operatorCell;
                    }
                }
                else {
                    OpenChannelSettingsSeperatorTableViewCell *seperatorCell = [tableView dequeueReusableCellWithIdentifier:@"OpenChannelSettingsSeperatorTableViewCell" forIndexPath:indexPath];
                    seperatorCell.bottomBorderLineView.hidden = YES;
                    cell = (UITableViewCell *)seperatorCell;
                }
            }

        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (indexPath.row == 0) {
        return 121;
    }
    else if (indexPath.row == 1) {
        return 35;
    }
    else if (indexPath.row == 2) {
        return 44;
    }
    else {
        if ([self.channel isOperatorWithUser:[SBDMain getCurrentUser]]) {
            if (indexPath.row == 3) {
                return 44;
            }
            else if (indexPath.row == 4) {
                return 44;
            }
            else if (indexPath.row == 5) {
                return 56;
            }
            else if (indexPath.row == 6) {
                return 44;
            }
            else {
                return 48;
            }
        }
        else {
            if (indexPath.row == 3) {
                return 56;
            }
            else {
                return 48;
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self clickSettingsMenuTableView];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 2) {
        // Participant
        OpenChannelParticipantListViewController *vc = [[OpenChannelParticipantListViewController alloc] initWithNibName:@"OpenChannelParticipantListViewController" bundle:nil];
        vc.channel = self.channel;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        if ([self.channel isOperatorWithUser:[SBDMain getCurrentUser]]) {
            if (indexPath.row == 3) {
                // Mute
                OpenChannelMutedUserListViewController *vc = [[OpenChannelMutedUserListViewController alloc] initWithNibName:@"OpenChannelMutedUserListViewController" bundle:nil];
                vc.channel = self.channel;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if (indexPath.row == 4) {
                // Ban
                OpenChannelBannedUserListViewController *vc = [[OpenChannelBannedUserListViewController alloc] initWithNibName:@"OpenChannelBannedUserListViewController" bundle:nil];
                vc.channel = self.channel;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if (indexPath.row == 6) {
                // Add Operators
                SelectOperatorsViewController *vc = [[SelectOperatorsViewController alloc] initWithNibName:@"SelectOperatorsViewController" bundle:nil];
                vc.title = @"Add an operator";
                vc.selectedUsers = [[NSMutableDictionary alloc] init];
                vc.delegate = self;
                for (SBDUser *user in self.channel.operators) {
                    vc.selectedUsers[user.userId] = user;
                }
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if (indexPath.row - OPERATOR_MENU_COUNT > 0) {
                UserProfileViewController *vc = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
                vc.user = self.operators[indexPath.row - OPERATOR_MENU_COUNT];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else {
            if (indexPath.row - REGULAR_PARTICIPANT_MENU_COUNT >= 0) {
                UserProfileViewController *vc = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
                vc.user = self.channel.operators[indexPath.row - REGULAR_PARTICIPANT_MENU_COUNT];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.loadingIndicatorView.hidden = NO;
    [self.loadingIndicatorView startAnimating];
    [self.channel updateChannelWithName:textField.text coverImage:nil coverImageName:nil data:nil operatorUserIds:nil customType:nil progressHandler:nil completionHandler:^(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error) {
        if (error != nil) {
            self.loadingIndicatorView.hidden = YES;
            [self.loadingIndicatorView stopAnimating];
            
            return;
        }
        
        self.loadingIndicatorView.hidden = YES;
        [self.loadingIndicatorView stopAnimating];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.settingsTableView reloadData];
        });
    }];
    
    return YES;
}

#pragma mark - OpenChannelSettingsChannelNameTableViewCellDelegate
- (void)didClickChannelCoverImageNameEdit {
    OpenChannelCoverImageNameSettingViewController *vc = [[OpenChannelCoverImageNameSettingViewController alloc] initWithNibName:@"OpenChannelCoverImageNameSettingViewController" bundle:nil];
    vc.delegate = self;
    vc.channel = self.channel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Crop Image
- (void)cropImage:(NSData *)imageData {
    UIImage *image = [UIImage imageWithData:imageData];
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image];
    imageCropVC.delegate = self;
    imageCropVC.cropMode = RSKImageCropModeSquare;
    [self presentViewController:imageCropVC animated:NO completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __weak OpenChannelSettingsViewController *weakSelf = self;
    NSDictionary *pickerInfo = info;
    [picker dismissViewControllerAnimated:YES completion:^{
        OpenChannelSettingsViewController *strongSelf = weakSelf;
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            PHAsset *imageAsset = [info objectForKey:UIImagePickerControllerPHAsset];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            options.networkAccessAllowed = YES;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)dataUTI, kUTTagClassMIMEType);
                
                NSString *filename = @"";
                if ([info objectForKey:@"PHImageFileURLKey"]) {
                    NSURL *fileurl = [info objectForKey:@"PHImageFileURLKey"];
                    filename = [fileurl lastPathComponent];
                }
                else {
                    UIImage *originalImage = (UIImage *)[pickerInfo objectForKey:UIImagePickerControllerOriginalImage];
                    imageData = UIImageJPEGRepresentation(originalImage, 1.0);
                    filename = @"image.jpg";
                    mimeType = @"image/jpeg";
                }
                
                if (!imageData) {
                    // fail
                } else {
                    // success, data is in imageData
                    [strongSelf cropImage:imageData];
                }
            }];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - RSKImageCropViewControllerDelegate
// Crop image has been canceled.
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller {
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect {
    [self updateChannelCoverImage:croppedImage imageCropImageController:controller];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle {
    [self updateChannelCoverImage:croppedImage imageCropImageController:controller];
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage {
    // Use when `applyMaskToCroppedImage` set to YES.
}

- (void)updateChannelCoverImage:(UIImage *)croppedImage imageCropImageController:(RSKImageCropViewController *)controller {
    NSData *coverImageData = UIImageJPEGRepresentation(croppedImage, 0.5);
    
    self.loadingIndicatorView.hidden = NO;
    [self.loadingIndicatorView startAnimating];
    [self.channel updateChannelWithName:nil coverImage:coverImageData coverImageName:@"image.jpg" data:nil operatorUserIds:nil customType:nil progressHandler:nil completionHandler:^(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error) {
        if (error != nil) {
            self.loadingIndicatorView.hidden = YES;
            [self.loadingIndicatorView stopAnimating];
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadingIndicatorView.hidden = YES;
            [self.loadingIndicatorView stopAnimating];
            
            [self.settingsTableView reloadData];
        });
    }];
    [controller dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - SelectOperatorsDelegate
- (void)didSelectUsers:(NSMutableDictionary<NSString *,SBDUser *> *)users {
    self.loadingIndicatorView.hidden = NO;
    [self.loadingIndicatorView startAnimating];
    NSMutableArray<SBDUser *> *operators = [[NSMutableArray alloc] initWithArray:[users allValues]];
    [operators addObject:[SBDMain getCurrentUser]];
    [self.channel updateChannelWithName:nil coverUrl:nil data:nil operatorUsers:operators completionHandler:^(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error) {
        if (error != nil) {
            self.loadingIndicatorView.hidden = YES;
            [self.loadingIndicatorView stopAnimating];
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadingIndicatorView.hidden = YES;
            [self.loadingIndicatorView stopAnimating];
            [self.operators removeAllObjects];
            for (SBDUser *op in self.channel.operators) {
                if ([op.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                    [self.operators insertObject:op atIndex:0];
                }
                else {
                    [self.operators addObject:op];
                }
            }
            
            [self.settingsTableView reloadData];
        });
    }];
}

#pragma mark - UIAlertController for operators
- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UITableViewCell *cell = (UITableViewCell *)recognizer.view;
        if ([cell isKindOfClass:[OpenChannelSettingsOperatorTableViewCell class]]) {
            OpenChannelSettingsOperatorTableViewCell *operatorCell = (OpenChannelSettingsOperatorTableViewCell *)cell;
            SBDUser *removedOperator = operatorCell.user;
            NSMutableArray<SBDUser *> *operators = [[NSMutableArray alloc] init];
            for (SBDUser *user in self.channel.operators) {
                if ([user.userId isEqualToString:removedOperator.userId]) {
                    continue;
                }
                
                [operators addObject:user];
            }
            
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:removedOperator.nickname message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *actionRemoveUser = [UIAlertAction actionWithTitle:@"Remove from operators" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                self.loadingIndicatorView.hidden = NO;
                [self.loadingIndicatorView startAnimating];
                
                [self.channel updateChannelWithName:nil coverUrl:nil data:nil operatorUsers:operators completionHandler:^(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error) {
                    if (error != nil) {
                        self.loadingIndicatorView.hidden = YES;
                        [self.loadingIndicatorView stopAnimating];
                        
                        return;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.loadingIndicatorView.hidden = YES;
                        [self.loadingIndicatorView stopAnimating];
                        [self.operators removeAllObjects];
                        for (SBDUser *op in self.channel.operators) {
                            if ([op.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                                [self.operators insertObject:op atIndex:0];
                            }
                            else {
                                [self.operators addObject:op];
                            }
                        }
                        [self.settingsTableView reloadData];
                    });
                }];
            }];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [vc addAction:actionRemoveUser];
            [vc addAction:actionCancel];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
        }
    }
}

- (void)refreshOperators {
    self.operators = [[NSMutableArray alloc] init];
    
    for (SBDUser *op in self.channel.operators) {
        if ([op.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            [self.operators insertObject:op atIndex:0];
        }
        else {
            [self.operators addObject:op];
        }
    }
}

#pragma mark - OpenChannelCoverImageNameSettingDelegate
- (void)didUpdateOpenChannel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.settingsTableView reloadData];
    });
}

#pragma mark - SBDChannelDelegate
- (void)channel:(SBDOpenChannel *)sender userDidExit:(SBDUser *)user {
    if (sender == self.channel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.settingsTableView reloadData];
        });
    }
}

- (void)channel:(SBDBaseChannel *)sender userWasBanned:(SBDUser *)user {
    if (sender == self.channel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.settingsTableView reloadData];
        });
    }
}

- (void)channel:(SBDOpenChannel *)sender userDidEnter:(SBDUser *)user {
    if (sender == self.channel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.settingsTableView reloadData];
        });
    }
}

- (void)channelWasChanged:(SBDBaseChannel *)sender {
    if (sender == self.channel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshOperators];
            [self.settingsTableView reloadData];
        });
    }
}

@end
