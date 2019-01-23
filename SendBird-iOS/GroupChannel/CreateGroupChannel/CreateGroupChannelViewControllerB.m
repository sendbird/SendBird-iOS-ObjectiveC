//
//  CreateGroupChannelViewControllerB.m
//  SendBird-iOS
//
//  Created by SendBird on 2/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "CreateGroupChannelViewControllerB.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>
#import <Photos/Photos.h>
#import "CustomActivityIndicatorView.h"
#import "GroupChannelChatViewController.h"
#import "CreateGroupChannelNavigationController.h"
#import "Constants.h"
#import "Utils.h"
#import "UIViewController+Utils.h"
#import "CreateGroupChannelViewControllerA.h"

@interface CreateGroupChannelViewControllerB ()

@property (weak, nonatomic) IBOutlet UIView *coverImageContainerView;
@property (weak, nonatomic) IBOutlet UITextField *channelNameTextField;

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

@property (weak, nonatomic) IBOutlet CustomActivityIndicatorView *loadingIndicatorView;

@property (strong) NSData *coverImageData;

@property (strong) UIBarButtonItem *createButtonItem;

@end

@implementation CreateGroupChannelViewControllerB

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Create Group Channel";
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    self.createButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStyleDone target:self action:@selector(clickCreateGroupChannel:)];
    self.navigationItem.rightBarButtonItem = self.createButtonItem;
    
    self.coverImageData = nil;
    [self.view bringSubviewToFront:self.loadingIndicatorView];
    self.loadingIndicatorView.hidden = YES;

    NSMutableArray<NSString *> *memberNicknames = [[NSMutableArray alloc] init];
    int memberCount = 0;
    for (SBDUser *user in self.members) {
        [memberNicknames addObject:user.nickname];
        memberCount += 1;
        if (memberCount == 4) {
            break;
        }
    }
    
    NSString *channelNamePlaceholder = [memberNicknames componentsJoinedByString:@", "];
    self.channelNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:channelNamePlaceholder attributes:@{
                                                                                                                                                                     NSFontAttributeName : [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular],
                                                                                                                                                                     NSForegroundColorAttributeName: [UIColor colorNamed:@"color_channelname_nickname_placeholder"],
                                                                                                                                                                     }];
    
    [self.coverImageContainerView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapCoverImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCoverImage:)];
    [self.coverImageContainerView addGestureRecognizer:tapCoverImageGesture];
    
    self.singleCoverImageContainerView.hidden = YES;
    self.doubleCoverImageContainerView.hidden = YES;
    self.tripleCoverImageContainerView.hidden = YES;
    self.quadrupleCoverImageContainerView.hidden = YES;
    
    if (self.members != nil) {
        if (self.members.count == 1) {
            self.singleCoverImageContainerView.hidden = NO;
            [self.singleCoverImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.members[0]]] placeholderImage:[Utils getDefaultUserProfileImage:self.members[0]]];
        }
        else if (self.members.count == 2) {
            self.doubleCoverImageContainerView.hidden = NO;
            [self.doubleCoverImageView1 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.members[0]]] placeholderImage:[Utils getDefaultUserProfileImage:self.members[0]]];
            [self.doubleCoverImageView2 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.members[1]]] placeholderImage:[Utils getDefaultUserProfileImage:self.members[1]]];
        }
        else if (self.members.count == 3) {
            self.tripleCoverImageContainerView.hidden = NO;
            [self.tripleCoverImageView1 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.members[0]]] placeholderImage:[Utils getDefaultUserProfileImage:self.members[0]]];
            [self.tripleCoverImageView2 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.members[1]]] placeholderImage:[Utils getDefaultUserProfileImage:self.members[1]]];
            [self.tripleCoverImageView3 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.members[2]]] placeholderImage:[Utils getDefaultUserProfileImage:self.members[2]]];
        }
        else if (self.members.count >= 4) {
            self.quadrupleCoverImageContainerView.hidden = NO;
            [self.quadrupleCoverImageView1 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.members[0]]] placeholderImage:[Utils getDefaultUserProfileImage:self.members[0]]];
            [self.quadrupleCoverImageView2 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.members[1]]] placeholderImage:[Utils getDefaultUserProfileImage:self.members[1]]];
            [self.quadrupleCoverImageView3 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.members[2]]] placeholderImage:[Utils getDefaultUserProfileImage:self.members[2]]];
            [self.quadrupleCoverImageView4 setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:self.members[3]]] placeholderImage:[Utils getDefaultUserProfileImage:self.members[3]]];
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

