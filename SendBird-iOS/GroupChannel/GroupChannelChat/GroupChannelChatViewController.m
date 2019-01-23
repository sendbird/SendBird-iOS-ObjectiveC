//
//  GroupChannelChatViewController.m
//  SendBird-iOS
//
//  Created by SendBird on 2/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelChatViewController.h"
#import "CreateGroupChannelNavigationController.h"
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
#import "GroupChannelIncomingUserMessageTableViewCell.h"
#import "GroupChannelIncomingImageVideoFileMessageTableViewCell.h"
#import "GroupChannelOutgoingUserMessageTableViewCell.h"
#import "GroupChannelNeutralAdminMessageTableViewCell.h"
#import "GroupChannelOutgoingImageVideoFileMessageTableViewCell.h"
#import "GroupChannelIncomingGeneralFileMessageTableViewCell.h"
#import "GroupChannelOutgoingGeneralFileMessageTableViewCell.h"
#import "GroupChannelOutgoingAudioFileMessageTableViewCell.h"
#import "GroupChannelIncomingAudioFileMessageTableViewCell.h"
#import "GroupChannelSettingsViewController.h"
#import "UserProfileViewController.h"
#import "Utils.h"
#import "DownloadManager.h"
#import "UIViewController+Utils.h"
#import "GroupChannelsViewController.h"
#import "CreateGroupChannelViewControllerB.h"

@interface GroupChannelChatViewController ()

@property (weak, nonatomic) IBOutlet UITableView *messageTableView;

@property (weak, nonatomic) IBOutlet UIView *typingIndicatorContainerView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *typingIndicatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *typingIndicatorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typingIndicatorContainerViewHeight;

@property (atomic) BOOL keyboardShown;
@property (atomic) CGFloat keyboardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTableViewBottomMargin;

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
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSObject *> *> *preSendFileData;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *resendableFileData;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *fileTrasnferProgress;

@property (strong) SBDBaseMessage *selectedMessage;

@property (strong) NSTimer *typingIndicatorTimer;

@property (strong, nonatomic) UIBarButtonItem *settingBarButton;

@property (atomic) BOOL pickerControllerOpened;

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *sendingImageVideoMessage;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *sendingAudioGeneralFileMessage;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *loadedImageHash;

@property (atomic) NSInteger rowRecalculateHeightCell;

@end

