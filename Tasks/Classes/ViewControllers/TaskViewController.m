//
//  TaskViewController.m
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "TaskViewController.h"
#import "SelectDateViewController.h"
#import "TaskListModel.h"
#import "DeviceDetector.h"
#import "Constants.h"

#define SELECT_DATE_SEGUE @"SelectDatesSegue"


@interface TaskViewController () <SelectDateDelegate, UITextFieldDelegate> {
    IBOutlet UITextField* txtTitle;
    IBOutlet UITextField* txtRepeatTimes;
    IBOutlet UISegmentedControl* sgmRepeatInterval;
    IBOutlet UISlider* sldTaskPoints;
    IBOutlet UILabel* dueDate;
    
    IBOutlet UIView* completeTaskDetailsView;
    IBOutletCollection(UIButton) NSArray* ratingButtons;
    IBOutlet UITextField* txtNotes;
    IBOutlet UILabel* doneDate;
    IBOutlet UILabel* lblInfo;
    
    IBOutlet NSLayoutConstraint* scrollViewHeightConstrait;
    IBOutlet NSLayoutConstraint* contentViewHeightConstrait;
    
    BOOL selectingDueDate;
    BOOL keyboardIsUp;
    
    NSDate* dueDateTemp;
    NSDate* completitionDateTemp;
    NSInteger ratingTemp;
}
@end

@implementation TaskViewController
@synthesize task;

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SELECT_DATE_SEGUE]) {
        SelectDateViewController* editController = (SelectDateViewController*) [segue destinationViewController];
        editController.delegate = self;
        if (selectingDueDate)
            editController.startDate = dueDateTemp;
        else
            editController.startDate = completitionDateTemp;
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
    txtTitle.text = self.task.title;
    txtRepeatTimes.text = [NSString stringWithFormat:@"%d",self.task.repeatTimes];
    sgmRepeatInterval.selectedSegmentIndex = self.task.repeatPeriod;
    sldTaskPoints.value = self.task.priorityPoints;
    
    
    
    if (self.task.status != TaskStatusComplete) {
        completeTaskDetailsView.hidden = YES;
        contentViewHeightConstrait.constant = contentViewHeightConstrait.constant - completeTaskDetailsView.frame.size.height;
    } else {
        [self setRating:self.task.rating];
        txtNotes.text = self.task.notes;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yy"];
        
        int timesDoneIt = [task.timesDoneIt[task.currentRepetition - 1] intValue];
        int timesMissedIt = [task.timesMissedIt[task.currentRepetition - 1] intValue];
        
        lblInfo.text = [NSString stringWithFormat:@"Created: %@ Done: %dx\nMissed: %dx Hit: %.1f%%",[formatter stringFromDate:task.creationDate], timesDoneIt, timesMissedIt, [task hitRate]];
    }
    
    dueDateTemp = self.task.dueDate;
    completitionDateTemp = self.task.completitionDate;
    
    scrollViewHeightConstrait.constant = self.view.frame.size.height;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        scrollViewHeightConstrait.constant -= (self.tabBarController.tabBar.frame.size.height + self.navigationController.navigationBar.frame.size.height);
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	// Do any additional setup after loading the view.
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_FORMAT];
    
    if (self.task.dueDate) {
        dueDate.text = [formatter stringFromDate:dueDateTemp];
    }
    
    if (self.task.completitionDate) {
        doneDate.text = [formatter stringFromDate:completitionDateTemp];
    }
    
}

- (IBAction) saveButtonPressed {
    
    if ([txtTitle.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Plese enter a title for the task." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    if ([txtRepeatTimes.text intValue] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Plese provide a valid amount of repetitions" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    self.task.title = txtTitle.text;
    self.task.repeatTimes = [txtRepeatTimes.text intValue];
    
    self.task.repeatPeriod = sgmRepeatInterval.selectedSegmentIndex;
    self.task.priorityPoints = sldTaskPoints.value;
    
    self.task.notes = txtNotes.text;
    
    self.task.dueDate = dueDateTemp;
    self.task.completitionDate = completitionDateTemp;
    self.task.rating = ratingTemp;
    
    if (self.isNewTask)
        [[TaskListModel sharedInstance] addTask:self.task];
    else
        [[TaskListModel sharedInstance] forceRecalculateTasks];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction) changeDueDate {
    selectingDueDate = YES;
    [self performSegueWithIdentifier:SELECT_DATE_SEGUE sender: self];
}

- (IBAction) changeCompletitionDate {
    selectingDueDate = NO;
    [self performSegueWithIdentifier:SELECT_DATE_SEGUE sender: self];
}

- (IBAction) ratingButtonPressed:(UIButton*) sender {
    [self setRating:sender.tag];
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


#pragma mark - SelectDateDelegate Methods
- (void) didSelectDate:(NSDate *)date {
    if (selectingDueDate)
        dueDateTemp = date;
    else
        completitionDateTemp = date;
}

#pragma mark - UITextField Methods 

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == txtTitle) {
        return newText.length <= TASK_TITLE_MAX_CHARACTERS;
    } else if (textField == txtNotes) {
        return newText.length <= TASK_NOTE_MAX_CHARACTERS;
    }
    
    return YES;
}

- (IBAction) textEditingBegun {
    if (!keyboardIsUp) {
        [UIView beginAnimations:Nil context:nil];
        [UIView setAnimationDuration:0.3];
        scrollViewHeightConstrait.constant = scrollViewHeightConstrait.constant - KEYBOARD_SIZE;
        [UIView commitAnimations];
        keyboardIsUp = YES;
    }
}


- (IBAction) textEditingEnd {
    if (keyboardIsUp) {
        [UIView beginAnimations:Nil context:nil];
        [UIView setAnimationDuration:0.3];
        scrollViewHeightConstrait.constant = scrollViewHeightConstrait.constant + KEYBOARD_SIZE;
        [UIView commitAnimations];
        keyboardIsUp = NO;
    }
}



@end
