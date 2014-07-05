//
//  LWDatabaseHelper.h
//  topic
//
//  Created by Lukas Welte on 04.07.14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class FMDatabaseQueue;

@interface LWDatabaseHelper : NSObject

+ (LWDatabaseHelper *)instance;

- (void)executeDatabaseBlock:(void (^)(FMDatabase *db))block;
@end
