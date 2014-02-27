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

- (void) reloadContentData {
    contentDataArray = [[TaskListModel sharedInstance] getDoneTasks];
}

- (void) setCellViewForCell:(SWTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TaskDTO* task = contentDataArray[indexPath.row];
    
    TasksViewCell* cellView = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"DoneItTasksViewCell"];
    
    CGRect frame = cellView.view.frame;
    frame.size = CGSizeMake(table.frame.size.width, table.rowHeight);
    frame.origin = CGPointZero;
    cellView.view.frame = frame;
    
    [cell setContentView:cellView.view];
    
    cellView.doneButton.tag = indexPath.row;
    
    NSString* titleBoldPart = @"";
    
    if (task.repeatTimes != 1) {
        titleBoldPart = [NSString stringWithFormat:@"%d of %d:", (int)task.currentRepetition, (int)task.repeatTimes];
    }
    
    cellView.lblTitle.attributedText = [self stringWithBoldPart:titleBoldPart andNormalPart:task.title];
    
    int timeSinceCompletition = ceil([[NSDate date] timeIntervalSinceDate:task.completitionDate] /60.0);
    
    NSString* completedText;
    
    if (timeSinceCompletition < 2)
        completedText = @"Done a few moments ago.";
    
    else if (timeSinceCompletition < 60)
        completedText = [NSString stringWithFormat:@"Done %d mins ago.", timeSinceCompletition];
    
    else {
        timeSinceCompletition = ceil(timeSinceCompletition / 60.0);
        
        if (timeSinceCompletition == 1)
            completedText = @"Done an hour ago.";
        
        else if (timeSinceCompletition < 24)
            completedText = [NSString stringWithFormat:@"Done %d hours ago.",timeSinceCompletition];
        
        else {
            timeSinceCompletition = ceil(timeSinceCompletition / 24.0);
            
            if (timeSinceCompletition == 1)
                completedText = @"Done yesterday.";
            
            else
                completedText = [NSString stringWithFormat:@"Done %d days ago.",timeSinceCompletition];
        }
        
    }
    
    cellView.dueDate.text = [NSString stringWithFormat:@"%@ Total %dx Hit %.1f%%",completedText, [task.timesDoneIt[task.currentRepetition - 1] intValue], [task hitRate]];
    
    
    [cellView.doneButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    cellView.doneButton.selected = NO;
}

@end
