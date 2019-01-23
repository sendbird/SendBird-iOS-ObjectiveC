//
//  DownloadManager.m
//  SendBird-iOS
//
//  Created by Jed Gyeong on 5/7/18.
//  Copyright © 2018 Jed Gyeong. All rights reserved.
//

#import "DownloadManager.h"
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>

@interface DownloadManager()

@property (strong) NSMutableDictionary<NSString *, NSString *> *filePath;
@property (strong) NSMutableDictionary<NSString *, NSNumber *> *saveToLibrary;
@property (strong) NSMutableDictionary<NSString *, NSString *> *mimeType;

@end

@implementation DownloadManager

+ (nullable instancetype)sharedInstance {
    static DownloadManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DownloadManager alloc] init];
        instance.filePath = [[NSMutableDictionary alloc] init];
        instance.saveToLibrary = [[NSMutableDictionary alloc] init];
        instance.mimeType = [[NSMutableDictionary alloc] init];
    });
    return instance;
}

- (nonnull NSURLSession *)backgroundSession {
    static dispatch_once_t onceToken;
    static NSURLSession *session;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configurationForFileDownload = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.sendbird.sample.downloadsession"];
        configurationForFileDownload.sessionSendsLaunchEvents = YES;
        configurationForFileDownload.discretionary = NO;
        configurationForFileDownload.timeoutIntervalForResource = 300;
        session = [NSURLSession sessionWithConfiguration:configurationForFileDownload delegate:[[self class] sharedInstance] delegateQueue:nil];
    });
    return session;
}

#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSString *filePath = [DownloadManager sharedInstance].filePath[dataTask.currentRequest.URL.absoluteString];
    if (filePath != nil) {
        NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        [handle seekToEndOfFile];
        [handle writeData:data];
        [handle closeFile];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode >= 200 && statusCode < 300) {
            completionHandler(NSURLSessionResponseAllow);
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    
}


#pragma mark - NSURLSessionTaskDelegate for file transfer progress
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (error != nil) {
        return;
    }
    else {
        BOOL saveToLibrary = [[[DownloadManager sharedInstance].saveToLibrary objectForKey:task.currentRequest.URL.absoluteString] boolValue];
        NSString *filePath = [[DownloadManager sharedInstance].filePath objectForKey:task.currentRequest.URL.absoluteString];
        NSString *mimeType =[[DownloadManager sharedInstance].mimeType objectForKey:task.currentRequest.URL.absoluteString];
        
        [[DownloadManager sharedInstance].saveToLibrary removeObjectForKey:task.currentRequest.URL.absoluteString];
        [[DownloadManager sharedInstance].filePath removeObjectForKey:task.currentRequest.URL.absoluteString];
        [[DownloadManager sharedInstance].mimeType removeObjectForKey:task.currentRequest.URL.absoluteString];
        
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)task.response statusCode];
            if (statusCode >= 200 && statusCode < 300) {
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.title = @"File Downloaded.";
                if (saveToLibrary) {
                    content.body = @"Run Photos app to open the file.";
                }
                else {
                    content.body = @"Run Files app to open the file.";
                }
                
                NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                if ([mimeType hasPrefix:@"image"]) {
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                }
                else if ([mimeType hasPrefix:@"video"]) {
                    UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil);
                }
                
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"com.sendbird.sample.local" content:content trigger:trigger];
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    
                }];
            }
        }
    }
}

+ (void)downloadWithURL:(NSURL *)url filename:(NSString *)filename mimeType:(NSString *)mimeType addToMediaLibrary:(BOOL)addToMediaLibrary {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [[[self sharedInstance] backgroundSession] dataTaskWithRequest:request];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    if ([[DownloadManager sharedInstance].filePath objectForKey:url.absoluteString] == nil) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        [[DownloadManager sharedInstance].filePath setObject:filePath forKey:url.absoluteString];
        [[DownloadManager sharedInstance].saveToLibrary setObject:@(addToMediaLibrary) forKey:url.absoluteString];
        [[DownloadManager sharedInstance].mimeType setObject:mimeType forKey:url.absoluteString];
        [dataTask resume];
    }
}

@end
