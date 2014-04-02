//
//  DoneItTasksListViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 2/25/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "DoneItTasksListViewController.h"
#import "TaskListModel.h"
#import "SWTableViewCell.h"
#import "TasksViewCell.h"

@interface DoneItTasksListViewController ()

@end

@implementation DoneItTasksListViewController
@synthesize navController;

- (void) reloadContentData {
    contentDataArray = [[TaskListModel sharedInstance] getDoneTasks];
}

- (void) setCellViewForCell:(SWTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TaskDTO* task = contentDataArray[indexPath.row];
    
    TasksViewCell* cellView = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"DoneItTasksViewCell"];
    
//    CGRect frame = cellView.view.frame;
//    frame.size = CGSizeMake(table.frame.size.width, table.rowHeight);
//    frame.origin = CGPointZero;
//    cellView.view.frame = frame;
    
    [cell setContentView:cellView.view];
    
    cellView.doneButton.tag = indexPath.row;
    
    if (task.repeatTimes != 1) {
        cellView.lblRepeatTimes.text = [NSString stringWithFormat:@"%d of %d", (int)task.currentRepetition, (int)task.repeatTimes];
    }
    
    cellView.lblTitle.text = task.title;
    
    int timeSinceCompletition = ceil([[NSDate date] timeIntervalSinceDate:task.completitionDate] /60.0);
    
    NSString* timeSinceText = (task.status == TaskStatusComplete)?@"Done":@"Missed";
    
    if (timeSinceCompletition < 2)
        timeSinceText = [timeSinceText stringByAppendingString:@" a few moments ago."];
    
    else if (timeSinceCompletition < 60)
        timeSinceText = [timeSinceText stringByAppendingString:[NSString stringWithFormat:@" %d mins ago.", timeSinceCompletition]];
    
    else {
        timeSinceCompletition = ceil(timeSinceCompletition / 60.0);
        
        if (timeSinceCompletition == 1)
            timeSinceText = [timeSinceText stringByAppendingString:@" an hour ago."];
        
        else if (timeSinceCompletition < 24)
            timeSinceText = [timeSinceText stringByAppendingString:[NSString stringWithFormat:@" %d hours ago.",timeSinceCompletition]];
        
        else {
            timeSinceCompletition = ceil(timeSinceCompletition / 24.0);
            
            if (timeSinceCompletition == 1)
                timeSinceText = [timeSinceText stringByAppendingString:@" yesterday."];
            
            else
                timeSinceText = [timeSinceText stringByAppendingString:[NSString stringWithFormat:@" %d days ago.",timeSinceCompletition]];
        }
        
    }
    
    cellView.lblDueDate.text = timeSinceText;
    cellView.lblNote.text = task.notes;
    
    int x = 0;
    
    for (; x < task.rating; x ++) {
        ((UIButton*)cellView.stars[x]).selected = YES;
    }
    
    for (; x < cellView.stars.count; x++) {
        ((UIButton*)cellView.stars[x]).selected = NO;
    }
        
}

@end
