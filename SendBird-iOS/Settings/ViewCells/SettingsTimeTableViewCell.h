//
//  SettingsTimeTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 3/1/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTimeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *settingLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomBorderView;
@property (weak, nonatomic) IBOutlet UIView *expandedBottomBorderView;
@property (weak, nonatomic) IBOutlet UIView *expandedTopBorderView;

@end
