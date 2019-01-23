//
//  FLAnimatedImageView+ImageLoader.h
//  SendBird-iOS
//
//  Created by SendBird on 2/6/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <FLAnimatedImage/FLAnimatedImage.h>

@interface FLAnimatedImageView (ImageLoader)

- (void)setAnimatedImageWithURL:(NSURL * _Nonnull)url success:(nullable void (^)(FLAnimatedImage * _Nullable image, NSUInteger hash))success failure:(nullable void (^)(NSError * _Nullable error))failure;

@end
