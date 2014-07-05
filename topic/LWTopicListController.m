//
//  LWTopicListController.m
//  topic
//
//  Created by Lukas Welte on 03.07.14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWTopicListController.h"
#import "LWArrayDataSource.h"
#import "LWTopic.h"
#import "LWBackendSyncController.h"
#import "LWTopicDetailViewController.h"

@interface LWTopicListController () <UITableViewDelegate>
@property(nonatomic, strong) LWArrayDataSource *dataSource;
@end

@implementation LWTopicListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES; //Don't allow going back to the login screen

    self.tableView.delegate = self;

    [self.refreshControl addTarget:self action:@selector(refreshTopics:) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTopics:(id)refreshTopics {
    [[LWBackendSyncController instance] syncWithBackend];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateTopics:) name:kSyncCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailUpdating:) name:kSyncFailed object:nil];
    [self reloadTableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadTableView {
    self.dataSource = [[LWArrayDataSource alloc] initWithItems:[LWTopic fetchAllTopics] cellIdentifier:@"topicCell" configureCellBlock:^(UITableViewCell *cell, LWTopic *item) {
        cell.textLabel.text = item.name;
    }];

    self.tableView.dataSource = self.dataSource;
    [self.tableView reloadData];
}

- (void)didUpdateTopics:(NSNotification *)notification {
    [self reloadTableView];
    [self.refreshControl endRefreshing];
}

- (void)didFailUpdating:(NSNotification *)notification {
    [self.refreshControl endRefreshing];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LWTopic *selectedTopic = [self.dataSource itemAtIndexPath:indexPath];
    LWTopicDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TopicDetail"];
    viewController.topic = selectedTopic;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
