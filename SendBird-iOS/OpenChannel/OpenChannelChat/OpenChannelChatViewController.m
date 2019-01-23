//
//  OpenChannelChatViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 1/23/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "OpenChannelChatViewController.h"
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFURLRequestSerialization.h>
#import <AFNetworking/AFImageDownloader.h>
#import <AFNetworking/UIImage+AFNetworking.h>
#import "CustomPhotosViewController.h"
#import <FLAnimatedImage/FLAnimatedImage.h>
#import "PhotoViewer.h"
#import "CustomActivityIndicatorView.h"
#import "FLAnimatedImageView+ImageLoader.h"
#import "OpenChannelSettingsViewController.h"
#import "UserProfileViewController.h"
#import "CreateOpenChannelNavigationController.h"

#import "OpenChannelAdminMessageTableViewCell.h"
#import "OpenChannelUserMessageTableViewCell.h"
#import "OpenChannelImageVideoFileMessageTableViewCell.h"
#import "OpenChannelAudioFileMessageTableViewCell.h"
#import "Utils.h"
#import "DownloadManager.h"
#import "UIViewController+Utils.h"
#import "OpenChannelsViewController.h"
#import "CreateOpenChannelViewControllerB.h"

@interface OpenChannelChatViewController ()

@property (weak, nonatomic) IBOutlet UITableView *messageTableView;

@property (atomic) BOOL keyboardShown;
@property (atomic) CGFloat keyboardHeight;
@property (atomic) BOOL firstKeyboardShown;

@property (atomic) BOOL initialLoading;
@property (atomic) BOOL stopMeasuringVelocity;
@property (atomic) CGFloat lastMessageHeight;
@property (atomic) BOOL scrollLock;
@property (atomic) CGPoint lastOffset;
@property (atomic) NSTimeInterval lastOffsetCapture;
@property (atomic) BOOL isScrollingFast;

@property (atomic) BOOL hasPrevious;
@property (atomic) long long minMessageTimestamp;
@property (atomic) BOOL isLoading;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputMessageInnerContainerViewBottomMargin;
@property (weak, nonatomic) IBOutlet CustomActivityIndicatorView *loadingIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *toastView;
@property (weak, nonatomic) IBOutlet UILabel *toastMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendUserMessageButton;

@property (strong) NSMutableArray<SBDBaseMessage *> *messages;

@property (strong, nonatomic) NSMutableDictionary<NSString *, SBDBaseMessage *> *resendableMessages;
@property (strong, nonatomic) NSMutableDictionary<NSString *, SBDBaseMessage *> *preSendMessages;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *preSendFileData;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *resendableFileData;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *fileTrasnferProgress;

@property (strong) SBDBaseMessage *selectedMessage;

@property (atomic) BOOL channelUpdated;

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *sendingImageVideoMessage;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *loadedImageHash;

@end

@implementation OpenChannelChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [SBDMain addChannelDelegate:self identifier:self.description];

    self.sendingImageVideoMessage = [[NSMutableDictionary alloc] init];
    self.resendableMessages = [[NSMutableDictionary alloc] init];
    self.preSendMessages = [[NSMutableDictionary alloc] init];
    self.resendableFileData = [[NSMutableDictionary alloc] init];
    self.preSendFileData = [[NSMutableDictionary alloc] init];
    self.fileTrasnferProgress = [[NSMutableDictionary alloc] init];
    self.loadedImageHash = [[NSMutableDictionary alloc] init];
    
    self.title = self.channel.name;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationController.navigationBarHidden = NO;
    
    UIBarButtonItem *settingBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"img_btn_channel_settings"] style:UIBarButtonItemStylePlain target:self action:@selector(clickOpenChannelSettingsButton:)];
    self.navigationItem.rightBarButtonItem = settingBarButtonItem;
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = nil;
    
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];

    self.messageTableView.rowHeight = UITableViewAutomaticDimension;
    self.messageTableView.estimatedRowHeight = 140;
    self.messageTableView.delegate = self;
    self.messageTableView.dataSource = self;
    self.messageTableView.contentInset = UIEdgeInsetsMake(0, 0, 14, 0);
    
    [self.messageTableView registerNib:[UINib nibWithNibName:@"OpenChannelAdminMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelAdminMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"OpenChannelUserMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelUserMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"OpenChannelImageVideoFileMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelImageVideoFileMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"OpenChannelGeneralFileMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelGeneralFileMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"OpenChannelAudioFileMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"OpenChannelAudioFileMessageTableViewCell"];
    
    // Input Text Field.
    UIView *leftPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    UIView *rightPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    self.inputMessageTextField.leftView = leftPaddingView;
    self.inputMessageTextField.rightView = rightPaddingView;
    self.inputMessageTextField.leftViewMode = UITextFieldViewModeAlways;
    self.inputMessageTextField.rightViewMode = UITextFieldViewModeAlways;
    [self.inputMessageTextField addTarget:self action:@selector(inputMessageTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    self.sendUserMessageButton.enabled = NO;
    
    self.initialLoading = YES;
    self.lastMessageHeight = 0;
    self.scrollLock = NO;
    self.stopMeasuringVelocity = NO;
    self.minMessageTimestamp = LLONG_MAX;
    self.isLoading = NO;
    self.firstKeyboardShown = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

    [self.view bringSubviewToFront:self.loadingIndicatorView];
    self.loadingIndicatorView.hidden = YES;
    
    self.messages = [[NSMutableArray alloc] init];

    [self loadPreviousMessages:YES];
    
    self.channelUpdated = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        if ([self.navigationController isKindOfClass:[CreateOpenChannelNavigationController class]] && ![self.navigationController.topViewController isKindOfClass:[OpenChannelSettingsViewController class]]) {
            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
            if (self.createChannelDelegate != nil && [self.createChannelDelegate respondsToSelector:@selector(didCreate:)]) {
                [self.createChannelDelegate didCreate:self.channel];
            }
        }
        else {
            [super viewWillDisappear:animated];
        }
        
        [self.channel exitChannelWithCompletionHandler:^(SBDError * _Nullable error) {
            if (self.channelUpdated && self.delegate != nil && [self.delegate respondsToSelector:@selector(didUpdateOpenChannel)]) {
                [self.delegate didUpdateOpenChannel];
            }
        }];
    }
    else {
        [super viewWillDisappear:animated];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [SBDConnectionManager removeNetworkDelegateForIdentifier:self.description];
}

- (void)showToast:(NSString *)message {
    self.toastView.alpha = 1;
    self.toastMessageLabel.text = message;
    self.toastView.hidden = NO;
    
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.toastView.alpha = 0;
    } completion:^(BOOL finished) {
        self.toastView.hidden = YES;
    }];
}

- (void)loadPreviousMessages:(BOOL)initial {
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    long long timestamp = 0;
    if (initial) {
        self.hasPrevious = YES;
        timestamp = LLONG_MAX;
    }
    else {
        timestamp = self.minMessageTimestamp;
    }
    
    if (self.hasPrevious == NO) {
        return;
    }
    
    [self.channel getPreviousMessagesByTimestamp:timestamp limit:30 reverse:!initial messageType:SBDMessageTypeFilterAll customType:nil completionHandler:^(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error) {
        if (error != nil) {
            self.isLoading = NO;
            
            return;
        }
        
        if (messages.count == 0) {
            self.hasPrevious = NO;
        }
        
        if (initial) {
            if (messages.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.messages removeAllObjects];
                    
                    for (SBDBaseMessage *message in messages) {
                        [self.messages addObject:message];
                        
                        if (self.minMessageTimestamp > message.createdAt) {
                            self.minMessageTimestamp = message.createdAt;
                        }
                    }
                    
                    self.initialLoading = YES;
            
                    [self.messageTableView reloadData];
                    [self.messageTableView layoutIfNeeded];
                    
                    [self scrollToBottomWithForce:YES];
                    self.initialLoading = NO;
                    self.isLoading = NO;
                });
            }
        }
        else {
            if (messages.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray<NSIndexPath *> *messageIndexPaths = [[NSMutableArray alloc] init];
                    NSInteger row = 0;
                    for (SBDBaseMessage *message in messages) {
                        [self.messages insertObject:message atIndex:0];
                        
                        if (self.minMessageTimestamp > message.createdAt) {
                            self.minMessageTimestamp = message.createdAt;
                        }
                        
                        [messageIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
                        row += 1;
                    }
                    
                    [self.messageTableView reloadData];
                    [self.messageTableView layoutIfNeeded];
                    
                    [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    
                    self.isLoading = NO;
                });
            }
        }
    }];
}