@implementation GroupChannelChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sendingImageVideoMessage = [[NSMutableDictionary alloc] init];
    self.sendingAudioGeneralFileMessage = [[NSMutableDictionary alloc] init];
    self.loadedImageHash = [[NSMutableDictionary alloc] init];
    
    self.rowRecalculateHeightCell = -1;
    
    self.pickerControllerOpened = NO;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;

    self.settingBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"img_btn_channel_settings"] style:UIBarButtonItemStylePlain target:self action:@selector(clickSettingBarButton:)];
    self.navigationItem.rightBarButtonItem = self.settingBarButton;
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = nil;
    
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    self.typingIndicatorTimer = nil;
    self.keyboardHeight = 0;
    
    [SBDMain addChannelDelegate:self identifier:self.description];
    [SBDMain addConnectionDelegate:self identifier:self.description];
    
    // TODO: Fix bug in SDK.
    [SBDConnectionManager addNetworkDelegate:self identifier:self.description];
    
    self.resendableMessages = [[NSMutableDictionary alloc] init];
    self.preSendMessages = [[NSMutableDictionary alloc] init];
    self.resendableFileData = [[NSMutableDictionary alloc] init];
    self.preSendFileData = [[NSMutableDictionary alloc] init];
    self.fileTrasnferProgress = [[NSMutableDictionary alloc] init];
    
    self.title = [Utils createGroupChannelName:self.channel];

    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"loading_typing" ofType:@"gif"]]];
    self.typingIndicatorImageView.animatedImage = image;
    
    self.typingIndicatorContainerView.hidden = YES;
    
    self.messageTableView.rowHeight = UITableViewAutomaticDimension;
    self.messageTableView.estimatedRowHeight = 140;
    self.messageTableView.delegate = self;
    self.messageTableView.dataSource = self;
    self.messageTableView.contentInset = UIEdgeInsetsMake(0, 0, 14, 0);
    [self.messageTableView registerNib:[UINib nibWithNibName:@"GroupChannelIncomingUserMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelIncomingUserMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"GroupChannelIncomingImageVideoFileMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelIncomingImageFileMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"GroupChannelIncomingImageVideoFileMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelIncomingVideoFileMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"GroupChannelOutgoingUserMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelOutgoingUserMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"GroupChannelNeutralAdminMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelNeutralAdminMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"GroupChannelOutgoingImageVideoFileMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelOutgoingImageFileMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"GroupChannelOutgoingImageVideoFileMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelOutgoingVideoFileMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"GroupChannelOutgoingGeneralFileMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelOutgoingGeneralFileMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"GroupChannelIncomingGeneralFileMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelIncomingGeneralFileMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"GroupChannelOutgoingAudioFileMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelOutgoingAudioFileMessageTableViewCell"];
    [self.messageTableView registerNib:[UINib nibWithNibName:@"GroupChannelIncomingAudioFileMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupChannelIncomingAudioFileMessageTableViewCell"];
    

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.view bringSubviewToFront:self.loadingIndicatorView];
    self.loadingIndicatorView.hidden = YES;
    
    self.messages = [[NSMutableArray alloc] init];

    [self loadPreviousMessages:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [SBDConnectionManager removeNetworkDelegateForIdentifier:self.description];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        if ([self.navigationController isKindOfClass:[CreateGroupChannelNavigationController class]] && ![self.navigationController.topViewController isKindOfClass:[GroupChannelSettingsViewController class]]) {
            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        }
        else {
            [super viewWillDisappear:animated];
        }
        
        [SBDMain removeChannelDelegateForIdentifier:self.description];
    }
    else {
        [super viewWillDisappear:animated];
    }
    
//    if (!self.pickerControllerOpened && [self.navigationController isKindOfClass:[CreateGroupChannelNavigationController class]] && ![self.navigationController.topViewController isKindOfClass:[GroupChannelSettingsViewController class]]) {
//        [SBDMain removeChannelDelegateForIdentifier:@"GroupChannelChatViewController"];
//        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
//    }
//    else {
//        [super viewWillDisappear:animated];
//    }
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

#pragma mark - NotificationDelegate
- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    if ([channelUrl isEqualToString:self.channel.channelUrl]) {
        return;
    }
    [self.navigationController popViewControllerAnimated:NO];
    UIViewController *cvc = [UIViewController currentViewController];
    if ([cvc isKindOfClass:[GroupChannelsViewController class]]) {
        [((GroupChannelsViewController *)cvc) openChatWithChannelUrl:channelUrl];
    }
    else if ([cvc isKindOfClass:[CreateGroupChannelViewControllerB class]]) {
        [((CreateGroupChannelViewControllerB *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)clickSettingBarButton:(id)sender {
    GroupChannelSettingsViewController *vc = [[GroupChannelSettingsViewController alloc] initWithNibName:@"GroupChannelSettingsViewController" bundle:nil];
    vc.delegate = self;
    vc.channel = self.channel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)hideTypingIndicator:(NSTimer *)timer {
    [self.typingIndicatorTimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.typingIndicatorContainerView.hidden = YES;
        self.messageTableViewBottomMargin.constant = 0;
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
        
        self.stopMeasuringVelocity = YES;
        [self determineScrollLock];
        [self scrollToBottomWithForce:NO];
    });
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
            [self.channel markAsRead];
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(updateGroupChannelList)]) {
                [self.delegate updateGroupChannelList];
            }
            
            if (messages.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.messages removeAllObjects];
                    
                    for (SBDBaseMessage *message in messages) {
                        [self.messages addObject:message];
                        
                        if (self.minMessageTimestamp > message.createdAt) {
                            self.minMessageTimestamp = message.createdAt;
                        }
                    }
                    
                    if (self.resendableMessages != nil && self.resendableMessages.count > 0) {
                        for (SBDBaseMessage *message in self.resendableMessages.allValues) {
                            [self.messages addObject:message];
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
                    NSMutableArray<NSIndexPath *> *messageIndexPathes = [[NSMutableArray alloc] init];
                    NSInteger row = 0;
                    for (SBDBaseMessage *message in messages) {
                        [self.messages insertObject:message atIndex:0];
                        if (self.minMessageTimestamp > message.createdAt) {
                            self.minMessageTimestamp = message.createdAt;
                        }
                        
                        [messageIndexPathes addObject:[NSIndexPath indexPathForRow:row inSection:0]];
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
    
    self.keyboardShown = YES;
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.keyboardHeight = keyboardFrameBeginRect.size.height;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.inputMessageInnerContainerViewBottomMargin.constant = self.keyboardHeight - self.view.safeAreaInsets.bottom;
        [self.view layoutIfNeeded];
        
        self.stopMeasuringVelocity = YES;
        [self scrollToBottomWithForce:NO];
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
}

- (IBAction)clickSendUserMessageButton:(id)sender {
    if (self.inputMessageTextField.text.length == 0) {
        return;
    }
    
    NSString *messageText = self.inputMessageTextField.text;
    __block SBDUserMessage *preSendMessage = [self.channel sendUserMessage:messageText completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
        self.inputMessageTextField.text = @"";
        self.sendUserMessageButton.enabled = NO;
        [self.channel endTyping];
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self determineScrollLock];
                [self.preSendMessages removeObjectForKey:preSendMessage.requestId];
                self.resendableMessages[preSendMessage.requestId] = preSendMessage;
                [self.messageTableView reloadData];
                [self scrollToBottomWithForce:NO];
            });
            
            return;
        }
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(updateGroupChannelList)]) {
            [self.delegate updateGroupChannelList];
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
            self.pickerControllerOpened = YES;
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
            self.pickerControllerOpened = YES;
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
            self.pickerControllerOpened = YES;
            UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
            documentPicker.allowsMultipleSelection = NO;
            documentPicker.delegate = self;
            [self presentViewController:documentPicker animated:YES completion:nil];
        });
    }];
    
    UIAlertAction *chooseFromLibraryAction = [UIAlertAction actionWithTitle:@"Choose from Media Library..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pickerControllerOpened = YES;
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

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    SBDBaseMessage *prevMessage = nil;
    SBDBaseMessage *nextMessage = nil;
    if (indexPath.row > 0) {
        prevMessage = self.messages[indexPath.row - 1];
    }
    if (indexPath.row + 1 < self.messages.count) {
        nextMessage = self.messages[indexPath.row + 1];
    }
    
    if ([self.messages[indexPath.row] isKindOfClass:[SBDAdminMessage class]]) {
        // Admin Message
        SBDAdminMessage *adminMessage = (SBDAdminMessage *)self.messages[indexPath.row];
        GroupChannelNeutralAdminMessageTableViewCell *adminMessageCell = (GroupChannelNeutralAdminMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelNeutralAdminMessageTableViewCell"];
//        SBDBaseMessage *prevMessage = nil;
//        if (indexPath.row > 0) {
//            prevMessage = self.messages[indexPath.row - 1];
//        }
        [adminMessageCell setCurrentMessage:adminMessage previousMessage:prevMessage];
        adminMessageCell.delegate = self;
        cell = (UITableViewCell *)adminMessageCell;
    }
    else if ([self.messages[indexPath.row] isKindOfClass:[SBDUserMessage class]]) {
        SBDUserMessage *userMessage = (SBDUserMessage *)self.messages[indexPath.row];
        if ([userMessage.sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            // Outgoing User Message
            GroupChannelOutgoingUserMessageTableViewCell *userMessageCell = (GroupChannelOutgoingUserMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingUserMessageTableViewCell"];
            userMessageCell.delegate = self;
            userMessageCell.channel = self.channel;

            BOOL failed = NO;
            if (userMessage.requestId != nil && self.resendableMessages[userMessage.requestId] != nil) {
                failed = YES;
            }
            
            [userMessageCell setCurrentMessage:userMessage previousMessage:prevMessage nextMessage:nextMessage failed:failed];
        
            cell = (UITableViewCell *)userMessageCell;
        }
        else {
            // Incoming User Message
            GroupChannelIncomingUserMessageTableViewCell *userMessageCell = (GroupChannelIncomingUserMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelIncomingUserMessageTableViewCell"];
            userMessageCell.delegate = self;
            [userMessageCell setCurrentMessage:userMessage previousMessage:prevMessage nextMessage:nextMessage];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UITableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];
                if (updateCell != nil && [updateCell isKindOfClass:[GroupChannelIncomingUserMessageTableViewCell class]]) {
                    [((GroupChannelIncomingUserMessageTableViewCell *)updateCell).profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:userMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:userMessage.sender]];
                }
            });
            
            cell = (UITableViewCell *)userMessageCell;
        }
    }
    else if ([self.messages[indexPath.row] isKindOfClass:[SBDFileMessage class]]) {
        // File Message
        SBDFileMessage *fileMessage = (SBDFileMessage *)self.messages[indexPath.row];
        if (self.preSendMessages[fileMessage.requestId] != nil) {
            // Pre send outgoing message
            NSMutableDictionary *fileDataDict = self.preSendFileData[fileMessage.requestId];
            if (fileDataDict != nil) {
                if ([fileDataDict[@"type"] hasPrefix:@"image"]) {
                    // Outgoing image file message
                    GroupChannelOutgoingImageVideoFileMessageTableViewCell *imageFileMessageCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingImageFileMessageTableViewCell"];
                    [imageFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage];
                    [imageFileMessageCell hideReadStatus];
                    [imageFileMessageCell hideElementsForFailure];
                    [imageFileMessageCell showBottomMargin];
                    [imageFileMessageCell hideAllPlaceholders];
                    if (self.fileTrasnferProgress[fileMessage.requestId] != nil) {
                        CGFloat progress = [[self.fileTrasnferProgress objectForKey:fileMessage.requestId] doubleValue];
                        [imageFileMessageCell showProgress:progress];
                    }

                    if ([fileDataDict[@"type"] isEqualToString:@"image/gif"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            GroupChannelOutgoingImageVideoFileMessageTableViewCell *updateCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                NSData *imageData = fileDataDict[@"data"];
                                updateCell.imageFileMessageImageView.image = nil;
                                [updateCell setAnimatedImage:[FLAnimatedImage animatedImageWithGIFData:imageData] hash:imageData.hash];
                            }
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            GroupChannelOutgoingImageVideoFileMessageTableViewCell *updateCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                NSData *imageData = fileDataDict[@"data"];
                                updateCell.imageFileMessageImageView.image = nil;
                                [updateCell setAnimatedImage:nil hash:0];
                                [updateCell.imageFileMessageImageView setImage:[UIImage imageWithData:imageData]];
                            }
                        });
                    }

                    cell = (UITableViewCell *)imageFileMessageCell;
                }
                else if ([fileDataDict[@"type"] hasPrefix:@"video"]) {
                    // Outgoing video file message
                    GroupChannelOutgoingImageVideoFileMessageTableViewCell *videoFileMessageCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingVideoFileMessageTableViewCell"];
                    [videoFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage];
                    [videoFileMessageCell hideReadStatus];
                    [videoFileMessageCell hideElementsForFailure];
                    [videoFileMessageCell showBottomMargin];
                    [videoFileMessageCell hideAllPlaceholders];
                    videoFileMessageCell.videoMessagePlaceholderImageView.hidden = NO;
                    
                    videoFileMessageCell.imageFileMessageImageView.image = nil;
                    videoFileMessageCell.imageFileMessageImageView.animatedImage = nil;
                    
                    if (self.fileTrasnferProgress[fileMessage.requestId] != nil) {
                        CGFloat progress = [[self.fileTrasnferProgress objectForKey:fileMessage.requestId] doubleValue];
                        [videoFileMessageCell showProgress:progress];
                    }
                    cell = (UITableViewCell *)videoFileMessageCell;
                }
                else if ([fileDataDict[@"type"] hasPrefix:@"audio"]) {
                    // Outgoing audio file message
                    GroupChannelOutgoingAudioFileMessageTableViewCell *audioFileMessageCell = (GroupChannelOutgoingAudioFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingAudioFileMessageTableViewCell"];
                    
                    [audioFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage failed:NO];
                    audioFileMessageCell.delegate = nil;
                    [audioFileMessageCell hideReadStatus];
                    [audioFileMessageCell hideElementsForFailure];
                    [audioFileMessageCell showBottomMargin];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        GroupChannelOutgoingAudioFileMessageTableViewCell *updateCell = (GroupChannelOutgoingAudioFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            if (self.fileTrasnferProgress[fileMessage.requestId] != nil) {
                                CGFloat progress = [[self.fileTrasnferProgress objectForKey:fileMessage.requestId] doubleValue];
                                [updateCell showProgress:progress];
                            }
                        }
                    });
                    
                    cell = (UITableViewCell *)audioFileMessageCell;
                }
                else {
                    // Outgoing general file message
                    GroupChannelOutgoingGeneralFileMessageTableViewCell *generalFileMessageCell = (GroupChannelOutgoingGeneralFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingGeneralFileMessageTableViewCell"];
                    
                    [generalFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage failed:NO];
                    generalFileMessageCell.delegate = nil;
                    cell = (UITableViewCell *)generalFileMessageCell;

                    dispatch_async(dispatch_get_main_queue(), ^{
                        GroupChannelOutgoingGeneralFileMessageTableViewCell *updateCell = (GroupChannelOutgoingGeneralFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            if (self.fileTrasnferProgress[fileMessage.requestId] != nil) {
                                CGFloat progress = [[self.fileTrasnferProgress objectForKey:fileMessage.requestId] doubleValue];
                                [updateCell showProgress:progress];
                            }
                        }
                    });
                }
            }
        }
        else if (self.resendableFileData[fileMessage.requestId] != nil) {
            NSDictionary *fileDataDict = self.resendableFileData[fileMessage.requestId];
            if (fileDataDict != nil) {
                if ([fileDataDict[@"type"] hasPrefix:@"image"]) {
                    // Failed outgoing image file message
                    GroupChannelOutgoingImageVideoFileMessageTableViewCell *imageFileMessageCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingImageFileMessageTableViewCell"];
                    [imageFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage];
                    [imageFileMessageCell hideReadStatus];
                    [imageFileMessageCell hideProgress];
                    [imageFileMessageCell showElementsForFailure];
                    [imageFileMessageCell showBottomMargin];
                    [imageFileMessageCell hideAllPlaceholders];
                    imageFileMessageCell.delegate = self;

                    if ([fileDataDict[@"type"] isEqualToString:@"image/gif"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            GroupChannelOutgoingImageVideoFileMessageTableViewCell *updateCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                NSData *imageData = fileDataDict[@"data"];
                                updateCell.imageFileMessageImageView.image = nil;
                                [updateCell setAnimatedImage:[FLAnimatedImage animatedImageWithGIFData:imageData] hash:imageData.hash];
                            }
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            GroupChannelOutgoingImageVideoFileMessageTableViewCell *updateCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                NSData *imageData = fileDataDict[@"data"];
                                updateCell.imageFileMessageImageView.image = nil;
                                [updateCell setAnimatedImage:nil hash:0];
                                [updateCell.imageFileMessageImageView setImage:[UIImage imageWithData:imageData]];
                            }
                        });
                    }
                    
                    cell = (UITableViewCell *)imageFileMessageCell;
                }
                else if ([fileDataDict[@"type"] hasPrefix:@"video"]) {
                    // Failed outgoing image file message
                    GroupChannelOutgoingImageVideoFileMessageTableViewCell *videoFileMessageCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingVideoFileMessageTableViewCell"];
                    [videoFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage];
                    [videoFileMessageCell hideReadStatus];
                    [videoFileMessageCell hideProgress];
                    [videoFileMessageCell showElementsForFailure];
                    [videoFileMessageCell showBottomMargin];
                    [videoFileMessageCell hideAllPlaceholders];
                    videoFileMessageCell.videoMessagePlaceholderImageView.hidden = NO;
                    videoFileMessageCell.delegate = self;

                    cell = (UITableViewCell *)videoFileMessageCell;
                }
                else if ([fileDataDict[@"type"] hasPrefix:@"audio"]) {
                    // Failed outgoing audio file message
                    GroupChannelOutgoingAudioFileMessageTableViewCell *audioFileMessageCell = (GroupChannelOutgoingAudioFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingAudioFileMessageTableViewCell"];
                    [audioFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage failed:YES];
                    [audioFileMessageCell hideReadStatus];
                    [audioFileMessageCell hideProgress];
                    [audioFileMessageCell showElementsForFailure];
                    [audioFileMessageCell showBottomMargin];
                    audioFileMessageCell.delegate = self;
                    
                    cell = audioFileMessageCell;
                }
                else {
                    // Failed outgoing general file message
                    GroupChannelOutgoingGeneralFileMessageTableViewCell *generalFileMessageCell = (GroupChannelOutgoingGeneralFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingGeneralFileMessageTableViewCell"];
                    [generalFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage failed:YES];
                    [generalFileMessageCell hideReadStatus];
                    [generalFileMessageCell hideProgress];
                    [generalFileMessageCell showElementsForFailure];
                    [generalFileMessageCell showBottomMargin];
                    generalFileMessageCell.delegate = self;
                    
                    cell = generalFileMessageCell;
                }
            }
        }
        else {
            if ([fileMessage.sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                // Outgoing file message
                if ([fileMessage.type hasPrefix:@"image"]) {
                    GroupChannelOutgoingImageVideoFileMessageTableViewCell *imageFileMessageCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingImageFileMessageTableViewCell"];
                    imageFileMessageCell.delegate = self;
                    imageFileMessageCell.channel = self.channel;
                    
                    [imageFileMessageCell hideElementsForFailure];
                    [imageFileMessageCell hideAllPlaceholders];
                    
                    [imageFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage];
                    
                    if (self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] == nil || [self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] longLongValue] != imageFileMessageCell.imageHash) {
                        imageFileMessageCell.imageMessagePlaceholderImageView.hidden = NO;
                        [imageFileMessageCell setImage:nil];
                        [imageFileMessageCell setAnimatedImage:nil hash:0];
                    }
                    
                    cell = (UITableViewCell *)imageFileMessageCell;
                    if ([fileMessage.type hasPrefix:@"image/gif"]) {
                        [imageFileMessageCell.imageFileMessageImageView setAnimatedImageWithURL:[NSURL URLWithString:fileMessage.url] success:^(FLAnimatedImage * _Nullable image, NSUInteger hash) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                GroupChannelOutgoingImageVideoFileMessageTableViewCell *updateCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
                                    [updateCell hideAllPlaceholders];
                                    [updateCell setAnimatedImage:image hash:hash];
                                    self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] = @(hash);
                                }
                            });
                        } failure:^(NSError * _Nullable error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                GroupChannelOutgoingImageVideoFileMessageTableViewCell *updateCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
                                    [updateCell hideAllPlaceholders];
                                    updateCell.imageMessagePlaceholderImageView.hidden = NO;
                                    [updateCell setImage:nil];
                                    [updateCell setAnimatedImage:nil hash:0];
                                    [self.loadedImageHash removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                                }
                            });
                        }];
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            GroupChannelOutgoingImageVideoFileMessageTableViewCell *updateCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if ([updateCell isKindOfClass:[GroupChannelOutgoingImageVideoFileMessageTableViewCell class]]) {
                                if (fileMessage.thumbnails != nil && fileMessage.thumbnails.count > 0) {
//                                    __weak GroupChannelOutgoingImageVideoFileMessageTableViewCell *weakCell = updateCell;
                                    NSLog(@"(%ld) Image URL: %@", indexPath.row, fileMessage.thumbnails[0].url);
//                                    [updateCell.imageFileMessageImageView setImageWithURL:[NSURL URLWithString:fileMessage.thumbnails[0].url] placeholderImage:nil];
                                    [updateCell.imageFileMessageImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fileMessage.thumbnails[0].url]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//                                        __strong GroupChannelOutgoingImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                        [updateCell hideAllPlaceholders];
                                        NSLog(@"(%ld) Image URL: %ld", indexPath.row, image.hash);
                                        [updateCell setImage:image];
//                                        updateCell.imageFileMessageImageView.image = image;
                                        self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] = @(UIImageJPEGRepresentation(image, 0.5).hash);
                                    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
//                                        __strong GroupChannelOutgoingImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                        [updateCell hideAllPlaceholders];
                                        updateCell.imageMessagePlaceholderImageView.hidden = NO;
                                        [updateCell setImage:nil];
                                        [updateCell setAnimatedImage:nil hash:0];
                                        [self.loadedImageHash removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                                    }];
                                }
                                else {
                                    __weak GroupChannelOutgoingImageVideoFileMessageTableViewCell *weakCell = updateCell;
                                    [updateCell.imageFileMessageImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fileMessage.url]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                        __strong GroupChannelOutgoingImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                        [strongCell hideAllPlaceholders];
                                        [strongCell setImage:image];
                                        self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] = @(UIImageJPEGRepresentation(image, 0.5).hash);
                                    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                        __strong GroupChannelOutgoingImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                        [strongCell hideAllPlaceholders];
                                        strongCell.imageMessagePlaceholderImageView.hidden = NO;
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
                    GroupChannelOutgoingImageVideoFileMessageTableViewCell *videoFileMessageCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingVideoFileMessageTableViewCell"];
                    
                    videoFileMessageCell.delegate = self;
                    
                    if (videoFileMessageCell.imageHash == 0 || videoFileMessageCell.imageFileMessageImageView.image == nil) {
                        [videoFileMessageCell setAnimatedImage:nil hash:0];
                        [videoFileMessageCell setImage:nil];
                    }
                    
                    [videoFileMessageCell hideAllPlaceholders];
                    
                    videoFileMessageCell.channel = self.channel;
                    [videoFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage];
                    
                    if (self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] == nil || [self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] longLongValue] != videoFileMessageCell.imageHash) {
                        videoFileMessageCell.videoMessagePlaceholderImageView.hidden = NO;
                        [videoFileMessageCell setImage:nil];
                        [videoFileMessageCell setAnimatedImage:nil hash:0];
                    }
                    
                    cell = (UITableViewCell *)videoFileMessageCell;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        GroupChannelOutgoingImageVideoFileMessageTableViewCell *updateCell = (GroupChannelOutgoingImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if ([updateCell isKindOfClass:[GroupChannelOutgoingImageVideoFileMessageTableViewCell class]]) {
                            if (fileMessage.thumbnails != nil && fileMessage.thumbnails.count > 0) {
                                __weak GroupChannelOutgoingImageVideoFileMessageTableViewCell *weakCell = updateCell;
                                [updateCell.imageFileMessageImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fileMessage.thumbnails[0].url]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                    __strong GroupChannelOutgoingImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                    [strongCell hideAllPlaceholders];
                                    strongCell.videoPlayIconImageView.hidden = NO;
                                    [strongCell setImage:image];
                                    self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] = @(UIImageJPEGRepresentation(image, 0.5).hash);
                                } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                    __strong GroupChannelOutgoingImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                    strongCell.videoPlayIconImageView.hidden = YES;
                                    strongCell.videoMessagePlaceholderImageView.hidden = NO;
                                    [videoFileMessageCell setAnimatedImage:nil hash:0];
                                    [videoFileMessageCell setImage:nil];
                                    [self.loadedImageHash removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                                }];
                            }
                            else {
                                // Without thumbnails.
                                [updateCell hideAllPlaceholders];
                                updateCell.videoMessagePlaceholderImageView.hidden = NO;
                                [updateCell setAnimatedImage:nil hash:0];
                                [updateCell setImage:nil];
                                [self.loadedImageHash removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                            }
                        }
                    });
                }
                else if ([fileMessage.type hasPrefix:@"audio"]) {
                    // Outgoing audio file message
                    GroupChannelOutgoingAudioFileMessageTableViewCell *audioFileMessageCell = (GroupChannelOutgoingAudioFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingAudioFileMessageTableViewCell"];
                    audioFileMessageCell.delegate = self;
                    audioFileMessageCell.channel = self.channel;
                    [audioFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage failed:NO];
                    [audioFileMessageCell showProgress:1.0];
                    
                    cell = (UITableViewCell *)audioFileMessageCell;
                }
                else {
                    // Outgoing general file message
                    GroupChannelOutgoingGeneralFileMessageTableViewCell *generalFileMessageCell = (GroupChannelOutgoingGeneralFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelOutgoingGeneralFileMessageTableViewCell"];
                    generalFileMessageCell.delegate = self;
                    generalFileMessageCell.channel = self.channel;
                    [generalFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage failed:NO];
                    [generalFileMessageCell showProgress:1.0];
                    
                    cell = (UITableViewCell *)generalFileMessageCell;
                }
            }
            else {
                if ([fileMessage.type hasPrefix:@"image"]) {
                    // Incoming image file message
                    GroupChannelIncomingImageVideoFileMessageTableViewCell *imageFileMessageCell = (GroupChannelIncomingImageVideoFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelIncomingImageFileMessageTableViewCell"];
                    [imageFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage];
                    imageFileMessageCell.delegate = self;
                    [imageFileMessageCell hideAllPlaceholders];
                    
                    if (self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] == nil || [self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] longLongValue] != imageFileMessageCell.imageHash) {
                        imageFileMessageCell.imageMessagePlaceholderImageView.hidden = NO;
                        [imageFileMessageCell setImage:nil];
                        [imageFileMessageCell setAnimatedImage:nil hash:0];
                    }
                    
                    cell = (UITableViewCell *)imageFileMessageCell;
                    if ([fileMessage.type isEqualToString:@"image/gif"]) {
                        [imageFileMessageCell.imageFileMessageImageView setAnimatedImageWithURL:[NSURL URLWithString:fileMessage.url] success:^(FLAnimatedImage * _Nullable image, NSUInteger hash) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                GroupChannelIncomingImageVideoFileMessageTableViewCell *updateCell = (GroupChannelIncomingImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
                                    [updateCell hideAllPlaceholders];
                                    [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                    [updateCell setAnimatedImage:image hash:hash];
                                    self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] = @(hash);
                                }
                            });
                        } failure:^(NSError * _Nullable error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                GroupChannelIncomingImageVideoFileMessageTableViewCell *updateCell = (GroupChannelIncomingImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
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
                            GroupChannelIncomingImageVideoFileMessageTableViewCell *updateCell = (GroupChannelIncomingImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if ([updateCell isKindOfClass:[GroupChannelIncomingImageVideoFileMessageTableViewCell class]]) {
                                [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                if (fileMessage.thumbnails != nil && fileMessage.thumbnails.count > 0) {
                                    __weak GroupChannelIncomingImageVideoFileMessageTableViewCell *weakCell = updateCell;
                                    [updateCell.imageFileMessageImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fileMessage.thumbnails[0].url]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                        __strong GroupChannelIncomingImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                        [strongCell hideAllPlaceholders];
                                        [strongCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                        [strongCell setImage:image];
                                        self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] = @(UIImageJPEGRepresentation(image, 0.5).hash);
                                    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                        __strong GroupChannelIncomingImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                        [strongCell hideAllPlaceholders];
                                        strongCell.imageMessagePlaceholderImageView.hidden = NO;
                                        [strongCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                        [strongCell setImage:nil];
                                        [strongCell setAnimatedImage:nil hash:0];
                                        [self.loadedImageHash removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                                    }];
                                }
                                else {
                                    // Without thumbnails.
                                    [updateCell hideAllPlaceholders];
                                    updateCell.videoMessagePlaceholderImageView.hidden = NO;
                                    [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                    [updateCell setAnimatedImage:nil hash:0];
                                    [updateCell setImage:nil];
                                    [self.loadedImageHash removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                                }
                            }
                        });
                    }
                }
                else if ([fileMessage.type hasPrefix:@"video"]) {
                    // Incoming video file message
                    GroupChannelIncomingImageVideoFileMessageTableViewCell *videoFileMessageCell = (GroupChannelIncomingImageVideoFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelIncomingVideoFileMessageTableViewCell"];
                    
                    videoFileMessageCell.delegate = self;
                    [videoFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage];
                    
                    [videoFileMessageCell hideAllPlaceholders];
                    
                    if (self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] == nil || [self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] longLongValue] != videoFileMessageCell.imageHash) {
                        videoFileMessageCell.videoMessagePlaceholderImageView.hidden = NO;
                        [videoFileMessageCell setImage:nil];
                        [videoFileMessageCell setAnimatedImage:nil hash:0];
                    }
                    
                    cell = (UITableViewCell *)videoFileMessageCell;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        GroupChannelIncomingImageVideoFileMessageTableViewCell *updateCell = (GroupChannelIncomingImageVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if ([updateCell isKindOfClass:[GroupChannelIncomingImageVideoFileMessageTableViewCell class]]) {
                            [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                            
                            if (fileMessage.thumbnails != nil && fileMessage.thumbnails.count > 0) {
                                __weak GroupChannelIncomingImageVideoFileMessageTableViewCell *weakCell = updateCell;
                                [updateCell.imageFileMessageImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fileMessage.thumbnails[0].url]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                    __strong GroupChannelIncomingImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                    [strongCell hideAllPlaceholders];
                                    strongCell.videoPlayIconImageView.hidden = NO;
                                    [strongCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                    [strongCell setImage:image];
                                    self.loadedImageHash[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] = @(UIImageJPEGRepresentation(image, 0.5).hash);
                                } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                    __strong GroupChannelIncomingImageVideoFileMessageTableViewCell *strongCell = weakCell;
                                    [strongCell hideAllPlaceholders];
                                    strongCell.videoMessagePlaceholderImageView.hidden = NO;
                                    [strongCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                                    [strongCell setImage:nil];
                                    [strongCell setAnimatedImage:nil hash:0];
                                    [self.loadedImageHash removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                                }];
                            }
                            else {
                                // Without thumbnails.
                                [updateCell hideAllPlaceholders];
                                updateCell.videoMessagePlaceholderImageView.hidden = NO;
                                [updateCell setAnimatedImage:nil hash:0];
                                [updateCell setImage:nil];
                                [self.loadedImageHash removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                            }
                        }
                    });
                }
                else if ([fileMessage.type hasPrefix:@"audio"]) {
                    // Incoming audio file message.
                    GroupChannelIncomingAudioFileMessageTableViewCell *audioFileMessageCell = (GroupChannelIncomingAudioFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelIncomingAudioFileMessageTableViewCell"];
                    audioFileMessageCell.delegate = self;
                    [audioFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        GroupChannelIncomingAudioFileMessageTableViewCell *updateCell = (GroupChannelIncomingAudioFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                        }
                    });
                    
                    cell = (UITableViewCell *)audioFileMessageCell;
                }
                else {
                    // Incoming general file message.
                    GroupChannelIncomingGeneralFileMessageTableViewCell *generalFileMessageCell = (GroupChannelIncomingGeneralFileMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupChannelIncomingGeneralFileMessageTableViewCell"];
                    generalFileMessageCell.delegate = self;
                    [generalFileMessageCell setCurrentMessage:fileMessage previousMessage:prevMessage nextMessage:nextMessage];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        GroupChannelIncomingGeneralFileMessageTableViewCell *updateCell = (GroupChannelIncomingGeneralFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                           [updateCell.profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:fileMessage.sender]] placeholderImage:[Utils getDefaultUserProfileImage:fileMessage.sender]];
                        }
                    });
                    
                    cell = (UITableViewCell *)generalFileMessageCell;
                }
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
//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.messages.count <= indexPath.row) {
//            return;
//        }
//
//        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
//        if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
//            SBDFileMessage *fileMessage = (SBDFileMessage *)baseMessage;
//            if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound) {
//                if ([self isDisplayedImageVideoMessage:fileMessage] == YES) {
//                    [self removeDisplayedImageVideoMessage:fileMessage];
//                }
//            }
//        }
//    });
//}

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

