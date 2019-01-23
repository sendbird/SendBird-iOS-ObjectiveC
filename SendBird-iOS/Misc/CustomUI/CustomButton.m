//
//  CustomButton.m
//  SendBird-iOS
//
//  Created by SendBird on 11/15/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.cornerRadius = self.cornerRadius;
    self.layer.masksToBounds = YES;
}

@end