#pragma mark - NotificationDelegate
- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    if ([channelUrl isEqualToString:self.channel.channelUrl]) {
        return;
    }
    [self.navigationController popViewControllerAnimated:NO];
    UIViewController *cvc = [UIViewController currentViewController];
    if ([cvc isKindOfClass:[OpenChannelsViewController class]]) {
        [((OpenChannelsViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
    else if ([cvc isKindOfClass:[CreateOpenChannelViewControllerB class]]) {
        [((CreateOpenChannelViewControllerB *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - Keyboard

- (void)determineScrollLock {
    if (self.messages.count > 0) {
        NSArray *indexPaths = [self.messageTableView indexPathsForVisibleRows];
        if (indexPaths != nil) {
            NSIndexPath *lastVisibleCellIndexPath = (NSIndexPath *)(indexPaths.lastObject);
            if (lastVisibleCellIndexPath != nil) {
                NSInteger lastVisibleRow = lastVisibleCellIndexPath.row;
                if (lastVisibleRow != self.messages.count - 1) {
                    self.scrollLock = YES;
                }
                else {
                    self.scrollLock = NO;
                }
            }
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self determineScrollLock];
    
    if (!self.firstKeyboardShown) {
        self.keyboardShown = YES;
    }
    self.firstKeyboardShown = NO;
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.keyboardHeight = keyboardFrameBeginRect.size.height;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.inputMessageInnerContainerViewBottomMargin.constant = self.keyboardHeight - self.view.safeAreaInsets.bottom;
        [self.view layoutIfNeeded];
        
        self.stopMeasuringVelocity = YES;
        [self scrollToBottomWithForce:NO];
        self.keyboardShown = YES;
    });
}

- (void)keyboardDidHide:(NSNotification *)notification {
    self.keyboardShown = NO;
    self.keyboardHeight = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.inputMessageInnerContainerViewBottomMargin.constant = 0;
        [self.view layoutIfNeeded];
        [self scrollToBottomWithForce:NO];
    });
}

- (void)hideKeyboardWhenFastScrolling {
    if (self.keyboardShown == NO) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.inputMessageInnerContainerViewBottomMargin.constant = 0;
        [self.view layoutIfNeeded];
        [self scrollToBottomWithForce:NO];
    });
    [self.view endEditing:YES];
    
    self.firstKeyboardShown = NO;
}

- (IBAction)clickSendUserMessageButton:(id)sender {
    if (self.inputMessageTextField.text.length == 0) {
        return;
    }
    
    NSString *messageText = self.inputMessageTextField.text;
    __block SBDUserMessage *preSendMessage = [self.channel sendUserMessage:messageText completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
        self.inputMessageTextField.text = @"";
        self.sendUserMessageButton.enabled = NO;
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.preSendMessages removeObjectForKey:preSendMessage.requestId];
                self.resendableMessages[preSendMessage.requestId] = preSendMessage;
                [self.messageTableView reloadData];
                [self scrollToBottomWithForce:NO];
            });

            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self determineScrollLock];
            [self.messages replaceObjectAtIndex:[self.messages indexOfObject:self.preSendMessages[userMessage.requestId]] withObject:userMessage];
            [self.preSendMessages removeObjectForKey:userMessage.requestId];
            [self.messageTableView reloadData];
            [self scrollToBottomWithForce:NO];
        });
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self determineScrollLock];
        self.preSendMessages[preSendMessage.requestId] = preSendMessage;
        [self.messages addObject:preSendMessage];
        [self.messageTableView reloadData];
        [self scrollToBottomWithForce:NO];
    });
}

- (IBAction)clickSendFileMessageButton:(id)sender {
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
    
    UIAlertAction *takeVideoAction = [UIAlertAction actionWithTitle:@"Take Video..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
            mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
            mediaUI.mediaTypes = mediaTypes;
            [mediaUI setDelegate:self];
            [self presentViewController:mediaUI animated:YES completion:nil];
        });
    }];
    
    UIAlertAction *browseDocumentsAction = [UIAlertAction actionWithTitle:@"Browse Files..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
            documentPicker.allowsMultipleSelection = NO;
            documentPicker.delegate = self;
            [self presentViewController:documentPicker animated:YES completion:nil];
        });
    }];
    
    UIAlertAction *chooseFromLibraryAction = [UIAlertAction actionWithTitle:@"Choose from Library..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
            mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie, nil];
            mediaUI.mediaTypes = mediaTypes;
            [mediaUI setDelegate:self];
            [self presentViewController:mediaUI animated:YES completion:nil];
        });
    }];
    
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    
    [vc addAction:takePhotoAction];
    [vc addAction:takeVideoAction];
    [vc addAction:browseDocumentsAction];
    [vc addAction:chooseFromLibraryAction];
    [vc addAction:closeAction];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Scroll
