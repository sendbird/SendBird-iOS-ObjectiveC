//
//  CustomTextField.h
//  SendBird-iOS
//
//  Created by SendBird on 11/15/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface CustomTextField : UITextField

@property (nonatomic) IBInspectable UIColor *bottomBorderColor;
@property (nonatomic) IBInspectable CGFloat bottomBorderWidth;

@end