#pragma mark - SBDChannelDelegate
- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    if (sender == self.channel) {
        [self.channel markAsRead];
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(updateGroupChannelList)]) {
            [self.delegate updateGroupChannelList];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self determineScrollLock];
            [UIView setAnimationsEnabled:NO];
            [self.messages addObject:message];
            [self.messageTableView reloadData];
            [self scrollToBottomWithForce:NO];
            [UIView setAnimationsEnabled:YES];
        });
    }
}

- (void)channelDidUpdateReadReceipt:(SBDGroupChannel * _Nonnull)sender {
    if (sender == self.channel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView setAnimationsEnabled:NO];
            [self.messageTableView reloadData];
            [self.messageTableView layoutIfNeeded];
            [self.messageTableView setContentOffset:self.messageTableView.contentOffset animated:NO];
            [UIView setAnimationsEnabled:YES];
        });
    }
}

- (void)channelDidUpdateTypingStatus:(SBDGroupChannel * _Nonnull)sender {
    NSString *typingIndicatorText = [Utils buildTypingIndicatorLabel:sender];
    if (self.typingIndicatorTimer != nil) {
        [self.typingIndicatorTimer invalidate];
        self.typingIndicatorTimer = nil;
    }
    self.typingIndicatorTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(hideTypingIndicator:) userInfo:nil repeats:NO];
    
    if (typingIndicatorText.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.typingIndicatorContainerView.hidden = NO;
            self.typingIndicatorLabel.text = typingIndicatorText;
            self.messageTableViewBottomMargin.constant = self.typingIndicatorContainerViewHeight.constant;
            [self.view updateConstraints];
            [self.view layoutIfNeeded];
            
            self.stopMeasuringVelocity = YES;
            [self determineScrollLock];
            [self scrollToBottomWithForce:NO];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.typingIndicatorContainerView.hidden = YES;
            self.messageTableViewBottomMargin.constant = 0;
            [self.view updateConstraints];
            [self.view layoutIfNeeded];
            
            self.stopMeasuringVelocity = YES;
            [self determineScrollLock];
            [self scrollToBottomWithForce:NO];
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
            [self deleteMessageFromTableViewWithMessageId:messageId];
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
    __weak GroupChannelChatViewController *weakSelf = self;
    NSDictionary *pickerInfo = info;
    [picker dismissViewControllerAnimated:YES completion:^{
        self.pickerControllerOpened = NO;
        GroupChannelChatViewController *strongSelf = weakSelf;
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            PHAsset *imageAsset = [info objectForKey:UIImagePickerControllerPHAsset];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            options.networkAccessAllowed = YES;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)dataUTI, kUTTagClassMIMEType);

                NSString *filename = @"";
                if ([mimeType isEqualToString:@"image/gif"]) {
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
                    /***********************************/
                    /* Thumbnail is a premium feature. */
                    /***********************************/
                    SBDThumbnailSize *thumbnailSize = [SBDThumbnailSize makeWithMaxWidth:320.0 maxHeight:320.0];
                    
                    __block SBDFileMessage *preSendMessage = [strongSelf.channel sendFileMessageWithBinaryData:imageData filename:filename type:mimeType size:imageData.length thumbnailSizes:@[thumbnailSize] data:nil customType:nil progressHandler:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (strongSelf.sendingImageVideoMessage[preSendMessage.requestId] == nil || [strongSelf.sendingImageVideoMessage[preSendMessage.requestId] isKindOfClass:[NSNull class]]) {
                                strongSelf.sendingImageVideoMessage[preSendMessage.requestId] = @(NO);
                            }
                            strongSelf.fileTrasnferProgress[preSendMessage.requestId] = @((CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend);
                            for (NSInteger index = strongSelf.messages.count - 1; index >= 0; index--) {
                                SBDBaseMessage *baseMessage = strongSelf.messages[index];
                                if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
                                    SBDFileMessage *fileMesssage = (SBDFileMessage *)baseMessage;
                                    if (fileMesssage.requestId != nil && [fileMesssage.requestId isEqualToString:preSendMessage.requestId]) {
                                        [strongSelf determineScrollLock];
                                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                                        if ([strongSelf.sendingImageVideoMessage[preSendMessage.requestId] boolValue] == NO) {
                                            [strongSelf.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                            strongSelf.sendingImageVideoMessage[preSendMessage.requestId] = @(YES);
                                            [strongSelf scrollToBottomWithForce:NO];
                                        }
                                        else {
                                            GroupChannelOutgoingImageVideoFileMessageTableViewCell *cell = [strongSelf.messageTableView cellForRowAtIndexPath:indexPath];
                                            [cell showProgress:(CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend];
                                        }
                                        
                                        break;
                                    }
                                }
                            }
                        });
                    } completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                            SBDFileMessage *preSendMessage = (SBDFileMessage *)strongSelf.preSendMessages[fileMessage.requestId];

                            [strongSelf.preSendMessages removeObjectForKey:fileMessage.requestId];
                            [strongSelf.sendingImageVideoMessage removeObjectForKey:fileMessage.requestId];

                            if (error != nil) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    strongSelf.resendableMessages[fileMessage.requestId] = preSendMessage;
                                    strongSelf.resendableFileData[preSendMessage.requestId] = @{
                                                                                                @"data": imageData,
                                                                                                @"type": mimeType,
                                                                                                @"filename": filename,
                                                                                                };
                                    [strongSelf.messageTableView reloadData];
                                    [strongSelf.messageTableView layoutIfNeeded];

                                    [self scrollToBottomWithForce:YES];
                                });

                                return;
                            }

                            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(updateGroupChannelList)]) {
                                [self.delegate updateGroupChannelList];
                            }

                            if (fileMessage != nil) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [strongSelf determineScrollLock];
                                    [strongSelf.resendableMessages removeObjectForKey:fileMessage.requestId];
                                    [strongSelf.resendableFileData removeObjectForKey:fileMessage.requestId];
                                    [strongSelf.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:fileMessage];

                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.messages indexOfObject:fileMessage] inSection:0];
                                    [strongSelf.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                    [strongSelf.messageTableView layoutIfNeeded];

                                    [strongSelf scrollToBottomWithForce:NO];
                                });
                            }
                        });
                    }];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf determineScrollLock];
                        strongSelf.fileTrasnferProgress[preSendMessage.requestId] = @(0);
                        strongSelf.preSendFileData[preSendMessage.requestId] = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                                 @"data": imageData,
                                                                                                                                 @"type": mimeType,
                                                                                                                                 @"filename": filename,
                                                                                                                                 }];
                        strongSelf.preSendMessages[preSendMessage.requestId] = preSendMessage;
                        [strongSelf.messages addObject:preSendMessage];
                        [UIView setAnimationsEnabled:NO];
                        [strongSelf.messageTableView reloadData];
                        [strongSelf.messageTableView layoutIfNeeded];
                        [UIView setAnimationsEnabled:YES];
                        [strongSelf scrollToBottomWithForce:NO];
                    });
                }
            }];
        }
        else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
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
            __block SBDFileMessage *preSendMessage = [strongSelf.channel sendFileMessageWithBinaryData:videoFileData filename:videoName type:mimeType size:videoFileData.length thumbnailSizes:@[thumbnailSize] data:nil customType:nil progressHandler:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (strongSelf.sendingImageVideoMessage[preSendMessage.requestId] == nil || [strongSelf.sendingImageVideoMessage[preSendMessage.requestId] isKindOfClass:[NSNull class]]) {
                        strongSelf.sendingImageVideoMessage[preSendMessage.requestId] = @(NO);
                    }
                    strongSelf.fileTrasnferProgress[preSendMessage.requestId] = @((CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend);
                    for (NSInteger index = strongSelf.messages.count - 1; index >= 0; index--) {
                        SBDBaseMessage *baseMessage = strongSelf.messages[index];
                        if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
                            SBDFileMessage *fileMesssage = (SBDFileMessage *)baseMessage;
                            if (fileMesssage.requestId != nil && [fileMesssage.requestId isEqualToString:preSendMessage.requestId]) {
                                [strongSelf determineScrollLock];
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                                if ([strongSelf.sendingImageVideoMessage[preSendMessage.requestId] boolValue] == NO) {
                                    [strongSelf.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                    strongSelf.sendingImageVideoMessage[preSendMessage.requestId] = @(YES);
                                    [strongSelf scrollToBottomWithForce:NO];
                                }
                                else {
                                    GroupChannelOutgoingImageVideoFileMessageTableViewCell *cell = [strongSelf.messageTableView cellForRowAtIndexPath:indexPath];
                                    [cell showProgress:(CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend];
                                }
                                
                                break;
                            }
                        }
                    }
                });
            } completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    SBDFileMessage *preSendMessage = (SBDFileMessage *)strongSelf.preSendMessages[fileMessage.requestId];
                    
                    [strongSelf.preSendMessages removeObjectForKey:fileMessage.requestId];
                    [strongSelf.sendingImageVideoMessage removeObjectForKey:fileMessage.requestId];
                    
                    if (error != nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            strongSelf.resendableMessages[fileMessage.requestId] = preSendMessage;
                            strongSelf.resendableFileData[preSendMessage.requestId] = @{
                                                                                        @"data": videoFileData,
                                                                                        @"type": mimeType,
                                                                                        @"filename": videoName,
                                                                                        };
                            [strongSelf.messageTableView reloadData];
                        
                            [self scrollToBottomWithForce:YES];
                        });
                        
                        return;
                    }
                    
                    if (strongSelf.delegate != nil && [strongSelf.delegate respondsToSelector:@selector(updateGroupChannelList)]) {
                        [strongSelf.delegate updateGroupChannelList];
                    }
                    
                    if (fileMessage != nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf determineScrollLock];
                            [strongSelf.resendableMessages removeObjectForKey:fileMessage.requestId];
                            [strongSelf.resendableFileData removeObjectForKey:fileMessage.requestId];
                            [strongSelf.messages replaceObjectAtIndex:[strongSelf.messages indexOfObject:preSendMessage] withObject:fileMessage];
                            
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[strongSelf.messages indexOfObject:fileMessage] inSection:0];
                            [strongSelf.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

                            [strongSelf scrollToBottomWithForce:NO];
                        });
                    }
                });
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.fileTrasnferProgress[preSendMessage.requestId] = @(0);
                strongSelf.preSendFileData[preSendMessage.requestId] = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                         @"data": videoFileData,
                                                                                                                         @"type": mimeType,
                                                                                                                         @"filename": videoName,
                                                                                                                         }];
                [strongSelf determineScrollLock];
                strongSelf.preSendMessages[preSendMessage.requestId] = preSendMessage;
                [strongSelf.messages addObject:preSendMessage];
                [strongSelf.messageTableView reloadData];
                
                [strongSelf scrollToBottomWithForce:NO];
            });
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        self.pickerControllerOpened = NO;
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