- (void)scrollToBottomWithForce:(BOOL)force {
    if (self.messages.count == 0) {
        return;
    }
    
    if (self.scrollLock && force == NO) {
        return;
    }
    
    NSInteger currentRowNumber = [self.messageTableView numberOfRowsInSection:0];

    [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowNumber - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)scrollToPosition:(NSInteger)position {
    if (self.messages.count == 0) {
        return;
    }
    
    [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:position inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)clickOpenChannelSettingsButton:(id)sender {
    OpenChannelSettingsViewController *vc = [[OpenChannelSettingsViewController alloc] initWithNibName:@"OpenChannelSettingsViewController" bundle:nil];
    vc.delegate = self;
    vc.channel = self.channel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if ([self.messages[indexPath.row] isKindOfClass:[SBDAdminMessage class]]) {
        SBDAdminMessage *adminMessage = (SBDAdminMessage *)self.messages[indexPath.row];
        OpenChannelAdminMessageTableViewCell *adminMessageCell = (OpenChannelAdminMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OpenChannelAdminMessageTableViewCell"];
        [adminMessageCell setMessage:adminMessage];
        adminMessageCell.delegate = self;
        if (indexPath.row > 0) {
            [adminMessageCell setPreviousMessage:self.messages[indexPath.row - 1]];
        }
        
        cell = (UITableViewCell *)adminMessageCell;
    }
    else if ([self.messages[indexPath.row] isKindOfClass:[SBDUserMessage class]]) {
        SBDUserMessage *userMessage = (SBDUserMessage *)self.messages[indexPath.row];
        OpenChannelUserMessageTableViewCell *userMessageCell = (OpenChannelUserMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OpenChannelUserMessageTableViewCell"];
        userMessageCell.delegate = self;
        [userMessageCell setMessage:userMessage];
        
        if ([userMessage.sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            // Outgoing message
            if (userMessage.requestId != nil && self.resendableMessages[userMessage.requestId] != nil) {
                [userMessageCell showElementsForFailure];
            }
            else {
                [userMessageCell hideElementsForFailure];
            }
        }
        else {
            // Incoming message
            [userMessageCell hideElementsForFailure];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];
            if (updateCell != nil && [updateCell isKindOfClass:[OpenChannelUserMessageTableViewCell class]]) {
                [((OpenChannelUserMessageTableViewCell *)updateCell).profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:userMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:userMessage.sender]];
            }
        });

        cell = (UITableViewCell *)userMessageCell;
    }
    else if ([self.messages[indexPath.row] isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)self.messages[indexPath.row];
        if ([fileMessage.sender.userId isEqualToString:[SBDMain getCurrentUser].userId] && self.preSendMessages[fileMessage.requestId] != nil) {
            // Outgoing & Pre send file message
            NSDictionary *fileDataDict = self.preSendFileData[fileMessage.requestId];
            if (fileDataDict != nil) {
                if ([fileDataDict[@"type"] hasPrefix:@"image"]) {
                    OpenChannelImageVideoFileMessageTableViewCell *imageFileMessageCell = (OpenChannelImageVideoFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OpenChannelImageVideoFileMessageTableViewCell" forIndexPath:indexPath];
                    [imageFileMessageCell setMessage:fileMessage];
                    imageFileMessageCell.delegate = nil;
                    [imageFileMessageCell hideElementsForFailure];
                    [imageFileMessageCell showBottomMargin];
                    [imageFileMessageCell hideAllPlaceholders];
                    
                    if (self.fileTrasnferProgress[fileMessage.requestId] != nil) {
                        CGFloat progress = [[self.fileTrasnferProgress objectForKey:fileMessage.requestId] doubleValue];
                        [imageFileMessageCell showProgress:progress];
                    }
                    
                    if ([fileDataDict[@"type"] isEqualToString:@"image/gif"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            OpenChannelImageVideoFileMessageTableViewCell *updateCell = (OpenChannelImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                NSData *imageData = fileDataDict[@"data"];
                                [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                [updateCell.fileImageView setAnimatedImage:[FLAnimatedImage animatedImageWithGIFData:imageData]];
                            }
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            OpenChannelImageVideoFileMessageTableViewCell *updateCell = (OpenChannelImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                NSData *imageData = fileDataDict[@"data"];
                                [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                [updateCell.fileImageView setImage:[UIImage imageWithData:imageData]];
                            }
                        });
                    }
                    
                    cell = (UITableViewCell *)imageFileMessageCell;
                }
                else if ([fileDataDict[@"type"] hasPrefix:@"video"]) {
                    OpenChannelImageVideoFileMessageTableViewCell *videoFileMessageCell = (OpenChannelImageVideoFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OpenChannelImageVideoFileMessageTableViewCell" forIndexPath:indexPath];
                    [videoFileMessageCell setMessage:fileMessage];
                    videoFileMessageCell.delegate = nil;
                    [videoFileMessageCell hideElementsForFailure];
                    [videoFileMessageCell showBottomMargin];
                    [videoFileMessageCell hideAllPlaceholders];
                    videoFileMessageCell.videoMessagePlaceholderImageView.hidden = NO;
                    
                    videoFileMessageCell.fileImageView.image = nil;
                    videoFileMessageCell.fileImageView.animatedImage = nil;

                    if (self.fileTrasnferProgress[fileMessage.requestId] != nil) {
                        CGFloat progress = [[self.fileTrasnferProgress objectForKey:fileMessage.requestId] doubleValue];
                        [videoFileMessageCell showProgress:progress];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        OpenChannelImageVideoFileMessageTableViewCell *updateCell = (OpenChannelImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                        }
                    });
                    
                    cell = (UITableViewCell *)videoFileMessageCell;
                }
                else if ([fileDataDict[@"type"] hasPrefix:@"audio"]) {
                    OpenChannelAudioFileMessageTableViewCell *audioFileMessageCell = (OpenChannelAudioFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OpenChannelAudioFileMessageTableViewCell" forIndexPath:indexPath];
                    [audioFileMessageCell setMessage:fileMessage];
                    audioFileMessageCell.delegate = nil;
                    [audioFileMessageCell hideElementsForFailure];
                    [audioFileMessageCell showBottomMargin];
                    
                    if (self.fileTrasnferProgress[fileMessage.requestId] != nil) {
                        CGFloat progress = [[self.fileTrasnferProgress objectForKey:fileMessage.requestId] doubleValue];
                        [audioFileMessageCell showProgress:progress];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        OpenChannelAudioFileMessageTableViewCell *updateCell = (OpenChannelAudioFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                        }
                    });
                    
                    cell = (UITableViewCell *)audioFileMessageCell;
                }
                else {
                    OpenChannelGeneralFileMessageTableViewCell *generalFileMessageCell = (OpenChannelGeneralFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OpenChannelGeneralFileMessageTableViewCell" forIndexPath:indexPath];
                    [generalFileMessageCell setMessage:fileMessage];
                    generalFileMessageCell.delegate = nil;
                    [generalFileMessageCell hideElementsForFailure];
                    [generalFileMessageCell showBottomMargin];
                    
                    if (self.fileTrasnferProgress[fileMessage.requestId] != nil) {
                        CGFloat progress = [[self.fileTrasnferProgress objectForKey:fileMessage.requestId] doubleValue];
                        [generalFileMessageCell showProgress:progress];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        OpenChannelGeneralFileMessageTableViewCell *updateCell = (OpenChannelGeneralFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                        }
                    });
                    
                    cell = (UITableViewCell *)generalFileMessageCell;
                }
            }
        }
        else {
            // Sent outgoing & incoming message
            if ([fileMessage.type hasPrefix:@"image"]) {
                OpenChannelImageVideoFileMessageTableViewCell *imageFileMessageCell = (OpenChannelImageVideoFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OpenChannelImageVideoFileMessageTableViewCell" forIndexPath:indexPath];
                imageFileMessageCell.delegate = self;
                
                [imageFileMessageCell hideElementsForFailure];
                [imageFileMessageCell hideAllPlaceholders];
                [imageFileMessageCell setMessage:fileMessage];
                imageFileMessageCell.channel = self.channel;
                [imageFileMessageCell hideProgress];
                [imageFileMessageCell hideBottomMargin];

                if (self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] == nil || [self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] longLongValue] != imageFileMessageCell.imageHash) {
                    imageFileMessageCell.imageMessagePlaceholderImageView.hidden = NO;
                    [imageFileMessageCell setImage:nil];
                    [imageFileMessageCell setAnimatedImage:nil hash:0];
                }
                
                cell = (UITableViewCell *)imageFileMessageCell;
                
                if ([fileMessage.type isEqualToString:@"image/gif"]) {
                    [imageFileMessageCell.fileImageView setAnimatedImageWithURL:[NSURL URLWithString:fileMessage.url] success:^(FLAnimatedImage * _Nullable image, NSUInteger hash) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            OpenChannelImageVideoFileMessageTableViewCell *updateCell = (OpenChannelImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                [updateCell hideAllPlaceholders];
                                [updateCell setAnimatedImage:image hash:hash];
                                [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] = @(hash);
                            }
                        });
                    } failure:^(NSError * _Nullable error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            OpenChannelImageVideoFileMessageTableViewCell *updateCell = (OpenChannelImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                [updateCell hideAllPlaceholders];
                                updateCell.imageMessagePlaceholderImageView.hidden = NO;
                                [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                [updateCell setImage:nil];
                                [updateCell setAnimatedImage:nil hash:0];
                                [self.loadedImageHash removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                            }
                        });
                    }];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        OpenChannelImageVideoFileMessageTableViewCell *updateCell = (OpenChannelImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if ([updateCell isKindOfClass:[OpenChannelImageVideoFileMessageTableViewCell class]]) {
                            if (fileMessage.thumbnails != nil && fileMessage.thumbnails.count > 0) {
                                __weak OpenChannelImageVideoFileMessageTableViewCell *weakCell = updateCell;
                                [updateCell.fileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fileMessage.thumbnails[0].url]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                    __strong OpenChannelImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                    [strongCell hideAllPlaceholders];
                                    [strongCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                    [strongCell setImage:image];
                                    self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] = @(UIImageJPEGRepresentation(image, 0.5).hash);
                                } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                    __strong OpenChannelImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                    [strongCell hideAllPlaceholders];
                                    strongCell.imageMessagePlaceholderImageView.hidden = NO;
                                    [strongCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                    [strongCell setImage:nil];
                                    [strongCell setAnimatedImage:nil hash:0];
                                    [self.loadedImageHash removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                                }];
                            }
                        }
                    });
                }
            }
            else if ([fileMessage.type hasPrefix:@"video"]) {
                OpenChannelImageVideoFileMessageTableViewCell *videoFileMessageCell = (OpenChannelImageVideoFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OpenChannelImageVideoFileMessageTableViewCell" forIndexPath:indexPath];
                videoFileMessageCell.delegate = self;
                
                [videoFileMessageCell hideAllPlaceholders];
                
                if (videoFileMessageCell.imageHash == 0 || videoFileMessageCell.fileImageView.image == nil) {
                    [videoFileMessageCell setAnimatedImage:nil hash:0];
                    [videoFileMessageCell setImage:nil];
                }

                videoFileMessageCell.channel = self.channel;
                [videoFileMessageCell setMessage:fileMessage];
                
                [videoFileMessageCell hideProgress];
                
                if (self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] == nil || [self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] longLongValue] != videoFileMessageCell.imageHash) {
                    videoFileMessageCell.videoMessagePlaceholderImageView.hidden = NO;
                    [videoFileMessageCell setImage:nil];
                    [videoFileMessageCell setAnimatedImage:nil hash:0];
                }
                
                cell = (UITableViewCell *)videoFileMessageCell;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    OpenChannelImageVideoFileMessageTableViewCell *updateCell = (OpenChannelImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                    if ([updateCell isKindOfClass:[OpenChannelImageVideoFileMessageTableViewCell class]]) {
                        if (fileMessage.thumbnails != nil && fileMessage.thumbnails.count > 0) {
                            __weak OpenChannelImageVideoFileMessageTableViewCell *weakCell = updateCell;
                            [updateCell.fileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fileMessage.thumbnails[0].url]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                __strong OpenChannelImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                [strongCell hideAllPlaceholders];
                                strongCell.videoPlayIconImageView.hidden = NO;
                                [strongCell setImage:image];
                                [strongCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] = @(UIImageJPEGRepresentation(image, 0.5).hash);
                            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                __strong OpenChannelImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                strongCell.videoPlayIconImageView.hidden = YES;
                                strongCell.videoMessagePlaceholderImageView.hidden = NO;
                                [strongCell setAnimatedImage:nil hash:0];
                                [strongCell setImage:nil];
                                [strongCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                [self.loadedImageHash removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                            }];
                        }
                        else {
                            // Without thumbnails.
                            [updateCell hideAllPlaceholders];
                            updateCell.videoMessagePlaceholderImageView.hidden = NO;
                            [updateCell setAnimatedImage:nil hash:0];
                            [updateCell setImage:nil];
                            [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                            [self.loadedImageHash removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                        }
                    }
                });
            }
            else if ([fileMessage.type hasPrefix:@"audio"]) {
                OpenChannelAudioFileMessageTableViewCell *audioFileMessageCell = (OpenChannelAudioFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OpenChannelAudioFileMessageTableViewCell" forIndexPath:indexPath];
                audioFileMessageCell.delegate = self;
                [audioFileMessageCell setMessage:fileMessage];
                [audioFileMessageCell hideElementsForFailure];
                [audioFileMessageCell hideProgress];
                [audioFileMessageCell hideBottomMargin];
                
                cell = (UITableViewCell *)audioFileMessageCell;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    OpenChannelAudioFileMessageTableViewCell *updateCell = (OpenChannelAudioFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell) {
                        [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                    }
                });
            }
            else {
                OpenChannelGeneralFileMessageTableViewCell *generalFileMessageCell = (OpenChannelGeneralFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OpenChannelGeneralFileMessageTableViewCell" forIndexPath:indexPath];
                generalFileMessageCell.delegate = self;
                [generalFileMessageCell setMessage:fileMessage];
                [generalFileMessageCell hideElementsForFailure];
                [generalFileMessageCell hideProgress];
                [generalFileMessageCell hideBottomMargin];
                
                cell = (UITableViewCell *)generalFileMessageCell;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    OpenChannelGeneralFileMessageTableViewCell *updateCell = (OpenChannelGeneralFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell) {
                        [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                    }
                });
            }
        }
    }
    
    if (indexPath.row == 0 && self.messages.count > 0 && self.initialLoading == NO && self.isLoading == NO) {
        [self loadPreviousMessages:NO];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.stopMeasuringVelocity = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.stopMeasuringVelocity = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.messageTableView) {
        if (self.stopMeasuringVelocity == NO) {
            CGPoint currentOffset = scrollView.contentOffset;
            NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
            
            NSTimeInterval timeDiff = currentTime - self.lastOffsetCapture;
            if(timeDiff > 0.1) {
                CGFloat distance = currentOffset.y - self.lastOffset.y;
                //The multiply by 10, / 1000 isn't really necessary.......
                CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
                
                CGFloat scrollSpeed = fabs(scrollSpeedNotAbs);
                if (scrollSpeed > 1.0) {
                    self.isScrollingFast = YES;
                } else {
                    self.isScrollingFast = NO;
                }
                
                self.lastOffset = currentOffset;
                self.lastOffsetCapture = currentTime;
            }
            
            if (self.isScrollingFast) {
                [self hideKeyboardWhenFastScrolling];
            }
        }
    }
}

