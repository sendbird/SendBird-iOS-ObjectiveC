//
//  SettingsTimePickerTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/2/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import "SettingsTimePickerTableViewCell.h"

@interface SettingsTimePickerTableViewCell()

@property (strong) NSMutableArray<NSString *> *hours;
@property (strong) NSMutableArray<NSString *> *mins;
@property (strong) NSMutableArray<NSString *> *ampm;

@end

@implementation SettingsTimePickerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.hours = [[NSMutableArray alloc] init];
    for (int i = 0; i < 12; i++) {
        [self.hours addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    self.mins = [[NSMutableArray alloc] init];
    for (int i = 0; i < 60; i++) {
        [self.mins addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    self.ampm = [[NSMutableArray alloc] init];
    [self.ampm addObject:@"AM"];
    [self.ampm addObject:@"PM"];
    
    self.timePicker.delegate = self;
    self.timePicker.dataSource = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView*)thePickerView {
    return 5;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 1) {
        return 12;
    }
    else if (component == 2) {
        return 60;
    }
    else if (component == 3) {
        return 2;
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 1) {
        return self.hours[row];
    }
    else if (component == 2) {
        return self.mins[row];
    }
    else if (component == 3) {
        return self.ampm[row];
    }

    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didSetTime:component:identifier:)]) {
        if (component == 1) {
            [self.delegate didSetTime:self.hours[row] component:component identifier:self.identifier];
        }
        else if (component == 2) {
            [self.delegate didSetTime:self.mins[row] component:component identifier:self.identifier];
        }
        else if (component == 3) {
            [self.delegate didSetTime:self.ampm[row] component:component identifier:self.identifier];
        }
        
    }
}

@end
