//
//  ViewController.m
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "TasksListViewController.h"
#import "TasksViewCell.h"
#import "CompleteTaskViewController.h"
#import "AddEditTaskViewController.h"
#import "SWTableViewCell.h"
#import "TaskListModel.h"
#import "DeviceDetector.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ZoomImageViewController.h"
#import "SVWebViewController.h"
#import "UsersModel.h"

#define DELETE_TASK_ALERT_TAG 125

@interface TasksListViewController () <SWTableViewCellDelegate, UIAlertViewDelegate, ZoomImageDelegate> {
    NSArray* arrayToShow;
    NSString* titleToShow;
    
    
    MPMoviePlayerController* playerViewController;
    ZoomImageViewController* zoomImageController;
    
    IBOutlet UIImageView* arrowImage;
    
}

@end

@implementation TasksListViewController


- (void) viewDidLoad {
    selectedRow = -1;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillAppear:) name: UIApplicationWillEnterForegroundNotification object:nil];
    
    }

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadContentData];
    [table reloadData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EDIT_TASK_SEGUE]) {
        AddEditTaskViewController* taskController = (AddEditTaskViewController*) [segue destinationViewController];
        taskController.task = taskToShow;
        taskController.isNewTask = taskToShowIsNewCopy;
        taskToShowIsNewCopy = NO;
    }
}

- (void) reloadContentData {}

- (void) deleteTaskOnMarkedPosition {
    [[TaskListModel sharedInstance] deleteTask:contentDataArray[tagToDeleteIndex]];
    [self reloadContentData];
    [table reloadData];
    tagToDeleteIndex = -1;
}

- (void) showTaskAtRow:(NSInteger)row {
    selectedRow = row;
    
    arrowImage.image = [UIImage imageNamed:@"arrow2.png"];
    
    [table beginUpdates];
    [table endUpdates];
    [table deselectRowAtIndexPath:[NSIndexPath indexPathForItem:row inSection:0] animated:YES];
}

- (void) hideTaskAtRow:(NSInteger)row {
    if (selectedRow == row) {
        [self showTaskAtRow:-1];
        arrowImage.image = [UIImage imageNamed:@"arrow1.png"];
    }
}

#pragma mark - UITableView Methods

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == selectedRow) {
        return [self getExpandedCellHeightForTask:contentDataArray[indexPath.row]];
    } else {
        return NORMAL_ROW_HEIGHT;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contentDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        static NSString *cellIdentifier = @"Cell";
        
        
        SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            NSMutableArray *leftUtilityButtons = [NSMutableArray new];
            NSMutableArray *rightUtilityButtons = [NSMutableArray new];
            
            [rightUtilityButtons sw_addUtilityButtonWithColor:
             [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:0.0]
                                                         icon:[UIImage imageNamed:@"Copy.png"] tag:indexPath.row];
            [rightUtilityButtons sw_addUtilityButtonWithColor:
             [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:0.0]
                                                         icon:[UIImage imageNamed:@"Edit.png"] tag:indexPath.row];
            [rightUtilityButtons sw_addUtilityButtonWithColor:
             [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:0.0]
                                                         icon:[UIImage imageNamed:@"Delete.png"] tag:indexPath.row];
            
            
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier
                                      containingTableView:tableView // For row height and selection
                                       leftUtilityButtons:leftUtilityButtons
                                      rightUtilityButtons:rightUtilityButtons];
            
            cell.delegate = self;
        }
        
        cell.height = [self getExpandedCellHeightForTask:contentDataArray[indexPath.row]];
        cell.clipsToBounds = YES
        ;
        
        //we'll use the tag to identify the task by it's index.
        [self setCellViewForCell:cell atIndexPath:indexPath];
        cell.tag = indexPath.row;
        cell.cellScrollView.scrollEnabled = [[UsersModel sharedInstance] currentUserCanCreateTasks];
        
        return cell;
    
}

//- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self showTaskAtRow:indexPath.row];
//}

