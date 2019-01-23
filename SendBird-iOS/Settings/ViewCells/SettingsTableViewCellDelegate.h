//
//  SettingsTableViewCellDelegate.h
//  SendBird-iOS
//
//  Created by SendBird on 3/5/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SettingsTableViewCellDelegate<NSObject>

@optional
- (void)didChangeSwitchButton:(BOOL)isOn identifier:(NSString *)identifier;

@end
