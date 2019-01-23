//
//  OpenChannelTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 12/5/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "OpenChannelTableViewCell.h"

@interface OpenChannelTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *operatorMarkImageView;

@end

@implementation OpenChannelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAsOperator:(BOOL)asOperator {
    _asOperator = asOperator;
    
    if (asOperator) {
        [self.operatorMarkImageView setImage:[UIImage imageNamed:@"img_icon_operator"]];
    }
    else {
        [self.operatorMarkImageView setImage:nil];
    }
}

@end
