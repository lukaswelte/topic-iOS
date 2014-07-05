//
// Created by Lukas Welte on 05.07.14.
// Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <objc/runtime.h>
#import "LWRemoteImageHelper.h"

@interface LWRemoteImageHelper ()
@property(nonatomic, strong) NSURLSession *urlSession;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation LWRemoteImageHelper {

}

+ (LWRemoteImageHelper *)instance {
    static LWRemoteImageHelper *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 3;
        _operationQueue.name = @"Remote Image Fetches";

        NSURLSessionConfiguration *sessionImageConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionImageConfiguration.timeoutIntervalForResource = 6;
        sessionImageConfiguration.HTTPMaximumConnectionsPerHost = 2;
        sessionImageConfiguration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;

        _urlSession = [NSURLSession sessionWithConfiguration:sessionImageConfiguration delegate:nil delegateQueue:_operationQueue];
    }

    return self;
}

- (NSURLSessionTask *)imageWithURL:(NSURL *)url
                           success:(void (^)(UIImage *image))success
                           failure:(void (^)(NSError *error))failure {

    NSURLSessionTask *task = [_urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
            return failure(error);
        if (response)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image)
                        success(image);
                });
            });
    }];

    [task resume];
    return task;
}

@end