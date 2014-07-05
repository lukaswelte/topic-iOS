//
//  LWTopic.m
//  topic
//
//  Created by Lukas Welte on 04.07.14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWTopic.h"
#import "LWCategory.h"
#import "LWDatabaseHelper.h"
#import "FMDatabase.h"
#import "LWBackendSyncController.h"

@interface LWTopic ()
@property(nonatomic, strong) NSNumber *localIdentifier;
@end

@implementation LWTopic

- (instancetype)initWithIdentifier:(NSNumber *)identifier name:(NSString *)name category:(LWCategory *)category startDate:(NSDate *)startDate endDate:(NSDate *)endDate localIdentifier:(NSNumber *)localIdentifier {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.name = name;
        self.category = category;
        self.startDate = startDate;
        self.endDate = endDate;
        self.localIdentifier = localIdentifier;
    }

    return self;
}


- (instancetype)initWithName:(NSString *)name category:(LWCategory *)category startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    return [self initWithIdentifier:@(-1) name:name category:category startDate:startDate endDate:endDate localIdentifier:@(-1)];
}

+ (instancetype)topicWithName:(NSString *)name category:(LWCategory *)category startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    return [[self alloc] initWithName:name category:category startDate:startDate endDate:endDate];
}

- (BOOL)saveToDatabase {
    __block BOOL successful = NO;
    [[LWDatabaseHelper instance] executeDatabaseBlock:^(FMDatabase *db) {
        if (![db open]) {
            return;
        }

        if (self.identifier && self.identifier.integerValue > 0) {
            FMResultSet *resultSet = [db executeQuery:@"SELECT id FROM topic WHERE id = ?", self.identifier];
            if ([resultSet next]) {
                successful = [db executeUpdate:@"UPDATE topic SET name = ?, startDate = ?, endDate = ?, categoryID = ? WHERE id = ?", self.name, self.startDate, self.endDate, self.category.identifier, self.identifier];
            }

        }

        if (!successful) {
            if (self.localIdentifier && self.localIdentifier.integerValue > 0) {
                FMResultSet *resultSet = [db executeQuery:@"SELECT id FROM topic WHERE localID = ?", self.localIdentifier];
                if ([resultSet next]) {
                    successful = [db executeUpdate:@"UPDATE topic SET id = ?, name = ?, startDate = ?, endDate = ?, categoryID = ? WHERE localID = ?", self.identifier, self.name, self.startDate, self.endDate, self.category.identifier, self.localIdentifier];
                }
            }
        }

        if (!successful) {
            successful = [db executeUpdate:@"INSERT INTO topic (id, name, startDate, endDate, categoryID) VALUES (?,?,?,?,?)", self.identifier, self.name, self.startDate, self.endDate, self.category.identifier];
            if (successful) {
                self.localIdentifier = @(db.lastInsertRowId);
            }
        }

        [db close];

    }];
    return successful;
}

+ (LWTopic *)objectWithIdentifier:(NSNumber *)identifier {
    return [LWTopic topicWithIdentifier:identifier];
}

- (void)uploadToBackend {
    [[LWBackendSyncController instance] uploadTopic:self];
}

+ (void)updateOrInsertObjects:(NSArray *)array {
    for (NSDictionary *dictionary in array) {
        NSNumber *identifier = dictionary[@"id"];
        NSString *name = dictionary[@"name"];
        NSDate *startDate = [LWBackendSyncController dateFromAPITimeString:dictionary[@"startdate"]];
        NSDate *endDate = [LWBackendSyncController dateFromAPITimeString:dictionary[@"enddate"]];
        LWCategory *category = [LWCategory categoryWithIdentifier:dictionary[@"category"]];

        LWTopic *topic = [[LWTopic alloc] initWithIdentifier:identifier name:name category:category startDate:startDate endDate:endDate localIdentifier:@(-1)];
        [topic saveToDatabase];
    }
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:5];
    if (self.name) {
        [result setObject:self.name forKey:@"name"];
    }

    NSString *startDate = [LWBackendSyncController apiStringFromDate:self.startDate];
    if (startDate) {
        [result setObject:startDate forKey:@"startdate"];
    }

    NSString *endDate = [LWBackendSyncController apiStringFromDate:self.endDate];
    if (endDate) {
        [result setObject:endDate forKey:@"enddate"];
    }

    if (self.category.identifier) {
        [result setObject:self.category.identifier forKey:@"category"];
    }

    if (self.identifier) {
        [result setObject:self.identifier forKey:@"id"];
    }
    return result;
}


+ (LWTopic *)topicWithIdentifier:(NSNumber *)identifier {
    __block  LWTopic *resultTopic = nil;
    [[LWDatabaseHelper instance] executeDatabaseBlock:^(FMDatabase *db) {
        if (![db open]) {
            return;
        }
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM topic WHERE id = ?", identifier];

        while ([resultSet next]) {
            NSNumber *localID = @([resultSet intForColumn:@"localID"]);
            NSString *name = [resultSet stringForColumn:@"name"];
            NSDate *startDate = [resultSet dateForColumn:@"startDate"];
            NSDate *endDate = [resultSet dateForColumn:@"endDate"];
            LWCategory *category = [LWCategory categoryWithIdentifier:@([resultSet intForColumn:@"categoryID"])];

            resultTopic = [[LWTopic alloc] initWithIdentifier:identifier name:name category:category startDate:startDate endDate:endDate localIdentifier:localID];
        }
        [db close];
    }];

    return resultTopic;
}

+ (NSArray *)fetchAllTopics {
    __block  NSMutableArray *fetchedTopics = [NSMutableArray array];
    [[LWDatabaseHelper instance] executeDatabaseBlock:^(FMDatabase *db) {
        if (![db open]) {
            return;
        }

        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM topic"];

        while ([resultSet next]) {
            NSNumber *localID = @([resultSet intForColumn:@"localID"]);
            NSNumber *identifier = @([resultSet intForColumn:@"id"]);
            NSString *name = [resultSet stringForColumn:@"name"];
            NSDate *startDate = [resultSet dateForColumn:@"startDate"];
            NSDate *endDate = [resultSet dateForColumn:@"endDate"];
            LWCategory *category = [LWCategory categoryWithIdentifier:@([resultSet intForColumn:@"categoryID"])];

            LWTopic *topic = [[LWTopic alloc] initWithIdentifier:identifier name:name category:category startDate:startDate endDate:endDate localIdentifier:localID];
            [fetchedTopics addObject:topic];
        }

        [db close];
    }];

    return fetchedTopics;
}

+ (NSArray *)notUploadedTopics {
    __block  NSMutableArray *fetchedTopics = [NSMutableArray array];
    [[LWDatabaseHelper instance] executeDatabaseBlock:^(FMDatabase *db) {
        if (![db open]) {
            return;
        }

        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM topic WHERE id=NULL OR id = 0"];

        while ([resultSet next]) {
            NSNumber *localID = @([resultSet intForColumn:@"localID"]);
            NSNumber *identifier = @([resultSet intForColumn:@"id"]);
            NSString *name = [resultSet stringForColumn:@"name"];
            NSDate *startDate = [resultSet dateForColumn:@"startDate"];
            NSDate *endDate = [resultSet dateForColumn:@"endDate"];
            LWCategory *category = [LWCategory categoryWithIdentifier:@([resultSet intForColumn:@"categoryID"])];

            LWTopic *topic = [[LWTopic alloc] initWithIdentifier:identifier name:name category:category startDate:startDate endDate:endDate localIdentifier:localID];
            [fetchedTopics addObject:topic];
        }

        [db close];
    }];

    return fetchedTopics;
}
@end