//
//  SettingsTimePickerTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/2/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsTimePickerDelegate<NSObject>

@optional
- (void)didSetTime:(NSString *)timeValue component:(NSInteger)component identifier:(NSString *)identifier;

@end

@interface SettingsTimePickerTableViewCell : UITableViewCell<UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) id<SettingsTimePickerDelegate> delegate;
@property (strong) NSString *identifier;
@property (weak, nonatomic) IBOutlet UIPickerView *timePicker;

@end
