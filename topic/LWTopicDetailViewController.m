//
//  LWTopicDetailViewController.m
//  topic
//
//  Created by Lukas Welte on 04.07.14.
//  Copyright (c) 2014 Lukas Welte. All rights reserved.
//

#import "LWTopicDetailViewController.h"
#import "LWTopic.h"
#import "LWCategory.h"

@interface LWTopicDetailViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property(weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property(weak, nonatomic) IBOutlet UITextField *topicName;
@property(weak, nonatomic) IBOutlet UIButton *categoryButton;

@property(weak, nonatomic) IBOutlet UITextField *startTime;
@property(weak, nonatomic) IBOutlet UITextField *stopTime;
@property(weak, nonatomic) IBOutlet UIButton *startTimeButton;
@property(weak, nonatomic) IBOutlet UIButton *stopTimeButton;

@property(strong, nonatomic) NSDateFormatter *dateFormatter;

@property(nonatomic, strong) NSArray *categories;
@end

@implementation LWTopicDetailViewController

- (LWTopic *)topic {
    if (!_topic) {
        _topic = [[LWTopic alloc] init];
        self.title = @"Create Topic";
    }
    return _topic;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"dd/MM/yy";
    }

    return _dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.topicName.text = self.topic.name;
    self.topicName.delegate = self;

    NSString *categoryName = self.topic.category.name;
    if (categoryName && categoryName.length > 0) {
        [self.categoryButton setTitle:categoryName forState:UIControlStateNormal];
    }

    self.startTime.text = [self.dateFormatter stringFromDate:self.topic.startDate];
    self.stopTime.text = [self.dateFormatter stringFromDate:self.topic.endDate];

    [self.categoryButton addTarget:self action:@selector(selectCategory:) forControlEvents:UIControlEventTouchUpInside];
    [self.startTimeButton addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopTimeButton addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];

    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)selectTime:(UIButton *)sender {
    self.categories = [LWCategory fetchAllCategories];
    UIView *clickRemover = [[UIView alloc] initWithFrame:self.view.frame];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - 250, CGRectGetWidth(self.view.frame), 250)];
    container.backgroundColor = [UIColor whiteColor];
    container.layer.borderColor = [UIColor lightGrayColor].CGColor;
    container.layer.borderWidth = 0.5f;

    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeSystem];
    okButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [okButton setFrame:CGRectMake(CGRectGetMaxX(container.frame) - 80, 0, 80, 44)];
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(clickedOK:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:okButton];

    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(okButton.frame), CGRectGetWidth(container.frame), 1)];
    dividerView.backgroundColor = [UIColor lightGrayColor];
    [container addSubview:dividerView];

    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dividerView.frame), CGRectGetWidth(container.frame), 200)];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    if ([sender isEqual:self.startTimeButton]) {
        container.tag = 456;
        _datePicker.date = (self.topic.startDate) ? self.topic.startDate : [NSDate date];
        _datePicker.maximumDate = self.topic.endDate;
    } else {
        container.tag = 654;
        _datePicker.date = (self.topic.endDate) ? self.topic.endDate : [NSDate date];
        _datePicker.minimumDate = self.topic.startDate;
    }

    [container addSubview:_datePicker];
    [self.view addSubview:container];
    [clickRemover addSubview:container];
    [self.view addSubview:clickRemover];
}

- (void)selectCategory:(UIButton *)sender {
    CGRect senderFrame = sender.frame;

    self.categories = [LWCategory fetchAllCategories];

    UIView *clickRemover = [[UIView alloc] initWithFrame:self.view.frame];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(senderFrame), CGRectGetMaxY(senderFrame), CGRectGetWidth(senderFrame), 194)];
    container.backgroundColor = [UIColor whiteColor];
    container.layer.borderColor = [UIColor lightGrayColor].CGColor;
    container.layer.borderWidth = 0.5f;
    container.tag = 123;

    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeSystem];
    okButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [okButton setFrame:CGRectMake(CGRectGetMaxX(container.frame) - 90, 0, 80, 44)];
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(clickedOK:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:okButton];

    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(okButton.frame), CGRectGetWidth(senderFrame), 1)];
    dividerView.backgroundColor = [UIColor lightGrayColor];
    [container addSubview:dividerView];

    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dividerView.frame), CGRectGetWidth(senderFrame), 150)];
    pickerView.dataSource = self;
    pickerView.delegate = self;

    [container addSubview:pickerView];
    [clickRemover addSubview:container];
    [self.view addSubview:clickRemover];

    if (!self.topic.category) {
        [self pickerView:pickerView didSelectRow:0 inComponent:1];
    }
}

- (void)clickedOK:(UIButton *)clickedOK {
    UIView *superView = clickedOK.superview;
    if (superView.tag == 456) {
        self.topic.startDate = _datePicker.date;
        self.startTime.text = [self.dateFormatter stringFromDate:self.topic.startDate];
    } else if (superView.tag == 654) {
        self.topic.endDate = _datePicker.date;
        self.stopTime.text = [self.dateFormatter stringFromDate:self.topic.endDate];
    }
    [superView.superview removeFromSuperview];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.categories.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    LWCategory *category = self.categories[(NSUInteger) row];
    return category.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    LWCategory *category = self.categories[(NSUInteger) row];
    [self.categoryButton setTitle:category.name forState:UIControlStateNormal];
    self.topic.category = category;
}

- (IBAction)saveTopic:(id)sender {
    self.topic.name = self.topicName.text;

    BOOL saved = [self.topic saveToDatabase];
    if (saved) {
        [[[UIAlertView alloc] initWithTitle:@"Saved" message:@"Topic was successfully saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self.topic uploadToBackend];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Fault" message:@"There was a problem saving your topic. Check if all values are present" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.topicName]) {
        self.topic.name = textField.text;
    }
}

@end