- (void)clickCoverImage:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionTakePhoto = [UIAlertAction actionWithTitle:@"Take Photo..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
            mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
            mediaUI.mediaTypes = mediaTypes;
            [mediaUI setDelegate:self];
            [self presentViewController:mediaUI animated:YES completion:nil];
        });
    }];
    
    UIAlertAction *actionChooseFromLibrary = [UIAlertAction actionWithTitle:@"Choose from Library..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
            mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
            mediaUI.mediaTypes = mediaTypes;
            [mediaUI setDelegate:self];
            [self presentViewController:mediaUI animated:YES completion:nil];
        });
    }];
    
    UIAlertAction *actionClose = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:actionTakePhoto];
    [alertController addAction:actionChooseFromLibrary];
    [alertController addAction:actionClose];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)clickCreateGroupChannel:(id)sender {
    [self showLoadingIndicatorView];
    NSString *channelName = self.channelNameTextField.text;
    BOOL isDistinct = [[[NSUserDefaults standardUserDefaults] objectForKey:ID_CREATE_DISTINCT_CHANNEL] boolValue];
    
    SBDGroupChannelParams *params = [[SBDGroupChannelParams alloc] init];
    params.coverImage = self.coverImageData;
    params.isDistinct = isDistinct;
    [params addUsers:self.members];
    params.name = channelName;
    
    [SBDGroupChannel createChannelWithParams:params completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
        [self hideLoadingIndicatorView];
        
        if (error != nil) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionClose = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:actionClose];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertController animated:YES completion:nil];
            });
            
            return;
        }
        
        GroupChannelChatViewController *vc = [[GroupChannelChatViewController alloc] initWithNibName:@"GroupChannelChatViewController" bundle:nil];
        vc.channel = channel;
        if (((CreateGroupChannelNavigationController *)self.navigationController).channelCreationDelegate != nil && [((CreateGroupChannelNavigationController *)self.navigationController).channelCreationDelegate respondsToSelector:@selector(didChangeValueForKey:)]) {
            [((CreateGroupChannelNavigationController *)self.navigationController).channelCreationDelegate didCreateGroupChannel:channel];
        }
        [self.navigationController pushViewController:vc animated:YES];
    }];
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
    if ([cvc isKindOfClass:[CreateGroupChannelViewControllerA class]]) {
        [((CreateGroupChannelViewControllerA *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __weak CreateGroupChannelViewControllerB *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        CreateGroupChannelViewControllerB *strongSelf = weakSelf;
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
    [picker dismissViewControllerAnimated:YES completion:nil];
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
    self.singleCoverImageView.image = croppedImage;
    self.singleCoverImageContainerView.hidden = NO;
    self.doubleCoverImageContainerView.hidden = YES;
    self.tripleCoverImageContainerView.hidden = YES;
    self.quadrupleCoverImageContainerView.hidden = YES;
    self.coverImageData = UIImageJPEGRepresentation(croppedImage, 0.5);
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle {
    self.singleCoverImageView.image = croppedImage;
    self.singleCoverImageContainerView.hidden = NO;
    self.doubleCoverImageContainerView.hidden = YES;
    self.tripleCoverImageContainerView.hidden = YES;
    self.quadrupleCoverImageContainerView.hidden = YES;
    self.coverImageData = UIImageJPEGRepresentation(croppedImage, 0.5);
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage {
    // Use when `applyMaskToCroppedImage` set to YES.
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
