//
//  LWDatabaseHelper.m
//  topic
//
//  Created by Lukas Welte on 04.07.14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWDatabaseHelper.h"
#import "FMDB.h"

@implementation LWDatabaseHelper

+ (LWDatabaseHelper *)instance {
    static LWDatabaseHelper *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

+ (NSString *)databasePath {
    NSString *databaseDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [databaseDirectory stringByAppendingPathComponent:@"topic.sqlite"];
}

- (id)init {
    self = [super init];
    if (self) {
        FMDatabaseQueue *databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[LWDatabaseHelper databasePath]];
        [databaseQueue inDatabase:^(FMDatabase *db) {
            if (![db open]) {
                return;
            }
            NSString *createCategoryTable = @"CREATE TABLE IF NOT EXISTS category( "
                    "localID INTEGER PRIMARY KEY   AUTOINCREMENT,"
                    "id INTEGER NOT NULL UNIQUE,"
                    "name TEXT NOT NULL"
                    ");";

            [db executeUpdate:createCategoryTable];

            NSString *createTopicTable = @"CREATE TABLE IF NOT EXISTS topic( "
                    "localID INTEGER PRIMARY KEY AUTOINCREMENT,"
                    "id INTEGER UNIQUE,"
                    "name TEXT NOT NULL,"
                    "startDate DATE,"
                    "endDate DATE,"
                    "categoryID INTEGER NOT NULL,"
                    "FOREIGN KEY(categoryID) REFERENCES category(id)"
                    ");";
            [db executeUpdate:createTopicTable];
            [db close];
        }];
    }

    return self;
}

- (void)executeDatabaseBlock:(void (^)(FMDatabase *db))block {
    FMDatabaseQueue *databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[LWDatabaseHelper databasePath]];
    [databaseQueue inDatabase:block];
}

@end