#pragma mark - SBDConnectionDelegate
- (void)didSucceedReconnection {
    [self.channel refreshWithCompletionHandler:^(SBDError * _Nullable error) {
        [self loadPreviousMessages:YES];
    }];
}

#pragma mark - SBDNetworkDelegate
- (void)didReconnect {
    // TODO: Fix bug in SDK.
}

#pragma mark - GroupChannelSettingsDelegate
- (void)didLeaveChannel {
    if ([self.navigationController isKindOfClass:[CreateGroupChannelNavigationController class]]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark - GroupChannelMessageTableViewCellDelegate
- (void)didLongClickAdminMessage:(SBDAdminMessage *)message {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:message.message message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCopyMessage = [UIAlertAction actionWithTitle:@"Copy message" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = message.message;
        
        [self showToast:@"Copied"];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [vc addAction:actionCopyMessage];
    [vc addAction:actionCancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)didLongClickUserMessage:(SBDUserMessage *)message {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:message.message message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCopyMessage = [UIAlertAction actionWithTitle:@"Copy message" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = message.message;
        
        [self showToast:@"Copied"];
    }];
    
    // TODO: Check the message's sender.
    UIAlertAction *actionDeleteMessage = [UIAlertAction actionWithTitle:@"Delete message" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *subVc = [UIAlertController alertControllerWithTitle:@"Are you sure you want to delete this message?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *subActionDeleteMessage = [UIAlertAction actionWithTitle:@"Yes. Delete the message" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.channel deleteMessage:message completionHandler:^(SBDError * _Nullable error) {
                if (error != nil) {
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *actionClose = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:actionClose];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                    
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self deleteMessageFromTableViewWithMessageId:message.messageId];
                });
            }];
        }];
        UIAlertAction *subActionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [subVc addAction:subActionDeleteMessage];
        [subVc addAction:subActionCancel];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:subVc animated:YES completion:nil];
        });
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [vc addAction:actionCopyMessage];
    
    if ([self.resendableMessages objectForKey:message.requestId] == nil && [message.sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
        [vc addAction:actionDeleteMessage];
    }
    
    [vc addAction:actionCancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)didClickVideoFileMessage:(SBDFileMessage *)message {
    if (self.resendableFileData[message.requestId] == nil && message.url != nil && message.url.length > 0) {
        NSURL *videoUrl = [NSURL URLWithString:message.url];
        [self playMediaWithUrl:videoUrl];
    }
}

- (void)didClickAudioFileMessage:(SBDFileMessage *)message {
    if (self.resendableFileData[message.requestId] == nil && message.url != nil && message.url.length > 0) {
        NSURL *audioUrl = [NSURL URLWithString:message.url];
        [self playMediaWithUrl:audioUrl];
    }
}

- (void)didLongClickGeneralFileMessage:(SBDFileMessage *)message {
    if (self.resendableFileData[message.requestId] == nil) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"General file" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *saveFileAction = [UIAlertAction actionWithTitle:@"Save File" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [DownloadManager downloadWithURL:[NSURL URLWithString:message.url] filename:message.name mimeType:message.type addToMediaLibrary:NO];
        }];
        UIAlertAction *deleteAction = nil;
        
        if ([message.sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                UIAlertController *subVc = [UIAlertController alertControllerWithTitle:@"Are you sure you want to delete this file?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *subActionDeleteMessage = [UIAlertAction actionWithTitle:@"Yes. Delete the file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.channel deleteMessage:message completionHandler:^(SBDError * _Nullable error) {
                        if (error != nil) {
                            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *actionClose = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                            [vc addAction:actionClose];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self presentViewController:vc animated:YES completion:nil];
                            });
                            
                            return;
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self deleteMessageFromTableViewWithMessageId:message.messageId];
                        });
                    }];
                }];
                UIAlertAction *subActionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                
                [subVc addAction:subActionDeleteMessage];
                [subVc addAction:subActionCancel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:subVc animated:YES completion:nil];
                });
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
}