#pragma mark - OpenChannelMessageTableViewCellDelegate
- (void)didClickResendUserMessageButton:(SBDUserMessage *)message {
    NSString *messageText = message.message;

    __block SBDUserMessage *preSendMessage = [self.channel sendUserMessage:messageText completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
        self.inputMessageTextField.text = @"";
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.messages replaceObjectAtIndex:[self.messages indexOfObject:message] withObject:preSendMessage];
                [self.resendableMessages removeObjectForKey:message.requestId];
                [self.preSendMessages removeObjectForKey:preSendMessage.requestId];
                self.resendableMessages[preSendMessage.requestId] = preSendMessage;
                [self.messageTableView reloadData];
                [self scrollToBottomWithForce:NO];
            });
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self determineScrollLock];
            [self.messages replaceObjectAtIndex:[self.messages indexOfObject:self.preSendMessages[userMessage.requestId]] withObject:userMessage];
            [self.preSendMessages removeObjectForKey:preSendMessage.requestId];
            [self.messageTableView reloadData];
            [self scrollToBottomWithForce:NO];
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messages replaceObjectAtIndex:[self.messages indexOfObject:message] withObject:preSendMessage];
        [self.resendableMessages removeObjectForKey:message.requestId];
        [self determineScrollLock];
        self.preSendMessages[preSendMessage.requestId] = preSendMessage;
        [self.messageTableView reloadData];
        [self scrollToBottomWithForce:NO];
    });
}

