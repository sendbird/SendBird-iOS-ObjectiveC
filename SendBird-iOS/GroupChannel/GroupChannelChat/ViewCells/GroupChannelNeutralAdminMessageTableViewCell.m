//
//  GroupChannelNeutralAdminMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 2/20/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelNeutralAdminMessageTableViewCell.h"
#import "Utils.h"

#define kDateSeperatorConatinerViewTopMargin 3
#define kDateSeperatorContainerViewHeight 65
#define kMessageConatinerViewTopMarginNormal 3
#define kMessageConatinerViewTopMarginNoDateSeperator 6

@interface GroupChannelNeutralAdminMessageTableViewCell()

@property (strong) SBDAdminMessage *msg;

@end

@implementation GroupChannelNeutralAdminMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurrentMessage:(SBDAdminMessage *)message previousMessage:(SBDBaseMessage *)prevMessage {
    BOOL showDateSeperator = NO;
    BOOL hasPrevMessage = NO;
    self.msg = message;
    
    UILongPressGestureRecognizer *longClickMessageContainerGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClickAdminMessage:)];
    [self.messageContainerView addGestureRecognizer:longClickMessageContainerGesture];
    
    self.dateSeperatorLabel.text = [Utils getDateStringForDateSeperatorFromTimestamp:self.msg.createdAt];
    self.textMessageLabel.text = self.msg.message;
    
    // Adjusts constraints regarding the prevMessage.
    if (prevMessage == nil) {
        showDateSeperator = YES;
        hasPrevMessage = NO;
    }
    else {
        if ([Utils checkDayChangeDayBetweenOldTimestamp:self.msg.createdAt newTimestamp:prevMessage.createdAt]) {
            showDateSeperator = YES;
        }
        else {
            showDateSeperator = NO;
        }
        
        hasPrevMessage = YES;
    }

    if (showDateSeperator) {
        self.dateSeperatorContainerView.hidden = NO;
        self.dateSeperatorContainerViewTopMargin.constant = kDateSeperatorConatinerViewTopMargin;
        self.dateSeperatorContainerViewHeight.constant = kDateSeperatorContainerViewHeight;
        self.messageContainerViewTopMargin.constant = kMessageConatinerViewTopMarginNormal;
    }
    else {
        self.dateSeperatorContainerView.hidden = YES;
        self.dateSeperatorContainerViewTopMargin.constant = 0;
        self.dateSeperatorContainerViewHeight.constant = 0;
        if (hasPrevMessage) {
            self.messageContainerViewTopMargin.constant = kMessageConatinerViewTopMarginNoDateSeperator;
        }
        else {
            self.messageContainerViewTopMargin.constant = 0;
        }
    }
}

- (SBDAdminMessage *)getMessage {
    return self.msg;
}

- (void)longClickAdminMessage:(UILongPressGestureRecognizer *)recognizer {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didLongClickAdminMessage:)]) {
        [self.delegate didLongClickAdminMessage:self.msg];
    }
}

@end
