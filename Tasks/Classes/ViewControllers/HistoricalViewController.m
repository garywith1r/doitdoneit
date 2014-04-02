//
//  HistoricalViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/2/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "HistoricalViewController.h"
#import "DoneItTasksListViewController.h"
#import "StatsViewController.h"

@interface HistoricalViewController () {
    IBOutlet UIView* contentView;
    
    DoneItTasksListViewController* doneItTaskListViewController;
    StatsViewController* statsViewController;
    UIViewController* awardsViewController;
}

@end

@implementation HistoricalViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [contentView layoutIfNeeded];
    [self showDoneItView];
    
}

- (IBAction) segmentButtonPressed:(UISegmentedControl*) segment {
    switch (segment.selectedSegmentIndex) {
        case 0:
            [self showDoneItView];
            break;
        case 1:
            [self showAwards];
            break;
        case 2:
            [self showStats];
            break;
    }
}

- (void) showDoneItView {
    if (statsViewController)
        [statsViewController.view removeFromSuperview];
    if (awardsViewController)
        [awardsViewController.view removeFromSuperview];
    
    if (!doneItTaskListViewController) {
        doneItTaskListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DoneItViewController"];
        doneItTaskListViewController.view.frame = contentView.bounds;
    }
    
    [contentView addSubview:doneItTaskListViewController.view];
}

- (void) showAwards {
    if (statsViewController)
        [statsViewController.view removeFromSuperview];
    if (doneItTaskListViewController)
        [doneItTaskListViewController.view removeFromSuperview];
    
//    if (!doneItTaskListViewController)
//        doneItTaskListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DoneItViewController"];
}

- (void) showStats {
    if (doneItTaskListViewController)
        [doneItTaskListViewController.view removeFromSuperview];
    if (awardsViewController)
        [awardsViewController.view removeFromSuperview];
    
    if (!statsViewController) {
        statsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StatsViewController"];
        statsViewController.view.frame = contentView.bounds;
    }
    
    [contentView addSubview:statsViewController.view];
}

@end
