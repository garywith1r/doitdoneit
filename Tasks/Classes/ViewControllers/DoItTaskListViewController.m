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
#import "UsersModel.h"
#import "QuickAddTaskCell.h"
#import "SelectRepeatTimesViewController.h"

#import "MOOPullGestureRecognizer.h"
#import "MOOCreateView.h"



@interface DoItTaskListViewController () <CompleteTaskDelegate, PopUpDelegate, SelectRepeatTimesDelegate> {
    BOOL showingQuickAddCell;
    int completedTaskIndex;
    
    CompleteTaskViewCell* completeTaskCell;
    
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
        [self performSegueWithIdentifier:NEW_TASK_SEGUE sender:nil];
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
    cellView.lblDescription.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi tortor nulla, auctor non purus ut, pellentesque suscipit nunc. Pellentesque eget metus quis erat viverra ullamcorper. Proin vel varius orci, sit amet luctus erat. Sed dapibus in erat id tincidunt. Maecenas et est volutpat, varius eros eu, hendrerit ante. Ut luctus tortor a convallis rutrum. Duis et urna nunc. In aliquet a nunc at pharetra. Pellentesque porttitor vel odio ut mollis. Pellentesque ultrices dictum nunc vel dapibus. Nulla et dui et elit sodales scelerisque sed ut metus. Curabitur id orci sagittis, laoreet neque ac, auctor nunc. Etiam iaculis at urna a mattis. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam egestas, augue et egestas vulputate, metus metus mattis eros, sed sollicitudin est justo nec urna.\n\nSuspendisse blandit, lacus vitae iaculis laoreet, turpis turpis adipiscing tellus, at posuere mi urna et ligula. Phasellus ultricies at dolor quis ornare. Praesent rhoncus elit arcu, eu ultrices nulla tincidunt a. Praesent vitae felis eget tellus lacinia egestas sed eu augue. Nam eu tincidunt odio, ut mollis velit. Phasellus est arcu, hendrerit eu mi quis, pharetra blandit libero. In mattis pretium augue, id luctus eros lacinia fermentum. Nulla a molestie mi. Donec congue pretium leo, eu aliquam felis porta ac. Nullam condimentum est felis, a posuere sem laoreet non. Morbi at convallis risus, mollis malesuada eros.\n\nNam eget venenatis ante. Morbi porta quam ac ornare interdum. Pellentesque fringilla, dui in elementum ullamcorper, odio quam bibendum metus, ut tempus ligula tellus in neque. Sed est est, volutpat eu massa ut, tempus tincidunt mauris. Maecenas vitae ligula consequat metus interdum pharetra. Praesent suscipit rhoncus mauris quis pellentesque. Aliquam aliquam, tellus ut ornare fermentum, urna magna pulvinar odio, vitae semper ligula eros ac magna. Quisque aliquam laoreet mi sed rhoncus. Fusce a mi dui. Maecenas mauris purus, tristique sed neque quis, gravida gravida mauris. Praesent lorem eros, pretium ac luctus sit amet, tincidunt eu ante. Proin vehicula sit amet purus quis interdum. Donec non erat eleifend, posuere elit nec, ornare lectus. Donec cursus consectetur arcu. Etiam ac pulvinar risus, ac ullamcorper justo.\n\nDonec justo magna, tempus id est a, mollis elementum tortor. Proin nec sem auctor, elementum augue sit amet, ultrices eros. Fusce quis est bibendum massa cursus vestibulum nec eget leo. Aliquam vitae nisl vitae mauris aliquam commodo eget a purus. Donec pellentesque odio quis ullamcorper rutrum. Proin at leo in turpis porttitor lacinia. Nunc imperdiet orci et feugiat dapibus. Suspendisse viverra interdum ipsum eget iaculis. Nam elit lorem, consectetur et semper id, ullamcorper vitae velit.\n\nClass aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Curabitur sed fringilla turpis. Quisque ultricies dapibus velit eu eleifend. Aliquam erat volutpat. Proin in accumsan massa. Suspendisse vel elit eget elit hendrerit scelerisque. Mauris sit amet eleifend tellus.";
    cellView.lblDescriptionHeightConstrait.constant = [cellView.lblDescription getPreferredHeight];
    [cellView.lblDescription layoutIfNeeded];
    cellView.descriptionScrollView.contentSize = cellView.lblDescription.frame.size;
    
    
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

#pragma mark - QuickAdd Methods

- (void) hideQuickAddCell {
    showingQuickAddCell = NO;
    [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    quickAddDto = nil;
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
}

- (IBAction) fullAddButtonPressed {
    taskToShow = quickAddDto;
    taskToShowIsNewCopy = YES;
    [self performSegueWithIdentifier:EDIT_TASK_SEGUE sender:nil];
}

- (IBAction) repeatTimesButtonPressed {
    SelectRepeatTimesViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectRepeatTimesViewController"];
    [vc setInitialTimes:quickAddDto.repeatTimes andInitialTimeInterval:quickAddDto.repeatPeriod];
    vc.delegate = self;
    [vc presentOnViewController:self];
}

- (IBAction) textFieldDidFinish:(UITextField*) sender {
    quickAddDto.title = sender.text;
}

#pragma mark - RepeatTimesDelegate methods
- (void) selectedRepeatTimes:(NSInteger)repeatTimes perTimeInterval:(NSInteger)timeInterval {
    quickAddDto.repeatTimes = repeatTimes;
    quickAddDto.repeatPeriod = (int)timeInterval;
    
    quickAddRepeatTimes.text = [quickAddDto repeatTimesDisplayText];
}

@end