- (void)didClickResendImageFileMessageButton:(SBDFileMessage *)message {
    NSData *imageData = (NSData *)self.resendableFileData[message.requestId][@"data"];
    NSString *filename = (NSString *)self.resendableFileData[message.requestId][@"filename"];
    NSString *mimeType = (NSString *)self.resendableFileData[message.requestId][@"type"];
    
    /***********************************/
    /* Thumbnail is a premium feature. */
    /***********************************/
    SBDThumbnailSize *thumbnailSize = [SBDThumbnailSize makeWithMaxWidth:320.0 maxHeight:320.0];
    
    __block SBDFileMessage *preSendMessage = [self.channel sendFileMessageWithBinaryData:imageData filename:filename type:mimeType size:imageData.length thumbnailSizes:@[thumbnailSize] data:nil customType:nil progressHandler:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fileTrasnferProgress[preSendMessage.requestId] = @((CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend);
            for (NSInteger index = self.messages.count - 1; index >= 0; index--) {
                SBDBaseMessage *baseMessage = self.messages[index];
                if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
                    SBDFileMessage *fileMesssage = (SBDFileMessage *)baseMessage;
                    if (fileMesssage.requestId != nil && [fileMesssage.requestId isEqualToString:preSendMessage.requestId]) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        OpenChannelImageVideoFileMessageTableViewCell *cell = [self.messageTableView cellForRowAtIndexPath:indexPath];
                        [cell showProgress:[self.fileTrasnferProgress[preSendMessage.requestId] doubleValue]];
                    }
                }
            }
        });
    } completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            if (error != nil) {
                self.resendableFileData[preSendMessage.requestId] = @{
                                                                      @"data": imageData,
                                                                      @"filename": filename,
                                                                      @"type": mimeType,
                                                                      };
                self.resendableMessages[preSendMessage.requestId] = preSendMessage;
                
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.messages removeObject:preSendMessage];
                        [self.preSendMessages removeObjectForKey:preSendMessage.requestId];
                        [self.preSendFileData removeObjectForKey:preSendMessage.requestId];
                        [self.fileTrasnferProgress removeObjectForKey:preSendMessage.requestId];
                        [self.messageTableView reloadData];
                        [self scrollToBottomWithForce:NO];
                    });
                }];
                [vc addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.preSendMessages removeObjectForKey:preSendMessage.requestId];
                [self.preSendFileData removeObjectForKey:preSendMessage.requestId];
                [self.fileTrasnferProgress removeObjectForKey:preSendMessage.requestId];
                
                [self.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:fileMessage];
                [self determineScrollLock];
                [self.messageTableView reloadData];
                [self scrollToBottomWithForce:NO];
            });
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.resendableFileData removeObjectForKey:message.requestId];
        [self.resendableMessages removeObjectForKey:message.requestId];
        
        [self determineScrollLock];
        self.preSendFileData[preSendMessage.requestId] = @{
                                                           @"data": imageData,
                                                           @"type": mimeType,
                                                           @"filename": filename,
                                                           };
        self.preSendMessages[preSendMessage.requestId] = preSendMessage;
        [self.messages addObject:preSendMessage];
        [self.messageTableView reloadData];
        [self scrollToBottomWithForce:NO];
    });
}

