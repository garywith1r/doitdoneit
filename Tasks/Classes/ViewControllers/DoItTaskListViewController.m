//
//  DoItTaskListViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 2/25/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "DoItTaskListViewController.h"
#import "TaskListModel.h"
#import "TasksViewCell.h"
#import "SWTableViewCell.h"
#import "DeviceDetector.h"
#import "Constants.h"
#import "SVWebViewController.h"
#import "CompleteTaskViewController.h"
#import "UsersModel.h"
#import "QuickAddTaskCell.h"
#import "SelectRepeatTimesViewController.h"

#import "MOOPullGestureRecognizer.h"
#import "MOOCreateView.h"



@interface DoItTaskListViewController () <PopUpDelegate, SelectRepeatTimesDelegate, UITextFieldDelegate> {
    BOOL showingQuickAddCell;
    int completedTaskIndex;
    
    
    UITextField* quickAddTitle;
    UILabel* quickAddRepeatTimes;
    TaskDTO* quickAddDto;
    MOOCreateView *createView;
}

@end

@implementation DoItTaskListViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    MOOPullGestureRecognizer *recognizer = [[MOOPullGestureRecognizer alloc] initWithTarget:self action:@selector(quickAddGesture:)];
    // Create quickAdd view
    
    UITableViewCell* cell = [table dequeueReusableCellWithIdentifier:@"QuickAddTaskCell"];
    
    createView = [[MOOCreateView alloc] initWithCell:cell];
    createView.hidden = YES;
    createView.configurationBlock = ^(MOOCreateView *view, UITableViewCell *cell, MOOPullState state){
        if (![cell isKindOfClass:[UITableViewCell class]])
            return;
        
        switch (state)
        {
            case MOOPullActive:
                break;
            case MOOPullTriggered:
                break;
            case MOOPullIdle:
                break;
        }
    };
    recognizer.triggerView = createView;
    [table addGestureRecognizer:recognizer];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    showingQuickAddCell = NO;
    quickAddDto = nil;
    [createView hideCreateView:![[UsersModel sharedInstance] currentUserCanCreateTasks]];
    [table reloadData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:COMPLETE_TASK_SEGUE]) {
        CompleteTaskViewController* vc = segue.destinationViewController;
        vc.task = contentDataArray[selectedRow];
    }
}

- (void) reloadContentData {
    contentDataArray = [[TaskListModel sharedInstance] getToDoTasks];
}

- (void) deleteTaskOnMarkedPosition {
    [super deleteTaskOnMarkedPosition];
}

