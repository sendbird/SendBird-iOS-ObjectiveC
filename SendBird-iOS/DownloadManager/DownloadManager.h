//
//  DownloadManager.h
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/7/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadManager : NSObject<NSURLSessionDelegate,NSURLSessionDataDelegate>

+ (void)downloadWithURL:(NSURL *)url filename:(NSString *)filename mimeType:(NSString *)mimeType addToMediaLibrary:(BOOL)addToMediaLibrary;

@end
