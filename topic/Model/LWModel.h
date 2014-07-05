//
// Created by Lukas Welte on 04.07.14.
// Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LWModel <NSObject>
- (BOOL)saveToDatabase;

+ (id)objectWithIdentifier:(NSNumber *)identifier;

+ (void)updateOrInsertObjects:(NSArray *)array;

- (NSDictionary *)dictionaryRepresentation;
@end