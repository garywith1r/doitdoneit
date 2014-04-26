//
//  EditTaskViewController.m
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SelectDateViewController.h"
#import "MNCalendarView.h"

@interface SelectDateViewController () <MNCalendarViewDelegate>{
    IBOutlet MNCalendarView *calendarView;
}

@end

@implementation SelectDateViewController
@synthesize delegate, startDate;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    
//    MNCalendarView *calendarView = [[MNCalendarView alloc] initWithFrame:self.view.bounds];
    if (self.startDate)
        calendarView.selectedDate = self.startDate;
    else
        calendarView.selectedDate = [NSDate date];
    calendarView.delegate = self;
}

- (IBAction) save {
    if([self.delegate respondsToSelector:@selector(didSelectDate:)])
        [self.delegate didSelectDate:self.startDate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)calendarView:(MNCalendarView *)calendarView didSelectDate:(NSDate *)date {
    self.startDate = date;
    [self save];
}

@end
