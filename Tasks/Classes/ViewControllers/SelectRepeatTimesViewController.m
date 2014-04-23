//
//  SelectRepeatTimesViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/23/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SelectRepeatTimesViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SelectRepeatTimesViewController () {
    IBOutletCollection(UIButton) NSArray* repeatTimeIntervalButtons;
    IBOutlet UILabel* lblRepeatTimes;
    IBOutlet UIButton* increaseButton;
    IBOutlet UIButton* decreaseButton;
    
    NSInteger repeatTimes;
    NSInteger repeatTimesInterval;
    
    IBOutlet UIView* contentView;
}

@end

@implementation SelectRepeatTimesViewController

- (void) presentOnViewController:(UIViewController*)viewController {
    [viewController.view addSubview:self.view];
    [viewController addChildViewController:self];
    
    [UIView beginAnimations:NULL context:nil];
    [UIView setAnimationDuration:0.3];
    self.view.alpha = 1;
    [UIView commitAnimations];
}

- (void) setInitialTimes:(NSInteger)times andInitialTimeInterval:(NSInteger)interval {
    repeatTimes = times;
    repeatTimesInterval = interval;
    
}

- (void) viewDidLoad {
    [super viewDidLoad];
    contentView.layer.cornerRadius = 5;
    contentView.layer.masksToBounds = YES;
    
    lblRepeatTimes.layer.borderColor = [UIColor blackColor].CGColor;
    lblRepeatTimes.layer.borderWidth = 1.0;
    lblRepeatTimes.layer.cornerRadius = 10;
    contentView.layer.masksToBounds = YES;
    
    lblRepeatTimes.text = [NSString stringWithFormat:@"%d",repeatTimes];
    
    decreaseButton.enabled = (repeatTimes != 1);
    increaseButton.enabled = (repeatTimes != 9);
    
    ((UIButton*)repeatTimeIntervalButtons[repeatTimesInterval]).selected = TRUE;
}

- (IBAction) increaseRepeatTimes {
    repeatTimes++;
    lblRepeatTimes.text = [NSString stringWithFormat:@"%d",repeatTimes];
    if (repeatTimes == 9)
        increaseButton.enabled = NO;
    else
        increaseButton.enabled = YES;
    
    decreaseButton.enabled = YES;
}

- (IBAction) decreaseRepeatTimes {
    repeatTimes--;
    lblRepeatTimes.text = [NSString stringWithFormat:@"%d",repeatTimes];
    if (repeatTimes == 1)
        decreaseButton.enabled = NO;
    else
        decreaseButton.enabled = YES;
    
    increaseButton.enabled = YES;
}

- (IBAction) repeatTimeIntervalButtonPressed:(UIButton*) sender {
    for (UIButton* button in repeatTimeIntervalButtons) {
        button.selected = NO;
    }
    
    sender.selected = YES;
    repeatTimesInterval = sender.tag;
}

- (IBAction) doneButtonPressed {
    if ([self.delegate respondsToSelector:@selector(selectedRepeatTimes:perTimeInterval:)])
        [self.delegate selectedRepeatTimes:repeatTimes perTimeInterval:repeatTimesInterval];
    [self closeButtonPressed];
}

- (IBAction) closeButtonPressed {
    [UIView beginAnimations:NULL context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(viewFadedOut)];
    self.view.alpha = 0;
    [UIView commitAnimations];
}

- (void) viewFadedOut {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}


@end
