//
//  CreateOpenChannelViewControllerB.m
//  SendBird-iOS
//
//  Created by SendBird on 1/3/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "CreateOpenChannelViewControllerB.h"
#import "CreateOpenChannelNavigationController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "CustomActivityIndicatorView.h"
#import "Utils.h"
#import "OpenChannelChatViewController.h"

#import "CreateOpenChannelChannelUrlTableViewCell.h"
#import "CreateOpenChannelOperatorSectionTableViewCell.h"
#import "CreateOpenChannelAddOperatorTableViewCell.h"
#import "CreateOpenChannelCurrentUserTableViewCell.h"
#import "CreateOpenChannelOperatorTableViewCell.h"
#import "CreateOpenChannelViewControllerA.h"
#import "UIViewController+Utils.h"

@interface CreateOpenChannelViewControllerB ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;

@property (strong) NSMutableDictionary<NSString *, SBDUser *> *selectedUsers;
@property (weak, nonatomic) IBOutlet CustomActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong) NSString *channelUrl;

@property (strong) UIBarButtonItem *doneButtonItem;

@end

@implementation CreateOpenChannelViewControllerB

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Create Open Channel";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [prevVC.navigationItem setBackBarButtonItem:barButtonItemBack];
    
    self.doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(clickDoneButton:)];
    self.navigationItem.rightBarButtonItem = self.doneButtonItem;
    
    self.selectedUsers = [[NSMutableDictionary alloc] init];

    self.channelUrl = [[[NSUUID UUID] UUIDString] substringToIndex:8];
    
    self.activityIndicatorView.hidden = YES;
    [self.view bringSubviewToFront:self.activityIndicatorView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CreateOpenChannelChannelUrlTableViewCell" bundle:nil] forCellReuseIdentifier:@"CreateOpenChannelChannelUrlTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CreateOpenChannelOperatorSectionTableViewCell" bundle:nil] forCellReuseIdentifier:@"CreateOpenChannelOperatorSectionTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CreateOpenChannelAddOperatorTableViewCell" bundle:nil] forCellReuseIdentifier:@"CreateOpenChannelAddOperatorTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CreateOpenChannelCurrentUserTableViewCell" bundle:nil] forCellReuseIdentifier:@"CreateOpenChannelCurrentUserTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CreateOpenChannelOperatorTableViewCell" bundle:nil] forCellReuseIdentifier:@"CreateOpenChannelOperatorTableViewCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickDoneButton:(id)sender {
    [self.activityIndicatorView setHidden:NO];
    [self.activityIndicatorView startAnimating];
    NSMutableArray<NSString *> *operatorIds = [[NSMutableArray alloc] init];
    [operatorIds addObjectsFromArray:self.selectedUsers.allKeys];
    [operatorIds addObject:[SBDMain getCurrentUser].userId];
    NSString *channelUrl = self.channelUrl;
    [SBDOpenChannel createChannelWithName:self.channelName channelUrl:channelUrl coverImage:self.coverImageData coverImageName:@"cover_image.jpg" data:nil operatorUserIds:operatorIds customType:nil progressHandler:nil completionHandler:^(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error) {
        if (error != nil) {
            [self.activityIndicatorView setHidden:YES];
            [self.activityIndicatorView stopAnimating];
            
            [Utils showAlertControllerWithError:error viewController:self];
            
            return;
        }
        
        if ([self.navigationController isKindOfClass:[CreateOpenChannelNavigationController class]]) {
            CreateOpenChannelNavigationController *nc = (CreateOpenChannelNavigationController *)self.navigationController;

            if (nc.createChannelDelegate != nil) {
                [nc.createChannelDelegate didCreate:channel];
            }
        }
        
        [channel enterChannelWithCompletionHandler:^(SBDError * _Nullable error) {
            [self.activityIndicatorView setHidden:YES];
            [self.activityIndicatorView stopAnimating];
            
            if (error != nil) {
                [Utils showAlertControllerWithError:error viewController:self];
                return;
            }
            
            OpenChannelChatViewController *vc = [[OpenChannelChatViewController alloc] initWithNibName:@"OpenChannelChatViewController" bundle:nil];
            vc.channel = channel;
            vc.hidesBottomBarWhenPushed = YES;
            vc.createChannelDelegate = ((CreateOpenChannelNavigationController *)self.navigationController).createChannelDelegate;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomMargin.constant = keyboardFrameBeginRect.size.height - self.view.safeAreaInsets.bottom;
        [self.view layoutIfNeeded];
    });
}

- (void)keyboardDidHide:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomMargin.constant = 0;
        [self.view layoutIfNeeded];
    });
}

#pragma mark - NotificationDelegate
- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self.navigationController popViewControllerAnimated:NO];
    UIViewController *cvc = [UIViewController currentViewController];
    if ([cvc isKindOfClass:[CreateOpenChannelViewControllerA class]]) {
        [((CreateOpenChannelViewControllerA *)cvc) openChatWithChannelUrl:channelUrl];
    }
}

