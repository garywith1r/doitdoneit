//
//  CompleteTaskViewController.m
//  self.tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "CompleteTaskViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DAAttributedLabel.h"
#import "SVWebViewController.h"
#import "MediaModel.h"
#import "TaskListModel.h"
#import "Constants.h"
#import "DAAttributedLabel.h"
#import "DeviceDetector.h"

@interface CompleteTaskViewController () <DAAttributedLabelDelegate>{
    IBOutlet UILabel* lblTitle;
    IBOutlet UILabel* lblStats;
    IBOutlet UILabel* lblDueDate;
    IBOutlet UILabel* lblRepeatTimes;
    IBOutlet UIButton* thumbImageButton;
    IBOutlet DAAttributedLabel* lblDescription;
    
    IBOutletCollection(UIButton) NSArray* ratingButtons;
    IBOutlet UITextField* txtNotes;
    
    IBOutlet NSLayoutConstraint* lblDescriptionHeightConstrait;
    IBOutlet NSLayoutConstraint* scrollViewBottomSpaceConstrait;
    IBOutlet NSLayoutConstraint* scrollViewHeightConstrait;
    
    IBOutlet UIView* contentView;
    IBOutlet UIScrollView* scrollView;
    
    CGFloat scrollViewBottomSpaceConstantOriginalValue;
    
    
    NSInteger ratingTemp;
    BOOL textIsUp;
}

@end

@implementation CompleteTaskViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    scrollViewHeightConstrait.constant = [[UIScreen mainScreen] applicationFrame].size.height;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        scrollViewHeightConstrait.constant -= (self.tabBarController.tabBar.frame.size.height + self.navigationController.navigationBar.frame.size.height);
    
    lblTitle.text = self.task.title;
    
    thumbImageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [thumbImageButton setImage:self.task.thumbImage forState:UIControlStateNormal];
    
    
    if (self.task.repeatTimes != 1) {
        lblRepeatTimes.text = [NSString stringWithFormat:@"%d of %d", (int)self.task.currentRepetition, (int)self.task.repeatTimes];
    } else {
        lblRepeatTimes.text = @"";
    }
    
    
    int remainingDays = ceil([self.task.dueDate timeIntervalSinceDate:[NSDate date]] /60.0 /60.0 /24.0);
    
    if (remainingDays == 1)
        lblDueDate.text = @"1 day left";
    else
        lblDueDate.text = [NSString stringWithFormat:@"%d days left",remainingDays];
    
    int timesDoneIt = [self.task.timesDoneIt[self.task.currentRepetition - 1] intValue];
    int timesMissedIt = [self.task.timesMissedIt[self.task.currentRepetition - 1] intValue];
    
    lblStats.text = [NSString stringWithFormat:@"Points: %ld Done: %d\nMissed: %d Hit: %.2f", (long)self.task.taskPoints, timesDoneIt, timesMissedIt, self.task.hitRate];
    
    lblDescription.text = self.task.detailsText;
    lblDescriptionHeightConstrait.constant = [lblDescription getPreferredHeight];
    lblDescription.delegate = self;
    
    [contentView layoutIfNeeded];
    
    CGFloat heightDifference = scrollViewHeightConstrait.constant - contentView.frame.size.height;
    
    if (heightDifference < 0)
        heightDifference = 0;
    
    scrollViewBottomSpaceConstrait.constant = scrollViewBottomSpaceConstantOriginalValue = heightDifference;
}


- (IBAction) ratingButtonPressed:(UIButton*) sender {
    [self setRating:(int)sender.tag];
}

- (void) setRating:(int)rating {
    int x = 0;
    for (; x < rating; x++) {
        [[ratingButtons objectAtIndex:x] setSelected:YES];
    }
    
    for (; x < ratingButtons.count; x++) {
        [[ratingButtons objectAtIndex:x] setSelected:NO];
    }
    
    ratingTemp = rating;
}

- (IBAction) skipTask {
    [[TaskListModel sharedInstance] missTask:self.task];
}

- (IBAction) completeTask {
    self.task.rating = ratingTemp;
    self.task.notes = txtNotes.text;
    [[TaskListModel sharedInstance] completeTask:self.task];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) shareOnFacebook {
    [MediaModel postMessageToFacebook:[NSString stringWithFormat:@"I Just completed %@",self.task.title]];
}

- (IBAction) shareOnTwitter {
    [MediaModel postMessageToTwitter:[NSString stringWithFormat:@"I Just completed %@",self.task.title]];
}

#pragma mark - UITextField Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return newText.length <= TASK_NOTE_MAX_CHARACTERS;
}


- (IBAction) textDidStartEditing {
    if (!textIsUp) {
        textIsUp = YES;
        scrollViewHeightConstrait.constant = scrollViewHeightConstrait.constant - KEYBOARD_SIZE;
        
        
        CGFloat heightDifference = scrollViewHeightConstrait.constant - contentView.frame.size.height;
        if (heightDifference < 0)
            heightDifference = 0;
        
        scrollViewBottomSpaceConstrait.constant = heightDifference;
    }
}



- (IBAction) textDidEndEditing {
    if (textIsUp) {
        textIsUp = NO;
        scrollViewBottomSpaceConstrait.constant = scrollViewBottomSpaceConstantOriginalValue;
        scrollViewHeightConstrait.constant = scrollViewHeightConstrait.constant + KEYBOARD_SIZE;
    }
}

#pragma mark - DAAttributedLabelDelegate Methods
- (void) label:(DAAttributedLabel *)label didSelectLink:(NSInteger)linkNum
{
    NSString* url = self.task.detailsLinksArray[linkNum];
    
    NSRange prefixRange = [url rangeOfString:@"http"
                                     options:(NSAnchoredSearch | NSCaseInsensitiveSearch)];
    
    if (prefixRange.location == NSNotFound) {
        url = [@"http://" stringByAppendingString:url];
    }
    
	SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:url];
    [self.navigationController pushViewController:webViewController animated:YES];
}


@end
