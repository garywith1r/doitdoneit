//
//  CompleteTaskViewController.m
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "CompleteTaskViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CompleteTaskViewController () {
    IBOutlet UITextView* textView;
    
    IBOutlet UIButton* goodQualityButton;
    IBOutlet UIButton* averageQualityButton;
    IBOutlet UIButton* badQualityButton;
    
    int workQuality;
}

@end

@implementation CompleteTaskViewController

+ (void)showInParentView:(UIViewController *)parent forTask:(TaskDTO *)task {
    CompleteTaskViewController *completeTaskController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"CompleteTaskScreen"];
    
    [parent addChildViewController:completeTaskController];
    [parent.view addSubview:completeTaskController.view];
    
    completeTaskController.view.alpha = 0;
    [UIView beginAnimations:NULL context:nil];
    [UIView setAnimationDuration:0.3];
    completeTaskController.view.alpha = 1;
    [UIView commitAnimations];
    
    completeTaskController.task = task;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    textView.layer.cornerRadius = 5;
    textView.layer.masksToBounds = YES;
}


- (IBAction) setWorkQuality:(UIButton*)sender {
    goodQualityButton.alpha = averageQualityButton.alpha = badQualityButton.alpha = 0.5;
    sender.alpha =1;
    
    workQuality = sender.tag;
}

- (IBAction)save {
    self.task.notes = textView.text;
    [self close];
}

- (IBAction)close {
    self.view.alpha = 1;
    [UIView beginAnimations:NULL context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop)];
    self.view.alpha = 0;
    [UIView commitAnimations];
}

- (void) animationDidStop {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
