//
// Created by Lukas Welte on 04.07.14.
// Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LWTopic;

static NSString *const kSyncCompleted = @"SyncCompleted";

static NSString *const kSyncFailed = @"SyncFailed";

@interface LWBackendSyncController : NSObject
+ (LWBackendSyncController *)instance;

- (void)syncWithBackend;

- (void)setTokenAndStartSync:(NSString *)token;

+ (NSDate *)dateFromAPITimeString:(NSString *)dateString;

+ (NSString *)apiStringFromDate:(NSDate *)date;

- (void)uploadTopic:(LWTopic *)topic;
@end