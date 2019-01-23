//
//  Utils.m
//  SendBird-iOS
//
//  Created by SendBird on 2/20/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSString *)getMessageDateStringFromTimestamp:(long long)timestamp {
    NSString *messageDateString;
    NSDateFormatter *messageDateFormatter = [[NSDateFormatter alloc] init];
    NSDate *messageDate = nil;
    if ([NSString stringWithFormat:@"%lld", timestamp].length == 10) {
        messageDate = [NSDate dateWithTimeIntervalSince1970:(double)timestamp];
    }
    else {
        messageDate = [NSDate dateWithTimeIntervalSince1970:(double)timestamp / 1000.0];
    }
    
    [messageDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [messageDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    messageDateString = [messageDateFormatter stringFromDate:messageDate];
    
    return messageDateString;
}

+ (NSString *)getDateStringForDateSeperatorFromTimestamp:(long long)timestamp {
    NSString *messageDateString;
    NSDateFormatter *messageDateFormatter = [[NSDateFormatter alloc] init];
    NSDate *messageDate = nil;
    if ([NSString stringWithFormat:@"%lld", timestamp].length == 10) {
        messageDate = [NSDate dateWithTimeIntervalSince1970:(double)timestamp];
    }
    else {
        messageDate = [NSDate dateWithTimeIntervalSince1970:(double)timestamp / 1000.0];
    }
    
    [messageDateFormatter setDateStyle:NSDateFormatterLongStyle];
    [messageDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    messageDateString = [messageDateFormatter stringFromDate:messageDate];
    
    return messageDateString;
}

+ (BOOL)checkDayChangeDayBetweenOldTimestamp:(long long)oldTimestamp newTimestamp:(long long)newTimestamp {
    NSDate *oldMessageDate = nil;
    NSDate *newMessageDate = nil;
    
    if ([NSString stringWithFormat:@"%lld", oldTimestamp].length == 10) {
        oldMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)oldTimestamp];
    }
    else {
        oldMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)oldTimestamp / 1000.0];
    }
    
    if ([NSString stringWithFormat:@"%lld", newTimestamp].length == 10) {
        newMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)newTimestamp];
    }
    else {
        newMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)newTimestamp / 1000.0];
    }

    NSDateComponents *oldMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:oldMessageDate];
    NSDateComponents *newMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:newMessageDate];
    
    if (oldMessageDateComponents.year != newMessageDateComponents.year || oldMessageDateComponents.month != newMessageDateComponents.month || oldMessageDateComponents.day != newMessageDateComponents.day) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (NSString *)createGroupChannelName:(SBDGroupChannel *)channel {
    if (channel.name.length > 0) {
        return channel.name;
    }
    else {
        return [self createGroupChannelNameFromMembers:channel];
    }
}

+ (NSString *)createGroupChannelNameFromMembers:(SBDGroupChannel *)channel {
    NSMutableArray<NSString *> *memberNicknames = [[NSMutableArray alloc] init];
    int count = 0;
    for (SBDUser *member in channel.members) {
        if ([member.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            continue;
        }
        
        [memberNicknames addObject:member.nickname];
        count += 1;
        if (count == 4) {
            break;
        }
    }
    
    NSString *channelName;
    
    if (count == 0) {
        channelName = @"NO MEMBERS";
    }
    else {
        channelName = [memberNicknames componentsJoinedByString:@", "];
    }
    
    return channelName;
}

+ (void)showAlertControllerWithError:(SBDError *)error viewController:(UIViewController *)viewController {
    NSString *errorMessage = [NSString stringWithFormat:@"%@(%ld)", error.domain, error.code];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:closeAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController presentViewController:vc animated:YES completion:nil];
    });
}

+ (void)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewController {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:closeAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController presentViewController:vc animated:YES completion:nil];
    });
}


+ (NSString *)buildTypingIndicatorLabel:(SBDGroupChannel *)channel {
    NSArray<SBDMember *> *typingMembers = [channel getTypingMembers];
    if (typingMembers == nil || typingMembers.count == 0) {
        return @"";
    }
    else {
        if (typingMembers.count == 1) {
            return [NSString stringWithFormat:@"%@ is typing.", typingMembers[0].nickname];
        }
        else if (typingMembers.count == 2) {
            return [NSString stringWithFormat:@"%@ and %@ are typing.", typingMembers[0].nickname, typingMembers[1].nickname];
        }
        else {
            return @"Several people are typing.";
        }
    }
}

+ (NSString *)transformUserProfileImage:(SBDUser *)user {
    if ([user.profileUrl hasPrefix:@"https://sendbird.com/main/img/profiles"]) {
        return @"";
    }
    else {
        return user.profileUrl;
    }
}

+ (UIImage *)getDefaultUserProfileImage:(SBDUser *)user {
    switch (user.nickname.length % 4) {
        case 0:
            return [UIImage imageNamed:@"img_default_profile_image_1"];
            break;
        case 1:
            return [UIImage imageNamed:@"img_default_profile_image_2"];
            break;
        case 2:
            return [UIImage imageNamed:@"img_default_profile_image_3"];
            break;
        case 3:
            return [UIImage imageNamed:@"img_default_profile_image_4"];
            break;
        default:
            return [UIImage imageNamed:@"img_default_profile_image_1"];
            break;
    }
}

@end
