//
//  UIImage+RemoteImage.m
//  topic
//
//  Created by Lukas Welte on 05.07.14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <objc/runtime.h>
#import "UIImage+RemoteImage.h"
#import "LWRemoteImageHelper.h"

@interface UIImageView (RemoteImage_Private)
@property(nonatomic, strong) NSURLSessionTask *task;
@end

@implementation UIImageView (RemoteImage_Private)

- (NSURLSessionTask *)task {
    return objc_getAssociatedObject(self,
            &kTaskKey);
}

- (void)setTask:(NSURLSessionTask *)newTask {
    objc_setAssociatedObject(self,
            &kTaskKey,
            newTask,
            OBJC_ASSOCIATION_COPY);
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    self.image = placeholder;
    NSURLSessionTask *downloadTask = [[LWRemoteImageHelper instance] imageWithURL:url success:^(UIImage *image) {
        self.image = image;
    }                                                                     failure:^(NSError *error) {
        NSLog(@"Error fetching image: %@", error.localizedDescription);
    }];
    self.task = downloadTask;
}

@end