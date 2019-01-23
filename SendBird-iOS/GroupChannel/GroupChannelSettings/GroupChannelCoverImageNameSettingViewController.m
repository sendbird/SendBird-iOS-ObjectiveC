//
//  GroupChannelCoverImageNameSettingViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 4/2/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelCoverImageNameSettingViewController.h"
#import "Utils.h"
#import "CustomActivityIndicatorView.h"

#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIViewController+Utils.h"
#import "GroupChannelSettingsViewController.h"

@interface GroupChannelCoverImageNameSettingViewController ()

@property (strong) UIImage *coverImage;

@property (weak, nonatomic) IBOutlet CustomActivityIndicatorView *loadingIndicatorView;

@property (weak, nonatomic) IBOutlet UITextField *channelNameTextField;

@property (weak, nonatomic) IBOutlet UIView *coverImageContainerView;

@property (weak, nonatomic) IBOutlet UIView *singleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *singleCoverImageView;

@property (weak, nonatomic) IBOutlet UIView *doubleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *doubleCoverImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *doubleCoverImageView2;

@property (weak, nonatomic) IBOutlet UIView *tripleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *tripleCoverImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *tripleCoverImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *tripleCoverImageView3;

@property (weak, nonatomic) IBOutlet UIView *quadrupleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *quadrupleCoverImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *quadrupleCoverImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *quadrupleCoverImageView3;
@property (weak, nonatomic) IBOutlet UIImageView *quadrupleCoverImageView4;

@end

@implementation GroupChannelCoverImageNameSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Cover Image & Name";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    UIBarButtonItem *barButtonItemDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(clickDoneButton:)];
    self.navigationItem.rightBarButtonItem = barButtonItemDone;
    
    [self.view bringSubviewToFront:self.loadingIndicatorView];
    self.loadingIndicatorView.hidden = YES;
    
    self.coverImage = nil;
    self.channelNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[Utils createGroupChannelNameFromMembers:self.channel] attributes:@{
                                                                                                                                         NSFontAttributeName : [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular],
                                                                                                                                         NSForegroundColorAttributeName: [UIColor colorNamed:@"color_channelname_nickname_placeholder"],
                                                                                                                                         }];
    self.channelNameTextField.text = self.channel.name;
    
    [self.coverImageContainerView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapCoverImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCoverImage)];
    [self.coverImageContainerView addGestureRecognizer:tapCoverImageGesture];
    
    self.singleCoverImageContainerView.hidden = YES;
    self.doubleCoverImageContainerView.hidden = YES;
    self.tripleCoverImageContainerView.hidden = YES;
    self.quadrupleCoverImageContainerView.hidden = YES;
    NSMutableArray<SBDMember *> *currentMembers = [[NSMutableArray alloc] init];
    int count = 0;
    for (SBDMember *member in self.channel.members) {
        if ([member.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            continue;
        }
        [currentMembers addObject:member];
        count += 1;
        if (count == 4) {
            break;
        }
    }
    
    if (self.channel.coverUrl.length > 0 && ![self.channel.coverUrl hasPrefix:@"https://sendbird.com/main/img/cover/"]) {
        self.singleCoverImageContainerView.hidden = NO;
        [self.singleCoverImageView setImageWithURL:[NSURL URLWithString:self.channel.coverUrl] placeholderImage:[UIImage imageNamed:@"img_default_profile_image_1"]];
    }
    else {
        if (currentMembers != nil) {
            if (currentMembers.count == 0) {
                self.singleCoverImageContainerView.hidden = NO;
                [self.singleCoverImageView setImage:[UIImage imageNamed:@"img_default_profile_image_1"]];
            }
            else if (currentMembers.count == 1) {
                self.singleCoverImageContainerView.hidden = NO;
                [self.singleCoverImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[0]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[0]]];
            }
            else if (currentMembers.count == 2) {
                self.doubleCoverImageContainerView.hidden = NO;
                [self.doubleCoverImageView1 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[0]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[0]]];
                [self.doubleCoverImageView2 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[1]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[1]]];
            }
            else if (currentMembers.count == 3) {
                self.tripleCoverImageContainerView.hidden = NO;
                [self.tripleCoverImageView1 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[0]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[0]]];
                [self.tripleCoverImageView2 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[1]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[1]]];
                [self.tripleCoverImageView3 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[2]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[2]]];
            }
            else if (currentMembers.count >= 4) {
                self.quadrupleCoverImageContainerView.hidden = NO;
                [self.quadrupleCoverImageView1 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[0]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[0]]];
                [self.quadrupleCoverImageView2 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[1]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[1]]];
                [self.quadrupleCoverImageView3 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[2]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[2]]];
                [self.quadrupleCoverImageView4 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:currentMembers[3]]] placeholderImage:[Utils getDefaultUserProfileImage:currentMembers[3]]];
            }
        }
    }
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
    if ([cvc isKindOfClass:[GroupChannelSettingsViewController class]]) {
        [((GroupChannelSettingsViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __weak GroupChannelCoverImageNameSettingViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        GroupChannelCoverImageNameSettingViewController *strongSelf = weakSelf;
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
    self.coverImage = croppedImage;
    
    self.singleCoverImageView.image = croppedImage;
    self.singleCoverImageContainerView.hidden = NO;
    self.doubleCoverImageContainerView.hidden = YES;
    self.tripleCoverImageContainerView.hidden = YES;
    self.quadrupleCoverImageContainerView.hidden = YES;
    
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle {
    self.coverImage = croppedImage;
    
    self.singleCoverImageView.image = croppedImage;
    self.singleCoverImageContainerView.hidden = NO;
    self.doubleCoverImageContainerView.hidden = YES;
    self.tripleCoverImageContainerView.hidden = YES;
    self.quadrupleCoverImageContainerView.hidden = YES;
    
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
    self.loadingIndicatorView.hidden = NO;
    [self.loadingIndicatorView startAnimating];
    
    SBDGroupChannelParams *params = [[SBDGroupChannelParams alloc] init];
    if (self.coverImage != nil) {
        params.coverImage = UIImageJPEGRepresentation(self.coverImage, 0.5);
    }
    else {
        params.coverUrl = self.channel.coverUrl;
    }
    
    params.name = self.channelNameTextField.text;
    
    [self.channel updateChannelWithParams:params completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
        self.loadingIndicatorView.hidden = YES;
        [self.loadingIndicatorView stopAnimating];
        
        if (error != nil) {
            [Utils showAlertControllerWithError:error viewController:self];
            return;
        }
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector
                                     (didUpdateGroupChannel)]) {
            [self.delegate didUpdateGroupChannel];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
