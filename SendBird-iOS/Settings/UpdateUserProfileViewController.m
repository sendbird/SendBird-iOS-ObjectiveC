//
//  UpdateUserProfileViewController.m
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/3/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import "UpdateUserProfileViewController.h"
#import "Utils.h"
#import "CustomActivityIndicatorView.h"

#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIViewController+Utils.h"
#import "SettingsViewController.h"

@interface UpdateUserProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet CustomActivityIndicatorView *loadingIndicatorView;

@property (strong) UIImage *profileImage;

@end

@implementation UpdateUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Profile Image & Name";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    UIBarButtonItem *barButtonItemDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(clickDoneButton:)];
    self.navigationItem.rightBarButtonItem = barButtonItemDone;
    
    self.loadingIndicatorView.hidden = YES;
    [self.view bringSubviewToFront:self.loadingIndicatorView];
    
    [self.profileImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapProfileImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProfileImage)];
    [self.profileImageView addGestureRecognizer:tapProfileImageGesture];
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:[SBDMain getCurrentUser]]] placeholderImage:[Utils getDefaultUserProfileImage:[SBDMain getCurrentUser]]];
    
    self.nicknameTextField.text = [SBDMain getCurrentUser].nickname;
    self.nicknameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Please write your nickname" attributes:@{
                                                                                                                                         NSFontAttributeName : [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular],
                                                                                                                                         NSForegroundColorAttributeName: [UIColor colorNamed:@"color_channelname_nickname_placeholder"],
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

- (void)clickDoneButton:(id)sender {
    [self updateUserProfile];
}

- (void)cropImage:(NSData *)imageData {
    UIImage *image = [UIImage imageWithData:imageData];
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image];
    imageCropVC.delegate = self;
    imageCropVC.cropMode = RSKImageCropModeSquare;
    [self presentViewController:imageCropVC animated:NO completion:nil];
}

#pragma mark - NotificationDelegate
- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self.navigationController popViewControllerAnimated:NO];
    UIViewController *cvc = [UIViewController currentViewController];
    if ([cvc isKindOfClass:[SettingsViewController class]]) {
        [((SettingsViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __weak UpdateUserProfileViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        UpdateUserProfileViewController *strongSelf = weakSelf;
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            UIImage *originalImage;
            originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
            if (originalImage != nil) {
                NSData *imageData = UIImageJPEGRepresentation(originalImage, 1.0);
                
                [strongSelf cropImage:imageData];
            }
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
    self.profileImage = croppedImage;
    
    self.profileImageView.image = croppedImage;
    
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle {
    self.profileImage = croppedImage;
    
    self.profileImageView.image = croppedImage;
    
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage {
    // Use when `applyMaskToCroppedImage` set to YES.
}

- (void)clickProfileImage {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
            mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
            mediaUI.mediaTypes = mediaTypes;
            [mediaUI setDelegate:self];
            [self presentViewController:mediaUI animated:YES completion:nil];
        });
    }];
    
    UIAlertAction *chooseFromLibraryAction = [UIAlertAction actionWithTitle:@"Choose from Library..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
            mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
            mediaUI.mediaTypes = mediaTypes;
            [mediaUI setDelegate:self];
            [self presentViewController:mediaUI animated:YES completion:nil];
        });
    }];
    
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    
    [vc addAction:takePhotoAction];
    [vc addAction:chooseFromLibraryAction];
    [vc addAction:closeAction];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)updateUserProfile {
    NSData *imageData = UIImageJPEGRepresentation(self.profileImage, 0.5);
    self.loadingIndicatorView.hidden = NO;
    [self.loadingIndicatorView startAnimating];
    [SBDMain updateCurrentUserInfoWithNickname:self.nicknameTextField.text profileImage:imageData completionHandler:^(SBDError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadingIndicatorView.hidden = YES;
            [self.loadingIndicatorView stopAnimating];
        });
        
        [[NSUserDefaults standardUserDefaults] setObject:[SBDMain getCurrentUser].nickname forKey:@"sendbird_user_nickname"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.delegate didUpdateUserProfile];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
