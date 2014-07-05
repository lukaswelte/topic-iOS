//
//  LWTopic.h
//  topic
//
//  Created by Lukas Welte on 04.07.14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWModel.h"

@class LWCategory;

@interface LWTopic : NSObject <LWModel>
@property(nonatomic, strong) NSNumber *identifier;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) LWCategory *category;
@property(nonatomic, strong) NSDate *startDate;
@property(nonatomic, strong) NSDate *endDate;

- (instancetype)initWithName:(NSString *)name category:(LWCategory *)category startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (instancetype)topicWithName:(NSString *)name category:(LWCategory *)category startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

- (void)uploadToBackend;

+ (LWTopic *)topicWithIdentifier:(NSNumber *)identifier;

+ (NSArray *)fetchAllTopics;

+ (NSArray *)notUploadedTopics;
@end
