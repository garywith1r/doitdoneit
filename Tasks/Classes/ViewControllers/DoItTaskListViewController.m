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
#import "CompleteTaskViewCell.h"
#import "DeviceDetector.h"
#import "Constants.h"
#import "DAAttributedLabel.h"
#import "SVWebViewController.h"
#import "CompleteTaskViewController.h"


#define COMPLETE_TASK_SEGUE @"CompleteTaskSegue"

@interface DoItTaskListViewController () <CompleteTaskDelegate> {
    BOOL keyboardIsUp;
    BOOL showingCompleteTaskCell;
    int completedTaskIndex;
    
    CompleteTaskViewCell* completeTaskCell;
    
    
}

@end

@implementation DoItTaskListViewController

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
    if (showingCompleteTaskCell && (tagToDeleteIndex == completedTaskIndex)) {
        showingCompleteTaskCell = NO;
        [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:completedTaskIndex + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        completedTaskIndex = -1;
    }
    [super deleteTaskOnMarkedPosition];
}

- (void)markTaskAsDone:(UIButton*)sender {
    [self performSegueWithIdentifier:COMPLETE_TASK_SEGUE sender: self];
}

- (void) setCellViewForCell:(SWTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TaskDTO* task = contentDataArray[indexPath.row];
    
    TasksViewCell* cellView = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"DoItTasksViewCell"];
    
    [cell setContentView:cellView.view];
    
    if (task.repeatTimes != 1) {
        cellView.lblRepeatTimes.text = [NSString stringWithFormat:@"%d of %d:", (int)task.currentRepetition, (int)task.repeatTimes];
    } else {
        cellView.lblRepeatTimes.text = @"";
    }
    
    cellView.lblTitle.text = task.title;
    
    cellView.thumbImageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cellView.thumbImageButton setImage:task.thumbImage forState:UIControlStateNormal];
    
    
    int remainingDays = ceil([task.dueDate timeIntervalSinceDate:[NSDate date]] /60.0 /60.0 /24.0);
    
    if (remainingDays == 1)
        cellView.lblDueDate.text = @"1 day left";
    else
        cellView.lblDueDate.text = [NSString stringWithFormat:@"%d days left",remainingDays];
    
    int timesDoneIt = [task.timesDoneIt[task.currentRepetition - 1] intValue];
    int timesMissedIt = [task.timesMissedIt[task.currentRepetition - 1] intValue];
    
    cellView.lblStats.text = [NSString stringWithFormat:@"Points: %ld Done: %d\nMissed: %d Hit: %.2f", (long)task.taskPoints, timesDoneIt, timesMissedIt, task.hitRate];
    
    cellView.lblDescription.text = task.detailsText;
    cellView.lblDescriptionHeightConstrait.constant = [cellView.lblDescription getPreferredHeight];
    cellView.lblDescription.delegate = self;
    
    cellView.doneButton.tag = indexPath.row;
    [cellView.doneButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cellView.doneButton addTarget:self action:@selector(markTaskAsDone:) forControlEvents:UIControlEventTouchUpInside];
    
    cellView.thumbImageButton.tag = indexPath.row;
    [cellView.thumbImageButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cellView.thumbImageButton addTarget:self action:@selector(thumbnailTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    cellView.hideCellButton.tag = indexPath.row;
    [cellView.hideCellButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cellView.hideCellButton addTarget:self action:@selector(hideSelectedRow:) forControlEvents:UIControlEventTouchUpInside];
    cellView.hideCellButton.enabled = NO;
}

- (CGFloat) getExpandedCellHeightForTask:(TaskDTO*)task {
    CGFloat labelsHeight = 0;
    
    if (task.detailsText && ![@"" isEqualToString:task.detailsText.string]) {
        DAAttributedLabel* attributedLabel = [[DAAttributedLabel alloc] initWithFrame:self.view.frame];
        attributedLabel.text = task.detailsText;
        labelsHeight = [attributedLabel getPreferredHeight];
    }
    
    return EXPANDED_ROW_HEIGHT + labelsHeight;
}

#pragma mark - CompleteTaskDelegate Methods

- (void) noteTextDidStartEditing {
    if (!keyboardIsUp) {
        [UIView beginAnimations:Nil context:nil];
        [UIView setAnimationDuration:0.3];
//        tableViewHeightConstrait.constant = tableViewHeightConstrait.constant - KEYBOARD_SIZE;
        [UIView commitAnimations];
        [self performSelector:@selector(scrollTableViewToCompleteViewCell) withObject:nil afterDelay:0.1];
        keyboardIsUp = YES;
    }
}

- (void) scrollTableViewToCompleteViewCell {
    [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:completedTaskIndex+1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void) noteTextDidEndEditing {
    if (keyboardIsUp) {
        [UIView beginAnimations:Nil context:nil];
        [UIView setAnimationDuration:0.3];
//        tableViewHeightConstrait.constant = tableViewHeightConstrait.constant + KEYBOARD_SIZE;
        [UIView commitAnimations];
        keyboardIsUp = NO;
    }
}

- (void) shouldDisposeTheCellForTask:(TaskDTO*)task {
    [self reloadContentData];
    if (task.currentRepetition == task.repeatTimes) {
        showingCompleteTaskCell = NO;
        [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:completedTaskIndex inSection:0], [NSIndexPath indexPathForRow:completedTaskIndex + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        
    } else {
        [table reloadData];
        showingCompleteTaskCell = NO;
        [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:completedTaskIndex + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    completedTaskIndex = -1;
    table.userInteractionEnabled = NO;
    [table performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    [self performSelector:@selector(restoreTable) withObject:[NSNumber numberWithBool:YES] afterDelay:0.35];
}

- (void) restoreTable {
    table.userInteractionEnabled = YES;
}

@end
