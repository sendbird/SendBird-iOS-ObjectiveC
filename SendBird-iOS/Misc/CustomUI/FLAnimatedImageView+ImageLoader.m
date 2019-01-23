//
//  FLAnimatedImageView+ImageLoader.m
//  SendBird-iOS
//
//  Created by SendBird on 2/6/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "FLAnimatedImageView+ImageLoader.h"

@implementation FLAnimatedImageView (ImageLoader)

+ (nonnull NSURLCache *)imageCache {
    static dispatch_once_t p = 0;
    __strong static NSURLCache *_sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024 diskCapacity:100 * 1024 * 1024 diskPath:nil];
        [NSURLCache setSharedURLCache:_sharedObject];
    });
    
    return _sharedObject;
}

- (void)setAnimatedImageWithURL:(NSURL * _Nonnull)url success:(nullable void (^)(FLAnimatedImage * _Nullable image, NSUInteger hash))success failure:(nullable void (^)(NSError * _Nullable error))failure {
    __block NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSCachedURLResponse *cachedResponse = [[FLAnimatedImageView imageCache] cachedResponseForRequest:request];
    if (cachedResponse != nil) {
        if (success != nil) {
            FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:cachedResponse.data];
            success(animatedImage, cachedResponse.data.hash);
        }
        
        return;
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            if (failure != nil) {
                failure(error);
            }
            
            [session invalidateAndCancel];
            
            return;
        }
        
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        if ([resp statusCode] >= 200 && [resp statusCode] < 300) {
            __block FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
            NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            [[FLAnimatedImageView imageCache] storeCachedResponse:cachedResponse forRequest:request];
            if (animatedImage != NULL) {
                if (success != nil) {
                    success(animatedImage, data.hash);
                }
            }
            else {
                if (failure != nil) {
                    failure(nil);
                }
            }
        }
        else {
            if (failure != nil) {
                failure(nil);
            }
        }
        
        [session invalidateAndCancel];
    }] resume];
}

@end
