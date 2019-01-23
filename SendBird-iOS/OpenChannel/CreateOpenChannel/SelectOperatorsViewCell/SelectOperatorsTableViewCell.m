//
//  SelectOperatorsTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 1/9/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "SelectOperatorsTableViewCell.h"

@interface SelectOperatorsTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

@end

@implementation SelectOperatorsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSelectedOperator:(BOOL)selectedOperator {
    _selectedOperator = selectedOperator;
    
    if (selectedOperator) {
        [self.checkImageView setImage:[UIImage imageNamed:@"img_list_checked"]];
    }
    else {
        [self.checkImageView setImage:[UIImage imageNamed:@"img_list_unchecked"]];
    }
}

@end
