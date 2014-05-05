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
#import "Constants.h"
#import "NSDate+Reporting.h"

@interface DoneItTasksListViewController () {
}

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
    
    cellView.thumbImageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (task.thumbImagePath && ![@"" isEqualToString: task.thumbImagePath])
        [cellView.thumbImageButton setImage:task.thumbImage forState:UIControlStateNormal];
    else
        [cellView.thumbImageButton setImage:DEFAULT_TASK_IMAGE forState:UIControlStateNormal];
    cellView.thumbImageButton.tag = indexPath.row;
    [cellView.thumbImageButton addTarget:self action:@selector(thumbnailTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    cellView.thumbImageButton.layer.borderColor = YELLOW_COLOR.CGColor;
    cellView.thumbImageButton.layer.borderWidth = 2.0;
    cellView.thumbImageButton.layer.cornerRadius = 4;
    cellView.thumbImageButton.layer.masksToBounds = YES;
    
    cellView.doneButton.tag = indexPath.row;
    
    if (task.repeatTimes != 1) {
        cellView.lblRepeatTimes.text = [NSString stringWithFormat:@"%d of %d", (int)task.currentRepetition, (int)task.repeatTimes];
    } else {
        cellView.lblRepeatTimes.text = @"";
    }
    
    cellView.lblTitle.text = task.title;
    
    
    NSString* timeSinceText = (task.status == TaskStatusComplete)?@"Done ":@"Missed ";
    
    timeSinceText = [timeSinceText stringByAppendingString:[NSDate timePassedSince:task.completitionDate]];
    
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
