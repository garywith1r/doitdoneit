//
//  SelectRepeatTimesViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/23/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SelectRepeatTimesViewController.h"


@interface SelectRepeatTimesViewController () {
    IBOutletCollection(UIButton) NSArray* repeatTimeIntervalButtons;
    IBOutlet UILabel* lblRepeatTimes;
    IBOutlet UIButton* increaseButton;
    IBOutlet UIButton* decreaseButton;
    
    NSInteger repeatTimes;
    NSInteger repeatTimesInterval;

}

@end

@implementation SelectRepeatTimesViewController



- (void) setInitialTimes:(NSInteger)times andInitialTimeInterval:(NSInteger)interval {
    repeatTimes = times;
    repeatTimesInterval = interval;
    
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
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
    [super doneButtonPressed];
}




@end