- (void)didClickResendUserMessage:(SBDUserMessage *)message {
    NSString *messageText = message.message;
    
    SBDUserMessageParams *params = [[SBDUserMessageParams alloc] initWithMessage:messageText];
    __block SBDUserMessage *preSendMessage = [self.channel sendUserMessageWithParams:params completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self determineScrollLock];
                [self.preSendMessages removeObjectForKey:preSendMessage.requestId];
                self.resendableMessages[preSendMessage.requestId] = preSendMessage;
                [self.messageTableView reloadData];
                [self scrollToBottomWithForce:NO];
            });
            
            return;
        }
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(updateGroupChannelList)]) {
            [self.delegate updateGroupChannelList];
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
        [self.messages replaceObjectAtIndex:[self.messages indexOfObject:message] withObject:preSendMessage];
        [self.resendableMessages removeObjectForKey:message.requestId];
        self.preSendMessages[preSendMessage.requestId] = preSendMessage;
        [self.messageTableView reloadData];
        [self scrollToBottomWithForce:NO];
    });
}

- (void)didLongClickUserProfile:(SBDUser *)user {
    if ([user.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
        return;
    }
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:user.nickname message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionBlockUser = nil;
    if (![user.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
        actionBlockUser = [UIAlertAction actionWithTitle:@"Block user" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SBDMain blockUser:user completionHandler:^(SBDUser * _Nullable blockedUser, SBDError * _Nullable error) {
                
            }];
        }];
    }
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    if (actionBlockUser != nil) {
        [vc addAction:actionBlockUser];
    }
    
    [vc addAction:actionCancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)didLongClickImageVideoFileMessage:(SBDFileMessage *)message {
    if (self.resendableFileData[message.requestId] == nil) {
        UIAlertController *vc = nil;
        NSString *deleteMessageActionTitle = @"";
        NSString *saveImageVideoActionTitle = @"";
        NSString *deleteMessageSubAlertTitle = @"";
        NSString *deleteMessageSubActionTitle = @"";
        if ([message.type hasPrefix:@"image"]) {
            vc = [UIAlertController alertControllerWithTitle:@"Image" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            deleteMessageActionTitle = @"Delete image";
            saveImageVideoActionTitle = @"Save image to media library";
            deleteMessageSubAlertTitle = @"Are you sure you want to delete this image?";
            deleteMessageSubActionTitle = @"Yes. Delete the image";
        }
        else if ([message.type hasPrefix:@"video"]) {
            vc = [UIAlertController alertControllerWithTitle:@"Video" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            deleteMessageActionTitle = @"Delete video";
            saveImageVideoActionTitle = @"Save video to media library";
            deleteMessageSubAlertTitle = @"Are you sure you want to delete this video?";
            deleteMessageSubActionTitle = @"Yes. Delete the video";
        }
        
        UIAlertAction *actionDeleteMessage = nil;
        if ([message.sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            actionDeleteMessage = [UIAlertAction actionWithTitle:deleteMessageActionTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                UIAlertController *subVc = [UIAlertController alertControllerWithTitle:deleteMessageSubAlertTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *subActionDeleteMessage = [UIAlertAction actionWithTitle:deleteMessageSubActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.channel deleteMessage:message completionHandler:^(SBDError * _Nullable error) {
                        if (error != nil) {
                            return;
                        }
                        
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [self determineScrollLock];
//                            [self removeDisplayedImageVideoMessage:message];
////                            [self.displayedImageVideoMessageByRequestId removeAllObjects];
////                            [self.displayedImageVideoMessageByMessageId removeAllObjects];
//                            NSInteger row = [self.messages indexOfObjectPassingTest:^BOOL(SBDBaseMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                                if (obj.messageId == message.messageId) {
//                                    return YES;
//                                }
//                                return NO;
//                            }];
//                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
//                            [self.messageTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                            [self.messages removeObject:message];
////                            [self.messageTableView reloadData];
//                            [self scrollToBottomWithForce:NO];
//                        });
                    }];
                }];
                UIAlertAction *subActionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                
                [subVc addAction:subActionDeleteMessage];
                [subVc addAction:subActionCancel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:subVc animated:YES completion:nil];
                });
            }];
        }
        
        UIAlertAction *actionSaveImageVideo = [UIAlertAction actionWithTitle:saveImageVideoActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [DownloadManager downloadWithURL:[NSURL URLWithString:message.url] filename:message.name mimeType:message.type addToMediaLibrary:YES];
        }];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
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
}

