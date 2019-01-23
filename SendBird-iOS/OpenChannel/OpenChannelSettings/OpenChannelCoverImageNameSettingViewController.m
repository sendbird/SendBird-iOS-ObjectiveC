//
//  OpenChannelCoverImageNameSettingViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 4/8/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "OpenChannelCoverImageNameSettingViewController.h"
#import "Utils.h"
#import "CustomActivityIndicatorView.h"

#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIViewController+Utils.h"
#import "OpenChannelSettingsViewController.h"

@interface OpenChannelCoverImageNameSettingViewController ()

@property (weak, nonatomic) IBOutlet UITextField *channelNameTextField;

@property (weak, nonatomic) IBOutlet UIView *coverImageContainerView;

@property (weak, nonatomic) IBOutlet UIView *singleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *singleCoverImageView;
@property (weak, nonatomic) IBOutlet CustomActivityIndicatorView *loadingIndicatorView;

@property (strong) UIImage *channelCoverImage;


@end

@implementation OpenChannelCoverImageNameSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Cover Image & Name";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    UIBarButtonItem *barButtonItemDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(clickDoneButton:)];
    self.navigationItem.rightBarButtonItem = barButtonItemDone;
    
    self.channelCoverImage = nil;
    self.loadingIndicatorView.hidden = YES;
    [self.view bringSubviewToFront:self.loadingIndicatorView];

    self.channelNameTextField.text = self.channel.name;
    self.channelNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Channel Name" attributes:@{
                                                                                                                                     NSFontAttributeName : [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular],
                                                                                                                                     NSForegroundColorAttributeName: [UIColor colorNamed:@"color_channelname_nickname_placeholder"],
                                                                                                                                     }];
    
    [self.coverImageContainerView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapCoverImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCoverImage)];
    [self.coverImageContainerView addGestureRecognizer:tapCoverImageGesture];
    self.singleCoverImageContainerView.hidden = NO;
    [self.singleCoverImageView setImageWithURL:[NSURL URLWithString:self.channel.coverUrl] placeholderImage:[UIImage imageNamed:@"img_default_profile_image_1"]];
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
    [self updateChannelInfo];
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
    if ([cvc isKindOfClass:[OpenChannelSettingsViewController class]]) {
        [((OpenChannelSettingsViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __weak OpenChannelCoverImageNameSettingViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        OpenChannelCoverImageNameSettingViewController *strongSelf = weakSelf;
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
    self.channelCoverImage = croppedImage;
    
    self.singleCoverImageView.image = croppedImage;
    self.singleCoverImageContainerView.hidden = NO;
    
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle {
    self.channelCoverImage = croppedImage;
    
    self.singleCoverImageView.image = croppedImage;
    self.singleCoverImageContainerView.hidden = NO;
    
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage {
    // Use when `applyMaskToCroppedImage` set to YES.
}

- (void)clickCoverImage {
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

- (void)updateChannelInfo {
    NSData *imageData = UIImageJPEGRepresentation(self.channelCoverImage, 0.5);
    self.loadingIndicatorView.hidden = NO;
    [self.loadingIndicatorView startAnimating];
    [self.channel updateChannelWithName:self.channelNameTextField.text coverImage:imageData coverImageName:@"image.jpg" data:nil operatorUserIds:nil customType:nil progressHandler:nil completionHandler:^(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadingIndicatorView.hidden = YES;
            [self.loadingIndicatorView stopAnimating];
        });

        [self.delegate didUpdateOpenChannel];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
