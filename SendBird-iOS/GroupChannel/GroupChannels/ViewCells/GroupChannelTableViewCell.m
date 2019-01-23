//
//  GroupChannelTableViewCell.m
//  SendBird-iOS
//
//  Created by SendBird on 2/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "GroupChannelTableViewCell.h"

@implementation GroupChannelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    NSDataAsset *asset = [[NSDataAsset alloc] initWithName:@"img_typing_indicator"];
//    NSData *typingIndicatorImageData = asset.data;
//    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:typingIndicatorImageData];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"loading_typing" ofType:@"gif"]]];
    self.typingIndicatorImageView.animatedImage = image;
    self.typingIndicatorContainerView.hidden = YES;
    self.lastMessageLabel.hidden = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
