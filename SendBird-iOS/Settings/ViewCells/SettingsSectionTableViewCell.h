//
//  SettingsSectionTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 3/1/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsSectionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sectionLabel;
@property (weak, nonatomic) IBOutlet UIView *topBorderView;
@property (weak, nonatomic) IBOutlet UIView *bottomBorderView;

@end
