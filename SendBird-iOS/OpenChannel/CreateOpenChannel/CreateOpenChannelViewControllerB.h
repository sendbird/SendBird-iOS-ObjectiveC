//
//  CreateOpenChannelViewControllerB.h
//  SendBird-iOS
//
//  Created by SendBird on 1/3/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectOperatorsViewController.h"
#import "NotificationDelegate.h"

@interface CreateOpenChannelViewControllerB : UIViewController<SelectOperatorsDelegate, UITableViewDelegate, UITableViewDataSource, NotificationDelegate>

@property (strong) NSString *channelName;
@property (strong) NSData *coverImageData;

@end
