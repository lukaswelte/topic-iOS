//
// Created by Lukas Welte on 05.07.14.
// Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LWRemoteImageHelper : NSObject
+ (LWRemoteImageHelper *)instance;

- (NSURLSessionTask *)imageWithURL:(NSURL *)url success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;
@end
