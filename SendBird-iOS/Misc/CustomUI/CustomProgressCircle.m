//
//  CustomProgressCircle.m
//  SendBird-iOS
//
//  Created by SendBird on 1/24/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "CustomProgressCircle.h"


@interface CustomProgressCircle()

@property (strong) CAShapeLayer *circleLayer;
@property (atomic) CGFloat progress;

@end

@implementation CustomProgressCircle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.progress = 0.5;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.progress = 0.5;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.progress = 0.5;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor clearColor];
    // Drawing code
    UIBezierPath *circlePath = [[UIBezierPath alloc] init];
    CGFloat startAngle = -(M_PI / 2);
    CGFloat endAngle = 2 * M_PI * self.progress + startAngle;
    [circlePath addArcWithCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0) radius:((self.frame.size.width - 4) / 2) startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    // Set the render colors.
    [[UIColor clearColor] setFill];
    [[UIColor colorNamed:@"color_general_file_message_transfer_progress_text" inBundle:nil compatibleWithTraitCollection:nil] setStroke];

    CGContextRef aRef = UIGraphicsGetCurrentContext();
    
    // If you have content to draw after the shape,
    // save the current state before changing the transform.
    //CGContextSaveGState(aRef);
    
    // Adjust the view's origin temporarily. The oval is
    // now drawn relative to the new origin point.
    CGContextTranslateCTM(aRef, 0, 0);
    
    // Adjust the drawing options as needed.
    circlePath.lineWidth = 2;
    
    // Fill the path before stroking it so that the fill
    // color does not obscure the stroked line.
    [circlePath fill];
    [circlePath stroke];
    
    // Restore the graphics state before drawing any other content.
    //CGContextRestoreGState(aRef);
}


- (void)drawCircleWithProgress:(CGFloat)progress {
    self.progress = progress;
    [self setNeedsDisplay];
}


@end
