//
//  CustomTextField.m
//  SendBird-iOS
//
//  Created by SendBird on 11/15/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "CustomTextField.h"

@interface CustomTextField()

@property (strong) CAShapeLayer *shapeLayer;

@end

@implementation CustomTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        self.shapeLayer = nil;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self != nil) {
        self.shapeLayer = nil;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.borderStyle = UITextBorderStyleNone;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.frame.size.height - (self.bottomBorderWidth / 2))];
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height - (self.bottomBorderWidth / 2))];

    if (self.shapeLayer != nil) {
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
    }
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.path = [path CGPath];
    self.shapeLayer.lineWidth = self.bottomBorderWidth;
    self.shapeLayer.strokeColor = self.bottomBorderColor.CGColor;
    self.shapeLayer.fillColor = self.bottomBorderColor.CGColor;
    
    [self.layer addSublayer:self.shapeLayer];
}

#pragma - Support IB_DESIGNABLE

@end