- (void)didLongClickUserProfile:(SBDUser *)user {
    if ([user.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
        return;
    }
    
    if (![self.channel isOperatorWithUser:[SBDMain getCurrentUser]]) {
        return;
    }
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:user.nickname message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *actionBanUser = [UIAlertAction actionWithTitle:@"Ban user for 10 minutes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.channel banUser:user seconds:600 completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
                return;
            }
        }];
    }];
        
    UIAlertAction *actionMuteUser = [UIAlertAction actionWithTitle:@"Mute user" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.channel muteUser:user completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
                return;
            }
        }];
    }];

    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    if (actionBanUser != nil) {
        [vc addAction:actionBanUser];
    }
    
    if (actionMuteUser != nil) {
        [vc addAction:actionMuteUser];
    }
    
    [vc addAction:actionCancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)didClickUserProfile:(SBDUser *)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        UserProfileViewController *vc = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
        vc.user = user;
        [self.navigationController pushViewController:vc animated:YES];
    });
}

- (void)didLongClickImageVideoFileMessage:(SBDFileMessage *)message {
    UIAlertController *vc = nil;
    NSString *deleteMessageActionTitle = @"";
    NSString *saveImageVideoActionTitle = @"";
    if ([message.type hasPrefix:@"image"]) {
        vc = [UIAlertController alertControllerWithTitle:@"Image" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        deleteMessageActionTitle = @"Delete image";
        saveImageVideoActionTitle = @"Save image to media library";
    }
    else if ([message.type hasPrefix:@"video"]) {
        vc = [UIAlertController alertControllerWithTitle:@"Video" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        deleteMessageActionTitle = @"Delete video";
        saveImageVideoActionTitle = @"Save video to media library";
    }
    
    UIAlertAction *actionDeleteMessage = nil;
    if ([message.sender.userId isEqualToString:[SBDMain getCurrentUser].userId] || [self.channel isOperatorWithUser:[SBDMain getCurrentUser]]) {
        actionDeleteMessage = [UIAlertAction actionWithTitle:deleteMessageActionTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.channel deleteMessage:message completionHandler:^(SBDError * _Nullable error) {
                if (error != nil) {
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                    
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self deleteMessageFromTableView:message.messageId];
                });
            }];
        }];
    }
    
    UIAlertAction *actionSaveImageVideo = [UIAlertAction actionWithTitle:saveImageVideoActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [DownloadManager downloadWithURL:[NSURL URLWithString:message.url] filename:message.name mimeType:message.type addToMediaLibrary:YES];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    if (vc != nil) {
        [vc addAction:actionSaveImageVideo];
        if (actionDeleteMessage != nil) {
            [vc addAction:actionDeleteMessage];
        }
        [vc addAction:actionCancel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:vc animated:YES completion:nil];
        });
    }
}

- (void)didLongClickGeneralFileMessage:(SBDFileMessage *)message {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"General File" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *saveFileAction = [UIAlertAction actionWithTitle:@"Save File" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [DownloadManager downloadWithURL:[NSURL URLWithString:message.url] filename:message.name mimeType:message.type addToMediaLibrary:NO];
    }];
    UIAlertAction *deleteAction = nil;
    
    NSString *deleteActionTitle = @"";
    if ([message.type hasPrefix:@"audio"]) {
        deleteActionTitle = @"Delete audio";
    }
    else {
        deleteActionTitle = @"Delete file";
    }
    
    if ([message.sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
        deleteAction = [UIAlertAction actionWithTitle:deleteActionTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.channel deleteMessage:message completionHandler:^(SBDError * _Nullable error) {
                if (error != nil) {
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                    
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self deleteMessageFromTableView:message.messageId];
                });
            }];
        }];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [ac addAction:saveFileAction];
    if (deleteAction != nil) {
        [ac addAction:deleteAction];
    }
    [ac addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:ac animated:YES completion:nil];
    });
}

- (void)didLongClickAdminMessage:(SBDAdminMessage *)message {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:message.message message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionDeleteMessage = nil;
    if ([self.channel isOperatorWithUser:[SBDMain getCurrentUser]]) {
        actionDeleteMessage = [UIAlertAction actionWithTitle:@"Delete message" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.channel deleteMessage:message completionHandler:^(SBDError * _Nullable error) {
                if (error != nil) {
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                    
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self deleteMessageFromTableView:message.messageId];
                });
            }];
        }];
    }
    
    UIAlertAction *actionCopyMessage = [UIAlertAction actionWithTitle:@"Copy message" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = message.message;
        
        [self showToast:@"Copied"];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [vc addAction:actionCopyMessage];
    if (actionDeleteMessage != nil) {
        [vc addAction:actionDeleteMessage];
    }
    [vc addAction:actionCancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)didLongClickUserMessage:(SBDUserMessage *)message {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:message.message message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionDeleteMessage = nil;
    if ([self.channel isOperatorWithUser:[SBDMain getCurrentUser]] || [message.sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
        actionDeleteMessage = [UIAlertAction actionWithTitle:@"Delete message" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.channel deleteMessage:message completionHandler:^(SBDError * _Nullable error) {
                if (error != nil) {
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                    
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self deleteMessageFromTableView:message.messageId];
                });
            }];
        }];
    }
    
    UIAlertAction *actionCopyMessage = [UIAlertAction actionWithTitle:@"Copy message" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = message.message;
        
        [self showToast:@"Copied"];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [vc addAction:actionCopyMessage];
    if (actionDeleteMessage != nil) {
        [vc addAction:actionDeleteMessage];
    }
    [vc addAction:actionCancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)didClickImageVideoFileMessage:(SBDFileMessage *)message {
    if ([message.type hasPrefix:@"image"]) {
        self.loadingIndicatorView.hidden = NO;
        [self.loadingIndicatorView startAnimating];
        NSURLSession *session = [NSURLSession sharedSession];
        __block NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:message.url]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
            if ([resp statusCode] >= 200 && [resp statusCode] < 300) {
                PhotoViewer *photo = [[PhotoViewer alloc] init];
                photo.imageData = data;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    CustomPhotosViewController *photosViewController = [[CustomPhotosViewController alloc] initWithPhotos:@[photo]];
                    
                    self.loadingIndicatorView.hidden = YES;
                    [self.loadingIndicatorView stopAnimating];
                    
                    [self presentViewController:photosViewController animated:YES completion:nil];
                });
            }
            else {
                self.loadingIndicatorView.hidden = YES;
                [self.loadingIndicatorView stopAnimating];
            }
        }] resume];
    }
    else if ([message.type hasPrefix:@"video"]) {
        NSURL *videoUrl = [NSURL URLWithString:message.url];
        [self playMediaWithUrl:videoUrl];
        
        return;
    }
}

- (void)didClickGeneralFileMessage:(SBDFileMessage *)message {
    if ([message.type hasPrefix:@"audio"]) {
        NSURL *audioUrl = [NSURL URLWithString:message.url];
        [self playMediaWithUrl:audioUrl];
    }
}

