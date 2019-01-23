//
//  CustomActivityIndicatorView.m
//  SendBird-iOS
//
//  Created by SendBird on 1/9/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

/*
 Copyright (C) 2013 by Connor Duggan.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "CustomActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@interface CustomActivityIndicatorView ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) CABasicAnimation *animation;

@end

@implementation CustomActivityIndicatorView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _init];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self _init];
    }
    
    return self;
}

- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style {
    self = [super initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    if (self) {
        [self _init];
    }
    
    return self;
}

- (void)_init {
    self.animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    self.animation.fromValue = [NSNumber numberWithFloat:0.0f];
    self.animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
    self.animation.duration = 1.0f;
    self.animation.repeatCount = HUGE_VAL;
    
    if (!self.frame.size.width) {
        return;
    }

    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    [self.backgroundImageView removeFromSuperview];
    self.backgroundImageView = nil;

    if (self.subviews.count) {
        [self.subviews[0] setHidden:YES];
    }
    
    self.image = [UIImage imageNamed:@"img_loading_indicator"];
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    
    self.backgroundImage = [UIImage imageNamed:@"img_loading_indicator_background"];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:self.backgroundImage];
    
    if (self.hidesWhenStopped && !self.isAnimating) {
        self.imageView.hidden = YES;
        self.backgroundImageView.hidden = YES;
    }

    [self addSubview:self.backgroundImageView];
    [self addSubview:self.imageView];
    
    
    if (![self.imageView.layer animationForKey:@"animation"]) {
        [self.imageView.layer addAnimation:self.animation forKey:@"animation"];
    }
    
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    self.imageView.frame = (CGRect){(width - self.imageView.frame.size.width) / 2, (height - self.imageView.frame.size.height) / 2, self.imageView.frame.size};
    self.backgroundImageView.frame = (CGRect){(width - self.backgroundImageView.frame.size.width) / 2, (height - self.backgroundImageView.frame.size.height) / 2, self.backgroundImageView.frame.size};
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    [super setHidesWhenStopped:hidesWhenStopped];
    
    if (self.hidesWhenStopped && !self.isAnimating) {
        self.imageView.hidden = YES;
        self.backgroundImageView.hidden = YES;
    }
    else {
        self.imageView.hidden = NO;
        self.backgroundImageView.hidden = NO;
    }
}

- (void)startAnimating {
    [super startAnimating];
    
    self.imageView.hidden = NO;
    self.backgroundImageView.hidden = NO;
    
    [self.imageView.layer addAnimation:self.animation forKey:@"animation"];
}

- (void)stopAnimating {
    [super stopAnimating];
    
    if (self.hidesWhenStopped) {
        self.imageView.hidden = YES;
        self.backgroundImageView.hidden = YES;
    }
    
    [self.imageView.layer removeAllAnimations];
}

@end