- (void) expandOrContractCell:(UIButton*) sender {
    if (sender.tag == selectedRow)
        [self hideTaskAtRow:sender.tag];
    else
        [self showTaskAtRow:sender.tag];
}

- (void) setCellViewForCell:(SWTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {}

- (CGFloat) getExpandedCellHeightForTask:(TaskDTO*)task { return EXPANDED_ROW_HEIGHT; }

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0: // copy
            taskToShow = [[contentDataArray objectAtIndex:cell.tag] taskWithData];
            taskToShowIsNewCopy = YES;
            [self performSegueWithIdentifier:EDIT_TASK_SEGUE sender:nil];
            break;
        case 1: // Edit
        {
            taskToShow = [contentDataArray objectAtIndex:cell.tag];
            [self performSegueWithIdentifier:EDIT_TASK_SEGUE sender:nil];
            break;
        }
        case 2: // delete
        {
            tagToDeleteIndex = (int)cell.tag;
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to completely delete this task?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            alert.tag = DELETE_TASK_ALERT_TAG;
            [alert show];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Utility Methods
- (NSAttributedString*) stringWithBoldPart:(NSString*)boldPart andNormalPart:(NSString*)normalPart {
    
    NSRange boldedRange = NSMakeRange(0, boldPart.length);
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",boldPart,normalPart]];
    
    NSRange noBoldRange = NSMakeRange(boldPart.length, attrString.length - boldPart.length);
    
    [attrString beginEditing];
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:17]
                       range:boldedRange];
    
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:15]
                       range:noBoldRange];
    
    [attrString endEditing];
    
    return attrString;
}

- (void) thumbnailTapped:(UIButton*)sender {
    TaskDTO* task = [contentDataArray objectAtIndex:sender.tag];
    if (task.videoUrl) {
        [self playVideo:task.videoUrl fromButton:sender];
    } else {
        //it's an image
        [self zoomImage:task.thumbImage fromButton:sender];
    }
}

- (void) zoomImage:(UIImage*)image fromButton:(UIButton*)sender {
    CGRect frame = [self.view convertRect:sender.frame fromView:table];
    BOOL isThereAnExpandedRow = (selectedRow < sender.tag);
    frame.origin.y = frame.origin.y + (sender.tag - isThereAnExpandedRow) * NORMAL_ROW_HEIGHT + isThereAnExpandedRow * EXPANDED_ROW_HEIGHT;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        frame.origin.y = frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    
    zoomImageController = [ZoomImageViewController expandImage:image fromFrame:frame delegate:self];
}

- (void) playVideo:(NSString*) path fromButton:(UIButton*)sender{
    if (!playerViewController)
        playerViewController = [[MPMoviePlayerController alloc] init];
    
    
    CGRect frame = sender.frame;
    frame.size = CGSizeZero;
    
    playerViewController.contentURL = [NSURL fileURLWithPath:path isDirectory:NO];
    playerViewController.view.frame = frame;
    
    [sender addSubview:playerViewController.view];
    playerViewController.fullscreen = YES;
    [playerViewController play];
}

#pragma mark - ZoomImageDelegate Methods
- (void) didExitFullScreen {
    [zoomImageController.view removeFromSuperview];
    zoomImageController = nil;
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == DELETE_TASK_ALERT_TAG) {
        if (buttonIndex == 1) {
            [self deleteTaskOnMarkedPosition];
        }
    }
}

#pragma mark - DAAttributedLabelDelegate Methods
- (void) label:(DAAttributedLabel *)label didSelectLink:(NSInteger)linkNum
{
    NSString* url = ((TaskDTO*)contentDataArray[selectedRow]).detailsLinksArray[linkNum];
    
    NSRange prefixRange = [url rangeOfString:@"http"
                options:(NSAnchoredSearch | NSCaseInsensitiveSearch)];
    
    if (prefixRange.location == NSNotFound) {
        url = [@"http://" stringByAppendingString:url];
    }
    
	SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:url];
    [self.navigationController pushViewController:webViewController animated:YES];
}

@end