#pragma mark - SBDChannelDelegate
- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    if (sender == self.channel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self determineScrollLock];
            [UIView setAnimationsEnabled:NO];
            [self.messages addObject:message];
            [self.messageTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self scrollToBottomWithForce:NO];
            [UIView setAnimationsEnabled:YES];
        });
    }
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasBanned:(SBDUser * _Nonnull)user {
    if ([user.userId isEqualToString:[SBDMain getCurrentUser].userId] && [sender.channelUrl isEqualToString:self.channel.channelUrl]) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"You are banned." message:@"You are banned for 10 mininutes. This channel will be closed." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [vc addAction:closeAction];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:vc animated:YES completion:nil];
        });
    }
}

- (void)channelWasDeleted:(NSString * _Nonnull)channelUrl channelType:(SBDChannelType)channelType {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Channel has been deleted." message:@"This channel has been deleted. It will be closed." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [vc addAction:closeAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)channel:(SBDBaseChannel * _Nonnull)sender messageWasDeleted:(long long)messageId {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (sender == self.channel) {
            [self deleteMessageFromTableView:messageId];
        }
   });
}

- (void)channelWasChanged:(SBDBaseChannel *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (sender == self.channel) {
            self.title = self.channel.name;
        }
    });
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
    __weak OpenChannelChatViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        OpenChannelChatViewController *strongSelf = weakSelf;
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            NSURL *imagePath = [info objectForKey:UIImagePickerControllerImageURL];
            NSString *imageName = [imagePath lastPathComponent];

            if (imagePath != nil) {
                NSString *ext = [imageName pathExtension];
                NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
                NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
                
                PHAsset *imageAsset = [info objectForKey:UIImagePickerControllerPHAsset];
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.synchronous = YES;
                options.networkAccessAllowed = YES;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                
                if ([mimeType isEqualToString:@"image/gif"]) {
                    [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                        if (imageData != nil) {
                            [strongSelf sendImageFileMessageWithImageData:imageData imageName:imageName mimeType:mimeType];
                        }
                    }];
                }
                else {
                    [[PHImageManager defaultManager] requestImageForAsset:imageAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        if (result != nil) {
                            NSData *imageData = UIImageJPEGRepresentation(result, 1.0);
                            if (imageData != nil) {
                                [strongSelf sendImageFileMessageWithImageData:imageData imageName:imageName mimeType:mimeType];
                            }
                        }
                    }];
                }
            }
            else {
                UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
                NSData *imageData = UIImageJPEGRepresentation(originalImage, 1.0);
                if (imageData != nil) {
                    [strongSelf sendImageFileMessageWithImageData:imageData imageName:@"image.jpg" mimeType:@"image/jpeg"];
                }
            }
        }
        else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            [strongSelf sendVideoFileMessage:info];
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
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle {
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage {
    // Use when `applyMaskToCroppedImage` set to YES.
}

#pragma mark - SBDNetworkDelegate
- (void)didReconnect {
    [self loadPreviousMessages:YES];
    [self.channel refreshWithCompletionHandler:nil];
}

#pragma mark - OpenChannelSettingsDelegate
- (void)didUpdateOpenChannel {
    self.title = self.channel.name;
    self.channelUpdated = YES;
}

- (void)inputMessageTextFieldChanged:(id)sender {
    if ([sender isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)sender;
        if (textField.text.length > 0) {
            self.sendUserMessageButton.enabled = YES;
        }
        else {
            self.sendUserMessageButton.enabled = NO;
        }
    }
}


#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    if (urls.count > 0) {
        NSURL *fileURL = urls[0];
        NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
        NSString *filename = [fileURL lastPathComponent];
        
        NSString *ext = [filename pathExtension];
        NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
        NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);

        __block SBDFileMessage *preSendMessage = [self.channel sendFileMessageWithBinaryData:fileData filename:filename type:mimeType size:fileData.length thumbnailSizes:nil data:nil customType:nil progressHandler:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.fileTrasnferProgress[preSendMessage.requestId] = @((CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend);
                for (NSInteger index = self.messages.count - 1; index >= 0; index--) {
                    SBDBaseMessage *baseMessage = self.messages[index];
                    if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
                        SBDFileMessage *fileMesssage = (SBDFileMessage *)baseMessage;
                        if (fileMesssage.requestId != nil && [fileMesssage.requestId isEqualToString:preSendMessage.requestId]) {
                            [self determineScrollLock];
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                            [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }
                }
            });
        } completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                SBDFileMessage *preSendMessage = (SBDFileMessage *)self.preSendMessages[fileMessage.requestId];
                [self.preSendMessages removeObjectForKey:fileMessage.requestId];
                
                if (error != nil) {
                    self.resendableMessages[fileMessage.requestId] = preSendMessage;
                    self.resendableFileData[preSendMessage.requestId] = @{
                                                                                @"data": fileData,
                                                                                @"type": mimeType,
                                                                                @"filename": filename,
                                                                                };
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self determineScrollLock];
                        [self.messageTableView reloadData];
                        [self scrollToBottomWithForce:NO];
                    });
                    
                    return;
                }
                
                if (fileMessage != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.resendableMessages removeObjectForKey:fileMessage.requestId];
                        [self.resendableFileData removeObjectForKey:fileMessage.requestId];
                        [self.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:fileMessage];
                        
                        [self determineScrollLock];
                        [self.messageTableView reloadData];
                    });
                }
            });
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fileTrasnferProgress[preSendMessage.requestId] = @(0);
            self.preSendFileData[preSendMessage.requestId] = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                     @"data": fileData,
                                                                                                                     @"type": mimeType,
                                                                                                                     @"filename": filename,
                                                                                                                     }];
            [self determineScrollLock];
            self.preSendMessages[preSendMessage.requestId] = preSendMessage;
            [self.messages addObject:preSendMessage];
            [self.messageTableView reloadData];
            
            [self scrollToBottomWithForce:NO];
        });
    }
}

- (void)deleteMessageFromTableView:(long long)messageId {
    for (NSInteger i = 0; i < self.messages.count; i++) {
        SBDBaseMessage *msg = self.messages[i];
        if (msg.messageId == messageId) {
            [self determineScrollLock];
            [self.messages removeObject:msg];
            [self.messageTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.messageTableView layoutIfNeeded];
            [self scrollToBottomWithForce:NO];
            
            break;
        }
    }
}

- (void)playMediaWithUrl:(NSURL *)url {
    AVPlayer *player = [[AVPlayer alloc] initWithURL:url];
    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
    vc.player = player;
    [self presentViewController:vc animated:YES completion:^{
        [player play];
    }];
}

