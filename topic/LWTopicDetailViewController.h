//
//  LWTopicDetailViewController.h
//  topic
//
//  Created by Lukas Welte on 04.07.14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWTopic;

@interface LWTopicDetailViewController : UIViewController {
    UIDatePicker *_datePicker;
}
@property(nonatomic, strong) LWTopic *topic;
@end