- (void)didClickImageVideoFileMessage:(SBDFileMessage *)message {
    if (self.resendableFileData[message.requestId] == nil) {
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
}

- (void)didClickUserProfile:(SBDUser *)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        UserProfileViewController *vc = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
        vc.user = user;
        [self.navigationController pushViewController:vc animated:YES];
    });
}

- (void)didClickResendImageVideoFileMessage:(SBDFileMessage *)message {
    if (self.resendableFileData[message.requestId] != nil) {
        NSData *imageData = (NSData *)self.resendableFileData[message.requestId][@"data"];
        NSString *filename = (NSString *)self.resendableFileData[message.requestId][@"filename"];
        NSString *mimeType = (NSString *)self.resendableFileData[message.requestId][@"type"];
        
        SBDThumbnailSize *thumbnailSize = [SBDThumbnailSize makeWithMaxWidth:320.0 maxHeight:320.0];
        
        __block SBDFileMessage *preSendMessage = [self.channel sendFileMessageWithBinaryData:imageData filename:filename type:mimeType size:imageData.length thumbnailSizes:@[thumbnailSize] data:nil customType:nil progressHandler:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self determineScrollLock];
                        self.resendableMessages[fileMessage.requestId] = preSendMessage;
                        self.resendableFileData[preSendMessage.requestId] = @{
                                                                                    @"data": imageData,
                                                                                    @"type": mimeType,
                                                                                    @"filename": filename,
                                                                                    };
                        [self.messageTableView reloadData];
                        [self scrollToBottomWithForce:NO];
                    });
                    
                    return;
                }
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(updateGroupChannelList)]) {
                    [self.delegate updateGroupChannelList];
                }
                
                if (fileMessage != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self determineScrollLock];
                        [self.resendableMessages removeObjectForKey:fileMessage.requestId];
                        [self.resendableFileData removeObjectForKey:fileMessage.requestId];
                        [self.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:fileMessage];
                        [self.messageTableView reloadData];
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
                                                                                                                     @"filename": filename,
                                                                                                                     }];
            self.preSendMessages[preSendMessage.requestId] = preSendMessage;
            [self.messages replaceObjectAtIndex:[self.messages indexOfObject:message] withObject:preSendMessage];
            [self.resendableMessages removeObjectForKey:message.requestId];
            [self.resendableFileData removeObjectForKey:message.requestId];
            self.preSendMessages[preSendMessage.requestId] = preSendMessage;
            [self.messageTableView reloadData];
            [self scrollToBottomWithForce:NO];
        });
    }
}

