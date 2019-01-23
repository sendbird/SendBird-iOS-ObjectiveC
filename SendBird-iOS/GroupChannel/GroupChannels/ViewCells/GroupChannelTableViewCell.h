//
//  GroupChannelTableViewCell.h
//  SendBird-iOS
//
//  Created by SendBird on 2/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>

@interface GroupChannelTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *singleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *singleCoverImageView;

@property (weak, nonatomic) IBOutlet UIView *doubleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *doubleCoverImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *doubleCoverImageView2;

@property (weak, nonatomic) IBOutlet UIView *tripleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *tripleCoverImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *tripleCoverImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *tripleCoverImageView3;

@property (weak, nonatomic) IBOutlet UIView *quadrupleCoverImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *quadrupleCoverImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *quadrupleCoverImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *quadrupleCoverImageView3;
@property (weak, nonatomic) IBOutlet UIImageView *quadrupleCoverImageView4;

@property (weak, nonatomic) IBOutlet UILabel *channelNameLabel;
@property (weak, nonatomic) IBOutlet UIView *memberCountContainerView;
@property (weak, nonatomic) IBOutlet UILabel *memberCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *notiOffIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadMessageCountContainerView;
@property (weak, nonatomic) IBOutlet UILabel *unreadMessageCountLabel;
@property (weak, nonatomic) IBOutlet UIView *typingIndicatorContainerView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *typingIndicatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *typingIndicatorLabel;

@end
