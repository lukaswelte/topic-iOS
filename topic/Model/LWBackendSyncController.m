//
// Created by Lukas Welte on 04.07.14.
// Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWBackendSyncController.h"
#import "LWCategory.h"
#import "LWTopic.h"


static NSString *const kTopicUploadList = @"topicUploadList";

@interface LWBackendSyncController () <NSURLSessionDelegate>
@property(nonatomic, copy) NSString *token;
@property(nonatomic, strong) NSURLSession *urlSession;
@end

@implementation LWBackendSyncController {

}
+ (LWBackendSyncController *)instance {
    static LWBackendSyncController *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {

    }

    return self;
}

- (void)setToken:(NSString *)token {
    _token = [token mutableCopy];
    [self setupURLSession];
}

- (void)setupURLSession {
    NSURLSessionConfiguration *sessionConfig =
            [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess = YES;
    [sessionConfig setHTTPAdditionalHeaders:
            @{
                    @"Accept" : @"application/json",
                    @"TOKEN" : self.token
            }];

    sessionConfig.timeoutIntervalForRequest = 30.0;
    sessionConfig.timeoutIntervalForResource = 60.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;

    self.urlSession =
            [NSURLSession sessionWithConfiguration:sessionConfig
                                          delegate:self
                                     delegateQueue:nil];
}

- (void)syncWithBackend {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self uploadUnsyncedTopics];

        [[self.urlSession dataTaskWithURL:self.categoryAPIPathURL
                        completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                    // handle response
                    if (!error) {
                        NSError *jsonError = nil;
                        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                        if (!jsonError && jsonResponse) {
                            NSArray *categories = jsonResponse[@"msg"];
                            [LWCategory updateOrInsertObjects:categories];

                            [self fetchTopicsFromBackend];
                        } else {
                            [self postSyncErrorNotification];
                        }
                    } else {
                        [self postSyncErrorNotification];
                    }

                }] resume];
    });
}

- (void)uploadUnsyncedTopics {
    NSArray *unsyncedTopics = [self unsyncedTopics];
    for (LWTopic *topic in unsyncedTopics) {
        [topic uploadToBackend];
    }
}

- (void)fetchTopicsFromBackend {
    [[self.urlSession dataTaskWithURL:self.topicAPIPathURL completionHandler:^(NSData *topicData, NSURLResponse *topicResponse, NSError *topicError) {
        if (topicError) {
            [self postSyncErrorNotification];
            return;
        }

        NSError *topicJsonError = nil;
        NSDictionary *topicJsonResponse = [NSJSONSerialization JSONObjectWithData:topicData options:NSJSONReadingAllowFragments error:&topicJsonError];
        if (!topicJsonError && topicJsonResponse) {
            NSArray *topics = topicJsonResponse[@"msg"];
            [LWTopic updateOrInsertObjects:topics];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSyncCompleted object:nil];
        } else {
            [self postSyncErrorNotification];
        }
    }] resume];
}

- (void)postSyncErrorNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSyncFailed object:nil];
}

- (NSURL *)categoryAPIPathURL {
    return [NSURL URLWithString:@"http://lukaswelte.de/topic/category"];
}

- (NSURL *)topicAPIPathURL {
    return [NSURL URLWithString:@"http://lukaswelte.de/topic/topic"];
}

- (NSURL *)topicUpdateURLForTopic:(LWTopic *)topic {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://lukaswelte.de/topic/topic/%d", topic.identifier.integerValue]];
}

- (void)setTokenAndStartSync:(NSString *)token {
    self.token = token;
    [self syncWithBackend];
}

static NSDateFormatter *apiDateFormatter = nil;

+ (NSDate *)dateFromAPITimeString:(NSString *)dateString {
    NSAssert(dateString != nil, @"Only string with date can be converted");

    if (!apiDateFormatter) {
        apiDateFormatter = [[NSDateFormatter alloc] init];
        apiDateFormatter.dateFormat = @"yyyy-MM-dd";
    }

    return [apiDateFormatter dateFromString:dateString];
}

+ (NSString *)apiStringFromDate:(NSDate *)date {
    NSAssert(date != nil, @"Only dates can be converted");

    if (!apiDateFormatter) {
        apiDateFormatter = [[NSDateFormatter alloc] init];
        apiDateFormatter.dateFormat = @"yyyy-MM-dd";
    }

    return [apiDateFormatter stringFromDate:date];
}

- (void)uploadTopic:(LWTopic *)topic {
    if (!topic.identifier || topic.identifier.integerValue <= 0) {
        //Insert topic

        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.topicAPIPathURL];
        [urlRequest setHTTPMethod:@"POST"];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:topic.dictionaryRepresentation options:NSJSONWritingPrettyPrinted error:&error];
        [urlRequest setHTTPBody:jsonData];

        [[self.urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *responseError) {
            if (!responseError) {
                NSError *jsonError;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                if (!jsonError) {
                    topic.identifier = responseDictionary[@"msg"];
                    [topic saveToDatabase];
                }
            }
        }] resume];
    } else {
        //Topic is a update

        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[self topicUpdateURLForTopic:topic]];
        [urlRequest setHTTPMethod:@"PUT"];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:topic.dictionaryRepresentation options:NSJSONWritingPrettyPrinted error:&error];
        [urlRequest setHTTPBody:jsonData];

        [[self.urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *responseError) {
            if (!responseError) {
                NSError *jsonError;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                if (!jsonError) {
                    NSString *successString = responseDictionary[@"msg"];
                    if ([successString.lowercaseString isEqualToString:@"success"]) {
                        return;
                    }
                }
            }

            [self addTopicToUploadList:topic];
        }] resume];
    }
}

- (NSArray *)unsyncedTopics {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSArray *topicIDS = [[userDefaults objectForKey:kTopicUploadList] copy];
    [userDefaults removeObjectForKey:kTopicUploadList];
    [userDefaults synchronize];

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:topicIDS.count];
    for (NSNumber *topicID in topicIDS) {
        [result addObject:[LWTopic topicWithIdentifier:topicID]];
    }

    [result addObjectsFromArray:[LWTopic notUploadedTopics]];

    return result;
}

- (void)addTopicToUploadList:(LWTopic *)topic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray *array = [[userDefaults objectForKey:kTopicUploadList] mutableCopy];
    if (!array) {
        array = [NSMutableArray array];
    }

    [array addObject:topic.identifier];
    [userDefaults setObject:array forKey:kTopicUploadList];
    [userDefaults synchronize];
}

@end