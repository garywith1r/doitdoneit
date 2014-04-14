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
    
    [cell setContentView:cellView.view];
    
    [cellView.thumbImageButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    if (task.thumbImage) {
        cellView.thumbImageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cellView.thumbImageButton setImage:task.thumbImage forState:UIControlStateNormal];
        cellView.thumbImageButton.tag = indexPath.row;
        [cellView.thumbImageButton addTarget:self action:@selector(thumbnailTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cellView.doneButton.tag = indexPath.row;
    
    if (task.repeatTimes != 1) {
        cellView.lblRepeatTimes.text = [NSString stringWithFormat:@"%d of %d", (int)task.currentRepetition, (int)task.repeatTimes];
    } else {
        cellView.lblRepeatTimes.text = @"";
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
    
    cellView.thumbImageButton.tag = indexPath.row;
    [cellView.thumbImageButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cellView.thumbImageButton addTarget:self action:@selector(thumbnailTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    cellView.expandCollapseButton.tag = indexPath.row;
    [cellView.expandCollapseButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cellView.expandCollapseButton addTarget:self action:@selector(expandOrContractCell:) forControlEvents:UIControlEventTouchUpInside];
    
    int x = 0;
    
    for (; x < task.rating; x ++) {
        ((UIButton*)cellView.stars[x]).selected = YES;
    }
    
    for (; x < cellView.stars.count; x++) {
        ((UIButton*)cellView.stars[x]).selected = NO;
    }
        
}

@end