#pragma mark - SelectOperatorsDelegate
- (void)didSelectUsers:(NSMutableDictionary<NSString *, SBDUser *> *)users {
    self.selectedUsers = users;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return UITableViewAutomaticDimension;
    }
    else if (indexPath.row == 1) {
        return UITableViewAutomaticDimension;
    }
    else {
        return 48;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 2) {
        SelectOperatorsViewController *vc = [[SelectOperatorsViewController alloc] initWithNibName:@"SelectOperatorsViewController" bundle:nil];
        vc.title = @"Select an operator";
        vc.delegate = self;
        vc.selectedUsers = self.selectedUsers;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectedUsers.count + 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        CreateOpenChannelChannelUrlTableViewCell *channelUrlCell = [tableView dequeueReusableCellWithIdentifier:@"CreateOpenChannelChannelUrlTableViewCell"];
        channelUrlCell.channelUrlTextField.text = self.channelUrl;
        [channelUrlCell.channelUrlTextField addTarget:self action:@selector(channelUrlChanged:) forControlEvents:UIControlEventEditingChanged];
        
        cell = (UITableViewCell *)channelUrlCell;
    }
    else if (indexPath.row == 1) {
        CreateOpenChannelOperatorSectionTableViewCell *operatorSectionCell = [tableView dequeueReusableCellWithIdentifier:@"CreateOpenChannelOperatorSectionTableViewCell"];
        
        cell = (UITableViewCell *)operatorSectionCell;
    }
    else if (indexPath.row == 2) {
        CreateOpenChannelAddOperatorTableViewCell *addOperatorCell = [tableView dequeueReusableCellWithIdentifier:@"CreateOpenChannelAddOperatorTableViewCell"];
        
        cell = (UITableViewCell *)addOperatorCell;
    }
    else if (indexPath.row == 3) {
        CreateOpenChannelCurrentUserTableViewCell *currentUserCell = [tableView dequeueReusableCellWithIdentifier:@"CreateOpenChannelCurrentUserTableViewCell"];
        currentUserCell.nicknameLabel.text = [SBDMain getCurrentUser].nickname;
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];
            if (updateCell != nil && [updateCell isKindOfClass:[CreateOpenChannelCurrentUserTableViewCell class]]) {
                [((CreateOpenChannelCurrentUserTableViewCell *)updateCell).profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:[SBDMain getCurrentUser]]] placeholderImage:[Utils getDefaultUserProfileImage:[SBDMain getCurrentUser]]];
            }
        });
        
        if (self.selectedUsers.count == 0) {
            currentUserCell.bottomBorderView.hidden = NO;
        }
        else {
            currentUserCell.bottomBorderView.hidden = YES;
        }
        
        cell = (UITableViewCell *)currentUserCell;
    }
    else {
        CreateOpenChannelOperatorTableViewCell *operatorCell = [tableView dequeueReusableCellWithIdentifier:@"CreateOpenChannelOperatorTableViewCell"];
        SBDUser *op = self.selectedUsers.allValues[indexPath.row -  4];
        operatorCell.op = op;
        operatorCell.nicknameLabel.text = op.nickname;
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];
            if (updateCell != nil && [updateCell isKindOfClass:[CreateOpenChannelOperatorTableViewCell class]]) {
                [((CreateOpenChannelOperatorTableViewCell *)updateCell).profileImageView setImageWithURL:[NSURL URLWithString:[Utils transformUserProfileImage:op]] placeholderImage:[Utils getDefaultUserProfileImage:op]];
            }
        });
        
        if (self.selectedUsers.count - 1 == indexPath.row - 4) {
            operatorCell.bottomBorderView.hidden = NO;
        }
        else {
            operatorCell.bottomBorderView.hidden = YES;
        }
        
        cell = (UITableViewCell *)operatorCell;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openOperatorActionSheet:)];
        [cell addGestureRecognizer:longPress];
    }
    
    return cell;
}

- (void)channelUrlChanged:(id)sender {
    if ([sender isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)sender;
        self.channelUrl = textField.text;
    }
}

- (void)openOperatorActionSheet:(UILongPressGestureRecognizer *)sender {
    if ([sender.view isKindOfClass:[CreateOpenChannelOperatorTableViewCell class]]) {
        SBDUser *op = ((CreateOpenChannelOperatorTableViewCell *)sender.view).op;
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:op.nickname message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *removeFromOperatorsAction = [UIAlertAction actionWithTitle:@"Remove from operators" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SBDUser *op = ((CreateOpenChannelOperatorTableViewCell *)sender.view).op;
                [self.selectedUsers removeObjectForKey:op.userId];
                [self.tableView reloadData];
            });
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [ac addAction:removeFromOperatorsAction];
        [ac addAction:cancelAction];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

@end
