//
// Created by Lukas Welte on 19.04.14.
// Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^TableViewCellConfigureBlock)(id cell, id item);

@interface LWArrayDataSource : NSObject <UITableViewDataSource, UICollectionViewDataSource>

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
@end