//
//  GroupChannelInviteMemberTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 2/28/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelInviteMemberTableViewCell.h"

@interface GroupChannelInviteMemberTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

@end

@implementation GroupChannelInviteMemberTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSelectedUser:(BOOL)selectedUser {
    _selectedUser = selectedUser;
    
    if (selectedUser) {
        [self.checkImageView setImage:[UIImage imageNamed:@"img_list_checked"]];
    }
    else {
        [self.checkImageView setImage:[UIImage imageNamed:@"img_list_unchecked"]];
    }
}

@end