- (void)sendImageFileMessageWithImageData:(NSData *)imageData imageName:(NSString *)imageName mimeType:(NSString *)mimeType {
    // success, data is in imageData
    /***********************************/
    /* Thumbnail is a premium feature. */
    /***********************************/
    SBDThumbnailSize *thumbnailSize = [SBDThumbnailSize makeWithMaxWidth:320.0 maxHeight:320.0];
    
    __block SBDFileMessage *preSendMessage = [self.channel sendFileMessageWithBinaryData:imageData filename:imageName type:mimeType size:imageData.length thumbnailSizes:@[thumbnailSize] data:nil customType:nil progressHandler:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.sendingImageVideoMessage[preSendMessage.requestId] == nil || [self.sendingImageVideoMessage[preSendMessage.requestId] isKindOfClass:[NSNull class]]) {
                self.sendingImageVideoMessage[preSendMessage.requestId] = @(NO);
            }
            self.fileTrasnferProgress[preSendMessage.requestId] = @((CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend);
            for (NSInteger index = self.messages.count - 1; index >= 0; index--) {
                SBDBaseMessage *baseMessage = self.messages[index];
                if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
                    SBDFileMessage *fileMesssage = (SBDFileMessage *)baseMessage;
                    if (fileMesssage.requestId != nil && [fileMesssage.requestId isEqualToString:preSendMessage.requestId]) {
                        [self determineScrollLock];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        if ([self.sendingImageVideoMessage[preSendMessage.requestId] boolValue] == NO) {
                            [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                            self.sendingImageVideoMessage[preSendMessage.requestId] = @(YES);
                            [self scrollToBottomWithForce:NO];
                        }
                        else {
                            OpenChannelImageVideoFileMessageTableViewCell *cell = [self.messageTableView cellForRowAtIndexPath:indexPath];
                            [cell showProgress:(CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend];
                        }
                        
                        break;
                    }
                }
            }
        });
    } completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            SBDFileMessage *preSendMessage = (SBDFileMessage *)self.preSendMessages[fileMessage.requestId];
            
            [self.preSendMessages removeObjectForKey:fileMessage.requestId];
            [self.sendingImageVideoMessage removeObjectForKey:fileMessage.requestId];
            
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resendableMessages[fileMessage.requestId] = preSendMessage;
                    self.resendableFileData[preSendMessage.requestId] = @{
                                                                                @"data": imageData,
                                                                                @"type": mimeType,
                                                                                @"filename": imageName,
                                                                                };
                    [self.messageTableView reloadData];
                    [self scrollToBottomWithForce:YES];
                });
                
                return;
            }
            
            if (fileMessage != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self determineScrollLock];
                    [self.resendableMessages removeObjectForKey:fileMessage.requestId];
                    [self.resendableFileData removeObjectForKey:fileMessage.requestId];
                    [self.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:fileMessage];
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.messages indexOfObject:fileMessage] inSection:0];
                    [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self scrollToBottomWithForce:NO];
                });
            }
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self determineScrollLock];
        self.fileTrasnferProgress[preSendMessage.requestId] = @(0);
        self.preSendFileData[preSendMessage.requestId] = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                 @"data": imageData,
                                                                                                                 @"type": mimeType,
                                                                                                                 @"filename": imageName,
                                                                                                                 }];
        self.preSendMessages[preSendMessage.requestId] = preSendMessage;
        [self.messages addObject:preSendMessage];
        [self.messageTableView reloadData];
        [self scrollToBottomWithForce:NO];
    });
}

- (void)sendVideoFileMessage:(NSDictionary *)info {
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSData *videoFileData = [NSData dataWithContentsOfURL:videoURL];
    NSString *videoName = [videoURL lastPathComponent];
    
    NSString *ext = [videoName pathExtension];
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    
    // success, data is in imageData
    /***********************************/
    /* Thumbnail is a premium feature. */
    /***********************************/
    SBDThumbnailSize *thumbnailSize = [SBDThumbnailSize makeWithMaxWidth:320.0 maxHeight:320.0];
    
    __block SBDFileMessage *preSendMessage = [self.channel sendFileMessageWithBinaryData:videoFileData filename:videoName type:mimeType size:videoFileData.length thumbnailSizes:@[thumbnailSize] data:nil customType:nil progressHandler:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.sendingImageVideoMessage[preSendMessage.requestId] == nil || [self.sendingImageVideoMessage[preSendMessage.requestId] isKindOfClass:[NSNull class]]) {
                self.sendingImageVideoMessage[preSendMessage.requestId] = @(NO);
            }
            self.fileTrasnferProgress[preSendMessage.requestId] = @((CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend);
            for (NSInteger index = self.messages.count - 1; index >= 0; index--) {
                SBDBaseMessage *baseMessage = self.messages[index];
                if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
                    SBDFileMessage *fileMesssage = (SBDFileMessage *)baseMessage;
                    if (fileMesssage.requestId != nil && [fileMesssage.requestId isEqualToString:preSendMessage.requestId]) {
                        [self determineScrollLock];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        if ([self.sendingImageVideoMessage[preSendMessage.requestId] boolValue] == NO) {
                            [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                            self.sendingImageVideoMessage[preSendMessage.requestId] = @(YES);
                            [self scrollToBottomWithForce:NO];
                        }
                        else {
                            OpenChannelImageVideoFileMessageTableViewCell *cell = [self.messageTableView cellForRowAtIndexPath:indexPath];
                            [cell showProgress:(CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend];
                        }
                        
                        break;
                    }
                }
            }
        });
    } completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            SBDFileMessage *preSendMessage = (SBDFileMessage *)self.preSendMessages[fileMessage.requestId];
            
            [self.preSendMessages removeObjectForKey:fileMessage.requestId];
            [self.sendingImageVideoMessage removeObjectForKey:fileMessage.requestId];
            
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resendableMessages[fileMessage.requestId] = preSendMessage;
                    self.resendableFileData[preSendMessage.requestId] = @{
                                                                                @"data": videoFileData,
                                                                                @"type": mimeType,
                                                                                @"filename": videoName,
                                                                                };
                    [self.messageTableView reloadData];
                    [self scrollToBottomWithForce:YES];
                });
                
                return;
            }
            
            if (fileMessage != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self determineScrollLock];
                    [self.resendableMessages removeObjectForKey:fileMessage.requestId];
                    [self.resendableFileData removeObjectForKey:fileMessage.requestId];
                    [self.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:fileMessage];
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.messages indexOfObject:fileMessage] inSection:0];
                    [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self scrollToBottomWithForce:NO];
                });
            }
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.fileTrasnferProgress[preSendMessage.requestId] = @(0);
        self.preSendFileData[preSendMessage.requestId] = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                 @"data": videoFileData,
                                                                                                                 @"type": mimeType,
                                                                                                                 @"filename": videoName,
                                                                                                                 }];
        [self determineScrollLock];
        self.preSendMessages[preSendMessage.requestId] = preSendMessage;
        [self.messages addObject:preSendMessage];
        [self.messageTableView reloadData];
        
        [self scrollToBottomWithForce:NO];
    });
}

@end
