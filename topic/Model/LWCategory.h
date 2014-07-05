//
//  LWCategory.h
//  topic
//
//  Created by Lukas Welte on 04.07.14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWModel.h"

@interface LWCategory : NSObject <LWModel>

@property(nonatomic, readonly) NSNumber *identifier;
@property(nonatomic, readonly) NSString *name;

+ (LWCategory *)categoryWithIdentifier:(NSNumber *)identifier;

+ (NSArray *)fetchAllCategories;
@end
