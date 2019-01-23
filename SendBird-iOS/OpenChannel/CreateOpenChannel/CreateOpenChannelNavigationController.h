//
//  CreateOpenChannelNavigationController.h
//  SendBird-iOS
//
//  Created by SendBird on 1/9/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateOpenChannelViewControllerB.h"

@protocol CreateOpenChannelDelegate <NSObject>

- (void)didCreate:(SBDOpenChannel *)channel;

@end

@interface CreateOpenChannelNavigationController : UINavigationController

@property (nonatomic, weak) id <CreateOpenChannelDelegate> createChannelDelegate;

@end
