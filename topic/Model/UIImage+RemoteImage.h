//
//  UIImage+RemoteImage.h
//  topic
//
//  Created by Lukas Welte on 05.07.14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <UIKit/UIKit.h>

static char const *const kTaskKey = "ImageFetchTask";

@interface UIImageView (RemoteImage)
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
@end