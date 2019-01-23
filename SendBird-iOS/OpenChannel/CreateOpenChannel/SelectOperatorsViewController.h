//
//  SelectOperatorsViewController.h
//  SendBird-iOS
//
//  Created by SendBird on 1/9/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "NotificationDelegate.h"

@protocol SelectOperatorsDelegate <NSObject>

- (void)didSelectUsers:(NSMutableDictionary<NSString *, SBDUser *> *)users;

@end

@interface SelectOperatorsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NotificationDelegate>

@property (nonatomic, weak) id <SelectOperatorsDelegate> delegate;

@property (strong) NSMutableDictionary<NSString *, SBDUser *> *selectedUsers;

@end
