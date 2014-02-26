//
//  EditTaskViewController.m
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SelectDateViewController.h"

@interface SelectDateViewController () {
    IBOutlet UIDatePicker* datePicker;
}

@end

@implementation SelectDateViewController
@synthesize delegate, startDate;

- (void) viewDidLoad {
    [super viewDidLoad];
    if (self.startDate)
        datePicker.date = self.startDate;
}

- (IBAction) save {
    if([self.delegate respondsToSelector:@selector(didSelectDate:)])
        [self.delegate didSelectDate:datePicker.date];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