- (void)didClickResendAudioGeneralFileMessage:(SBDFileMessage *)message {
    if (self.resendableFileData[message.requestId] != nil) {
        NSData *fileData = (NSData *)self.resendableFileData[message.requestId][@"data"];
        NSString *filename = (NSString *)self.resendableFileData[message.requestId][@"filename"];
        NSString *mimeType = (NSString *)self.resendableFileData[message.requestId][@"type"];
        
        SBDFileMessageParams *params = [[SBDFileMessageParams alloc] initWithFile:fileData];
        params.fileName = filename;
        params.mimeType = mimeType;
        params.fileSize = fileData.length;
        
        __block SBDFileMessage *preSendMessage = [self.channel sendFileMessageWithParams:params progressHandler:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self determineScrollLock];
                        self.resendableMessages[fileMessage.requestId] = preSendMessage;
                        self.resendableFileData[preSendMessage.requestId] = @{
                                                                              @"data": fileData,
                                                                              @"type": mimeType,
                                                                              @"filename": filename,
                                                                              };
                        [self.messageTableView reloadData];
                        [self scrollToBottomWithForce:NO];
                    });
                    
                    return;
                }
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(updateGroupChannelList)]) {
                    [self.delegate updateGroupChannelList];
                }
                
                if (fileMessage != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self determineScrollLock];
                        [self.resendableMessages removeObjectForKey:fileMessage.requestId];
                        [self.resendableFileData removeObjectForKey:fileMessage.requestId];
                        [self.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:fileMessage];
                        [self.messageTableView reloadData];
                    });
                }
            });
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self determineScrollLock];
            
            self.fileTrasnferProgress[preSendMessage.requestId] = @(0);
            self.preSendFileData[preSendMessage.requestId] = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                               @"data": fileData,
                                                                                                               @"type": mimeType,
                                                                                                               @"filename": filename,
                                                                                                               }];
            self.preSendMessages[preSendMessage.requestId] = preSendMessage;
            [self.messages replaceObjectAtIndex:[self.messages indexOfObject:message] withObject:preSendMessage];
            [self.resendableMessages removeObjectForKey:message.requestId];
            [self.resendableFileData removeObjectForKey:message.requestId];
            self.preSendMessages[preSendMessage.requestId] = preSendMessage;
            [self.messageTableView reloadData];
            [self scrollToBottomWithForce:NO];
        });
    }
}

