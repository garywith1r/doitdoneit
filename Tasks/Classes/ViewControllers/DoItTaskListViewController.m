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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < contentDataArray.count) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else { //add new task cell
        return  [tableView dequeueReusableCellWithIdentifier:@"AddNewTaskCell"];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < contentDataArray.count) {
        [super tableView:table didSelectRowAtIndexPath:indexPath];
    } else {
        [self performSegueWithIdentifier:@"NewTaskSegue" sender:nil];
    }
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
//    cellView.lblDescriptionHeightConstrait.constant = [cellView.lblDescription getPreferredHeight];
    cellView.lblDescription.delegate = self;
    
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
    NSLog(@"%f",table.frame.size.height);
    
    return 305;
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
