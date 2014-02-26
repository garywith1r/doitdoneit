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

@implementation DoItTaskListViewController

- (void) reloadContentData {
    contentDataArray = [[TaskListModel sharedInstance] getToDoTasks];
}

- (void)markTaskAsDone:(UIButton*)sender {
    TaskListModel* taskListModel = [TaskListModel sharedInstance];
    
    TaskDTO* task = [contentDataArray objectAtIndex:sender.tag];
    
    sender.selected = YES;
    
    //    int numberOfTasksForToday = [taskListModel getTodayTasks].count;
    [taskListModel completeTask:task];
    
    [self reloadContentData];
    
    if (task.currentRepetition == task.repeatTimes) {
        [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        table.userInteractionEnabled = NO;
        [table performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
        [table performSelector:@selector(setUserInteractionEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.35];
    } else {
        [table reloadData];
    }
    
//    [CompleteTaskViewController showInParentView:self forTask:task];
    
}

- (void) setCellViewForCell:(SWTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TaskDTO* task = contentDataArray[indexPath.row];
    
    TasksViewCell* cellView = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"DoItTasksViewCell"];
    
    CGRect frame = cellView.view.frame;
    frame.size = CGSizeMake(table.frame.size.width, table.rowHeight);
    frame.origin = CGPointZero;
    cellView.view.frame = frame;
    
    [cell setContentView:cellView.view];
    
    cellView.doneButton.tag = indexPath.row;
    
    NSString* titleBoldPart = @"";
    
    if (task.repeatTimes != 1) {
        titleBoldPart = [NSString stringWithFormat:@"%d of %d:", task.currentRepetition, task.repeatTimes];
    }
    
    cellView.lblTitle.attributedText = [self stringWithBoldPart:titleBoldPart andNormalPart:task.title];
    
    int remainingDays = ceil([task.dueDate timeIntervalSinceDate:[NSDate date]] /60.0 /60.0 /24.0);
    
    if (remainingDays == 1)
        cellView.dueDate.text = @"1 day left";
    else
        cellView.dueDate.text = [NSString stringWithFormat:@"%d days left",remainingDays];
    
    
    [cellView.doneButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cellView.doneButton addTarget:self action:@selector(markTaskAsDone:) forControlEvents:UIControlEventTouchUpInside];
    
    cellView.doneButton.selected = NO;
}

@end
