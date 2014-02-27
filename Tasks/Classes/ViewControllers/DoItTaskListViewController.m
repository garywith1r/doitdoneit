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

#define COMPLETE_TASK_CELL_IDENTIFIER @"CompleteTaskCell"

@interface DoItTaskListViewController () <CompleteTaskDelegate> {
    BOOL showingCompleteTaskCell;
    int completedTaskIndex;
    
    CompleteTaskViewCell* completeTaskCell;
}

@end

@implementation DoItTaskListViewController

- (void) viewDidLoad {
    completedTaskIndex = -1;
    [super viewDidLoad];
    [table registerNib:[UINib nibWithNibName:@"CompleteTaskViewCell" bundle:nil] forCellReuseIdentifier:COMPLETE_TASK_CELL_IDENTIFIER];
}

- (void) reloadContentData {
    contentDataArray = [[TaskListModel sharedInstance] getToDoTasks];
}

- (void)markTaskAsDone:(UIButton*)sender {
    
    if (sender.tag == completedTaskIndex) {
        //if the user taps again on the selected button, close the "completed task view"
        showingCompleteTaskCell = NO;
        [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:completedTaskIndex + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        completedTaskIndex = -1;
    } else {
    
        if (showingCompleteTaskCell) {
            showingCompleteTaskCell = NO;
            [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:completedTaskIndex + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        }
        
        
        showingCompleteTaskCell = YES;
        completedTaskIndex = sender.tag;
        
        [table insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:completedTaskIndex + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        
        [table reloadData];
        
    }
    
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
    
    cellView.doneButton.selected = indexPath.row == completedTaskIndex;
}

#pragma mark - UITableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numberOfRows = [super tableView:tableView numberOfRowsInSection:section];
    
    return numberOfRows + showingCompleteTaskCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if  (showingCompleteTaskCell && (indexPath.row == completedTaskIndex + 1))
         return COMPLETE_TASK_VIEW_CELL_HEIGHT;
    else
        return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (showingCompleteTaskCell) {

        if (indexPath.row == completedTaskIndex + 1) { //here should appear the complete task cell
            
            static NSString *CellIdentifier = COMPLETE_TASK_CELL_IDENTIFIER;
            completeTaskCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!completeTaskCell)
                completeTaskCell = [[CompleteTaskViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            [completeTaskCell resetContent];
            completeTaskCell.task = [contentDataArray objectAtIndex:indexPath.row - 1];
            completeTaskCell.delegate = self;
            
            return completeTaskCell;
            
        } else if (indexPath.row <= completedTaskIndex) {
            return [super tableView:tableView cellForRowAtIndexPath:indexPath];
            
        } else { //indexPath.row > completedTaskIndex + 1
           return [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
        }
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return nil;
}

#pragma mark - CompleteTaskDelegate Methods

- (void) noteTextDidStartEditing {

}

- (void) noteTextDidEndEditing {

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
    [table performSelector:@selector(setUserInteractionEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.35];
}

@end
