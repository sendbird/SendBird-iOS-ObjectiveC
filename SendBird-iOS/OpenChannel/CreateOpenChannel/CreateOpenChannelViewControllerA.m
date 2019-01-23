//
//  CreateOpenChannelViewControllerA.m
//  SendBird-iOS
//
//  Created by SendBird on 12/4/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "CreateOpenChannelViewControllerA.h"
#import <SendBirdSDK/SendBirdSDK.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>
#import <Photos/Photos.h>
#import "UIViewController+Utils.h"
#import "OpenChannelsViewController.h"

@interface CreateOpenChannelViewControllerA ()

@property (strong, nonatomic) UIBarButtonItem *cancelButton;
@property (strong, nonatomic) UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UITextField *channelNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (strong) NSData *coverImageData;

@end

@implementation CreateOpenChannelViewControllerA

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Create Open Channel";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(clickCancelButton:)];
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(clickNextButton:)];
    self.navigationItem.rightBarButtonItem = self.nextButton;
    
    if (self.channelNameTextField.text.length > 0) {
        [self.nextButton setEnabled:YES];
    }
    else {
        [self.nextButton setEnabled:NO];
    }
    
    self.channelNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Channel Name" attributes:@{
                                                                                                                              NSFontAttributeName : [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular],
                                                                                                                              NSForegroundColorAttributeName: [UIColor colorNamed:@"color_channelname_nickname_placeholder"],
                                                                                                                              }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChangeNotification:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    UITapGestureRecognizer *clickCoverImageRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCoverImage:)];
    [self.coverImageView setUserInteractionEnabled:YES];
    [self.coverImageView addGestureRecognizer:clickCoverImageRecognizer];
    
    // Set the default cover image randomly.
    int r = arc4random() % 5;
    switch (r) {
        case 0:
            [self.coverImageView setImage:[UIImage imageNamed:@"img_default_cover_image_1"]];
            break;
        case 1:
            [self.coverImageView setImage:[UIImage imageNamed:@"img_default_cover_image_2"]];
            break;
        case 2:
            [self.coverImageView setImage:[UIImage imageNamed:@"img_default_cover_image_3"]];
            break;
        case 3:
            [self.coverImageView setImage:[UIImage imageNamed:@"img_default_cover_image_4"]];
            break;
        case 4:
            [self.coverImageView setImage:[UIImage imageNamed:@"img_default_cover_image_5"]];
            break;
        default:
            [self.coverImageView setImage:[UIImage imageNamed:@"img_default_cover_image_1"]];
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickCoverImage:(id)sender {
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

- (void)textFieldDidChangeNotification:(NSNotification *)notification {
    if (notification.object == self.channelNameTextField) {
        if (self.channelNameTextField.text.length > 0) {
            [self.nextButton setEnabled:YES];
        }
        else {
            [self.nextButton setEnabled:NO];
        }
    }
}

#pragma mark - NotificationDelegate
- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self dismissViewControllerAnimated:NO completion:^{
        UIViewController *cvc = [UIViewController currentViewController];
        if ([cvc isKindOfClass:[OpenChannelsViewController class]]) {
            [((OpenChannelsViewController *)cvc) openChatWithChannelUrl:channelUrl];
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)clickNextButton:(id)sender {
    CreateOpenChannelViewControllerB *vc = [[CreateOpenChannelViewControllerB alloc] initWithNibName:@"CreateOpenChannelViewControllerB" bundle:nil];
    vc.channelName = self.channelNameTextField.text;
    if (self.coverImageData == nil) {
        self.coverImageData = UIImageJPEGRepresentation(self.coverImageView.image, 0.5);
    }
    vc.coverImageData = self.coverImageData;
    [self.navigationController pushViewController:vc animated:YES];
}

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
    __weak CreateOpenChannelViewControllerA *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        CreateOpenChannelViewControllerA *strongSelf = weakSelf;
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
    self.coverImageView.image = croppedImage;
    self.coverImageData = UIImageJPEGRepresentation(croppedImage, 0.5);
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle {
    self.coverImageView.image = croppedImage;
    self.coverImageData = UIImageJPEGRepresentation(croppedImage, 0.5);
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage {
    // Use when `applyMaskToCroppedImage` set to YES.
}


@end