- (void)inputMessageTextFieldChanged:(id)sender {
    if ([sender isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)sender;
        if (textField.text.length > 0) {
            [self.channel startTyping];
            self.sendUserMessageButton.enabled = YES;
        }
        else {
            [self.channel endTyping];
            self.sendUserMessageButton.enabled = NO;
        }
    }
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    self.pickerControllerOpened = NO;
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    self.pickerControllerOpened = NO;
    [SBDMain setLogLevel:1112017];
    if (urls.count > 0) {
        NSURL *fileURL = urls[0];
        NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
        NSString *filename = [fileURL lastPathComponent];
        
        NSString *ext = [filename pathExtension];
        NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
        NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
        __weak GroupChannelChatViewController *weakSelf = self;
        __block SBDFileMessage *preSendMessage = [self.channel sendFileMessageWithBinaryData:fileData filename:filename type:mimeType size:fileData.length thumbnailSizes:nil data:nil customType:nil progressHandler:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            GroupChannelChatViewController *strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.sendingAudioGeneralFileMessage[preSendMessage.requestId] == nil || [strongSelf.sendingAudioGeneralFileMessage[preSendMessage.requestId] isKindOfClass:[NSNull class]]) {
                    strongSelf.sendingAudioGeneralFileMessage[preSendMessage.requestId] = @(NO);
                }
                strongSelf.fileTrasnferProgress[preSendMessage.requestId] = @((CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend);
                for (NSInteger index = strongSelf.messages.count - 1; index >= 0; index--) {
                    SBDBaseMessage *baseMessage = strongSelf.messages[index];
                    if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
                        SBDFileMessage *fileMesssage = (SBDFileMessage *)baseMessage;
                        if (fileMesssage.requestId != nil && [fileMesssage.requestId isEqualToString:preSendMessage.requestId]) {
                            [strongSelf determineScrollLock];
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                            if ([strongSelf.sendingAudioGeneralFileMessage[preSendMessage.requestId] boolValue] == NO) {
                                [strongSelf.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                strongSelf.sendingAudioGeneralFileMessage[preSendMessage.requestId] = @(YES);
                                [strongSelf scrollToBottomWithForce:NO];
                            }
                            else {
                                GroupChannelOutgoingAudioFileMessageTableViewCell *cell = [strongSelf.messageTableView cellForRowAtIndexPath:indexPath];
                                [cell showProgress:(CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend];
                            }
                            
                            break;
                        }
                    }
                }

                self.fileTrasnferProgress[preSendMessage.requestId] = @((CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend);
            });
        } completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                SBDFileMessage *preSendMessage = (SBDFileMessage *)self.preSendMessages[fileMessage.requestId];
                [self.preSendMessages removeObjectForKey:fileMessage.requestId];
                [self.sendingAudioGeneralFileMessage removeObjectForKey:fileMessage.requestId];
                
                if (error != nil) {
                    self.resendableMessages[fileMessage.requestId] = preSendMessage;
                    self.resendableFileData[preSendMessage.requestId] = @{
                                                                                @"data": fileData,
                                                                                @"type": mimeType,
                                                                                @"filename": filename,
                                                                                };
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.messageTableView reloadData];
                        [self scrollToBottomWithForce:YES];
                    });
                    
                    return;
                }
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(updateGroupChannelList)]) {
                    [self.delegate updateGroupChannelList];
                }
                
                if (fileMessage != nil) {
                    [self.resendableMessages removeObjectForKey:fileMessage.requestId];
                    [self.resendableFileData removeObjectForKey:fileMessage.requestId];
                    [self.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:fileMessage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.messageTableView reloadData];
                        [self scrollToBottomWithForce:YES];
                    });
                }
            });
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.preSendFileData[preSendMessage.requestId] = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                               @"data": fileData,
                                                                                                               @"type": mimeType,
                                                                                                               @"filename": filename,
                                                                                                               }];
            self.preSendMessages[preSendMessage.requestId] = preSendMessage;
            [self.messages addObject:preSendMessage];
            [self.messageTableView reloadData];
            
            [self scrollToBottomWithForce:YES];
        });
    }
}

- (void)deleteMessageFromTableViewWithMessageId:(long long)messageId {
    if (self.messages.count == 0) {
        return;
    }
    
    for (int i = 0; i < self.messages.count; i++) {
        SBDBaseMessage *msg = self.messages[i];
        if (msg.messageId == messageId) {
            [self determineScrollLock];
            [self.messages removeObject:msg];
            [self.messageTableView reloadData];
            [self.messageTableView layoutIfNeeded];
            
            break;
        }
    }
}

- (void)playMediaWithUrl:(NSURL *)url {
    AVPlayer *player = [[AVPlayer alloc] initWithURL:url];
    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
    vc.player = player;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:^{
            [player play];
        }];
    });
}

@end
