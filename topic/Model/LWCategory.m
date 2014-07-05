//
//  LWCategory.m
//  topic
//
//  Created by Lukas Welte on 04.07.14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWCategory.h"
#import "FMDatabase.h"
#import "LWDatabaseHelper.h"

@implementation LWCategory

- (instancetype)initWithIdentifier:(NSNumber *)identifier name:(NSString *)name {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _name = name;
    }

    return self;
}

+ (instancetype)categoryWithIdentifier:(NSNumber *)identifier name:(NSString *)name {
    return [[self alloc] initWithIdentifier:identifier name:name];
}

+ (id)objectWithIdentifier:(NSNumber *)identifier {
    return [LWCategory categoryWithIdentifier:identifier];
}

+ (LWCategory *)categoryWithIdentifier:(NSNumber *)identifier {
    __block  LWCategory *resultCategory = nil;
    [[LWDatabaseHelper instance] executeDatabaseBlock:^(FMDatabase *db) {
        if (![db open]) {
            return;
        }
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM category WHERE id = ?", identifier];

        while ([resultSet next]) {
            NSString *name = [resultSet stringForColumn:@"name"];

            resultCategory = [LWCategory categoryWithIdentifier:identifier name:name];
        }
        [db close];
    }];

    return resultCategory;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
            @"id" : self.identifier,
            @"name" : self.name
    };
}

+ (void)updateOrInsertObjects:(NSArray *)array {
    for (NSDictionary *dictionary in array) {
        NSNumber *identifier = dictionary[@"id"];
        NSString *name = dictionary[@"name"];

        LWCategory *category = [LWCategory categoryWithIdentifier:identifier name:name];
        [category saveToDatabase];
    }
}

- (BOOL)saveToDatabase {
    __block BOOL successful = NO;
    [[LWDatabaseHelper instance] executeDatabaseBlock:^(FMDatabase *db) {
        if (![db open]) {
            successful = NO;
            return;
        }

        FMResultSet *resultSet = [db executeQuery:@"SELECT id FROM category WHERE id=?", self.identifier];
        if ([resultSet next]) {
            successful = [db executeUpdate:@"UPDATE category SET name = ? WHERE id = ?", self.name, self.identifier];

        } else {
            successful = [db executeUpdate:@"INSERT INTO category (id, name) VALUES (?,?)", self.identifier, self.name];
        }

        [db close];
    }];
    return successful;
}

+ (NSArray *)fetchAllCategories {
    __block  NSMutableArray *fetchedCategories = [NSMutableArray array];
    [[LWDatabaseHelper instance] executeDatabaseBlock:^(FMDatabase *db) {
        if (![db open]) {
            return;
        }

        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM category"];

        while ([resultSet next]) {
            NSNumber *identifier = @([resultSet intForColumn:@"id"]);
            NSString *name = [resultSet stringForColumn:@"name"];

            LWCategory *category = [LWCategory categoryWithIdentifier:identifier name:name];
            [fetchedCategories addObject:category];
        }

        [db close];
    }];

    return fetchedCategories;
}

@end