- (void)markTaskAsDone:(UIButton*)sender {
    [self performSegueWithIdentifier:COMPLETE_TASK_SEGUE sender: self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contentDataArray count] + [[UsersModel sharedInstance] currentUserCanCreateTasks] + showingQuickAddCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    if (showingQuickAddCell) {
        if (row == 0) {
            QuickAddTaskCell* cell = (QuickAddTaskCell*)[table dequeueReusableCellWithIdentifier:@"QuickAddTaskCell"];
            quickAddRepeatTimes = cell.lblRepeatTiems;
            quickAddTitle = cell.txtTitle;
            [quickAddTitle performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.001];
            quickAddTitle.delegate = self;
            return cell;
        } else {
            row--;
        }
    }
    
    if (row < contentDataArray.count) {
        return [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    } else { //add new task cell
        return  [tableView dequeueReusableCellWithIdentifier:@"AddNewTaskCell"];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= (contentDataArray.count + showingQuickAddCell)) {
        [self presentEditTaskControllerForTask:nil beingNewTask:YES];
    }
}


- (void) setCellViewForCell:(SWTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TaskDTO* task = contentDataArray[indexPath.row];
    
    TasksViewCell* cellView = [self.storyboard instantiateViewControllerWithIdentifier:@"DoItTasksViewCell"];
    
    
    [cell setContentView:cellView.view];
    
    if (task.repeatTimes != 1) {
        cellView.lblRepeatTimes.text = [NSString stringWithFormat:@"%d of %d:", (int)task.currentRepetition, (int)task.repeatTimes];
    } else {
        cellView.lblRepeatTimes.text = @"";
    }
    
    cellView.lblTitle.text = task.title;
    
    cellView.thumbImageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (task.thumbImagePath && ![@"" isEqualToString: task.thumbImagePath])
        [cellView.thumbImageButton setImage:task.thumbImage forState:UIControlStateNormal];
    else
        [cellView.thumbImageButton setImage:DEFAULT_TASK_IMAGE forState:UIControlStateNormal];
    cellView.thumbImageButton.layer.borderColor = YELLOW_COLOR.CGColor;
    cellView.thumbImageButton.layer.borderWidth = 2.0;
    cellView.thumbImageButton.layer.cornerRadius = 4;
    cellView.thumbImageButton.layer.masksToBounds = YES;
    
    
    int remainingDays = ceil([task.dueDate timeIntervalSinceDate:[NSDate date]] /60.0 /60.0 /24.0);
    
    if (remainingDays == 1)
        cellView.lblDueDate.text = @"1 day left";
    else
        cellView.lblDueDate.text = [NSString stringWithFormat:@"%d days left",remainingDays];
    
    int timesDoneIt = [task.timesDoneIt[task.currentRepetition - 1] intValue];
    int timesMissedIt = [task.timesMissedIt[task.currentRepetition - 1] intValue];
    
    cellView.lblStats.text = [NSString stringWithFormat:@"Points:%ld done:%dx\nmissed:%dx Hit: %.1f%%", (long)task.taskPoints, timesDoneIt, timesMissedIt, task.hitRate];
    
    cellView.lblDescription.dataDetectorTypes = UIDataDetectorTypeAll;
    cellView.lblDescription.numberOfLines = 0;
    cellView.lblDescription.highlightedTextColor = YELLOW_COLOR;
    cellView.lblDescription.text = task.detailsText;
    cellView.lblDescriptionHeightConstrait.constant = [cellView.lblDescription getPreferredHeight];
    [cellView.lblDescription layoutIfNeeded];
    cellView.descriptionScrollView.contentSize = cellView.lblDescription.frame.size;
    
    cellView.statsImage.image = [task getHitRateImage];
    
    
    cellView.lblDescription.delegate = self;
    
    
    cellView.lblDescriptionScrollViewHeightConstrait.constant = table.frame.size.height - CELL_ITEMS_HEIGHT;
    
    cellView.doneButton.tag = indexPath.row;
    [cellView.doneButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cellView.doneButton addTarget:self action:@selector(markTaskAsDone:) forControlEvents:UIControlEventTouchUpInside];
    
    cellView.thumbImageButton.tag = indexPath.row;
    [cellView.thumbImageButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cellView.thumbImageButton addTarget:self action:@selector(thumbnailTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    cellView.expandCollapseButton.tag = indexPath.row;
    [cellView.expandCollapseButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cellView.expandCollapseButton addTarget:self action:@selector(expandOrContractCell:) forControlEvents:UIControlEventTouchUpInside];
}

- (CGFloat) getExpandedCellHeightForTask:(TaskDTO*)task {
    return table.frame.size.height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.row == 0) && showingQuickAddCell)
        return 110;
    else
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void) showTaskAtRow:(NSInteger)row {
    [super showTaskAtRow:row];
    if (row != -1) {
        [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        table.scrollEnabled = NO;
    }
}

- (void) hideTaskAtRow:(NSInteger)row {
    [super hideTaskAtRow:row];
    table.scrollEnabled = YES;
}

#pragma mark - CompleteTaskDelegate Methods



- (void) scrollTableViewToCompleteViewCell {
    [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:completedTaskIndex+1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void) restoreTable {
    table.userInteractionEnabled = YES;
}

#pragma mark - Gesture Methods

- (void) quickAddGesture:(MOOPullGestureRecognizer*)gesture {
    if (!showingQuickAddCell && [[UsersModel sharedInstance] currentUserCanCreateTasks] && (gesture.pullState == MOOPullTriggered)) {
        showingQuickAddCell = YES;
        quickAddDto = [[TaskDTO alloc] init];
        quickAddTitle.text = quickAddDto.title;
        quickAddRepeatTimes.text = [quickAddDto repeatTimesDisplayText];
//        [quickAddTitle becomeFirstResponder];
        [table reloadData];
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if (!showingQuickAddCell && [[UsersModel sharedInstance] currentUserCanCreateTasks] && scrollView.pullGestureRecognizer)
        [scrollView.pullGestureRecognizer scrollViewDidScroll:scrollView];
    
    if (scrollView.contentOffset.y >= 3.0f && showingQuickAddCell) {
        [self hideQuickAddCell];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    if (!showingQuickAddCell && scrollView.pullGestureRecognizer)
        [scrollView.pullGestureRecognizer resetPullState];
}

#pragma mark - UITextField Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == quickAddTitle) {
        if ( newText.length <= TASK_TITLE_MAX_CHARACTERS) {
            quickAddDto.title = [textField.text stringByReplacingCharactersInRange:range withString:string];
            return YES;
        } else {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - QuickAdd Methods

- (void) hideQuickAddCell {
    showingQuickAddCell = NO;
    [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    quickAddDto = nil;
    [quickAddTitle resignFirstResponder];
    [table becomeFirstResponder];
    quickAddTitle = nil;
}

- (IBAction) quickAddButtonPressed {
    if (!quickAddDto.title || [quickAddDto.title isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Plese enter a title for the task." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    [[TaskListModel sharedInstance] addTask:quickAddDto];
    [self hideQuickAddCell];
    [self reloadContentData];
    [table reloadData];
    quickAddDto = nil;
    [quickAddTitle resignFirstResponder];
}

- (IBAction) fullAddButtonPressed {
    [self presentEditTaskControllerForTask:quickAddDto beingNewTask:YES];
}

- (IBAction) repeatTimesButtonPressed {
    SelectRepeatTimesViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectRepeatTimesViewController"];
    [vc setInitialTimes:quickAddDto.repeatTimes andInitialTimeInterval:quickAddDto.repeatPeriod];
    vc.delegate = self;
    
    UINavigationController* mainVC = (UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [vc presentOnViewController:mainVC];
    [quickAddTitle resignFirstResponder];
}


- (IBAction) textFieldDidFinish:(UITextField*) sender {}

#pragma mark - SelectRepeatTimesDelegate methods
- (void) selectedRepeatTimes:(NSInteger)repeatTimes perTimeInterval:(NSInteger)timeInterval {
    quickAddDto.repeatTimes = repeatTimes;
    quickAddDto.repeatPeriod = (int)timeInterval;
    
    quickAddRepeatTimes.text = [quickAddDto repeatTimesDisplayText];
}

@end
