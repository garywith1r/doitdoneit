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
#import "TaskViewController.h"
#import "SWTableViewCell.h"
#import "TaskListModel.h"
#import "DeviceDetector.h"


#define CANT_UPCOMING_TASKS_TO_SHOW 4

@interface TasksListViewController () <SWTableViewCellDelegate> {
    NSArray* arrayToShow;
    NSString* titleToShow;
    
    
    TaskDTO* taskToShow;
    BOOL taskToShowIsNewCopy;
}

@end

@implementation TasksListViewController

- (void) viewDidLoad {
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
    if ([segue.identifier isEqualToString:@"ViewTaskSegue"]) {
        TaskViewController* taskController = (TaskViewController*) [segue destinationViewController];
        taskController.task = taskToShow;
        taskController.isNewTask = taskToShowIsNewCopy;
        taskToShowIsNewCopy = NO;
    } else if ([segue.identifier isEqualToString:@"NewTaskSegue"]) {
        TaskViewController* taskController = (TaskViewController*) [segue destinationViewController];
        taskController.task = [[TaskDTO alloc] init];
        taskController.isNewTask = YES;
    }
}

- (void) reloadContentData {}


#pragma mark - UITableView Methods

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

    //we'll use the tag to identify the task by it's index.
    
    [self setCellViewForCell:cell atIndexPath:indexPath];
    cell.tag = indexPath.row;
    
    
    return cell;
    
}

- (void) setCellViewForCell:(SWTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0: // copy
            taskToShow = [[contentDataArray objectAtIndex:cell.tag] taskWithData];
            taskToShowIsNewCopy = YES;
            [self performSegueWithIdentifier:@"ViewTaskSegue" sender:nil];
            break;
        case 1: // Edit
        {
            taskToShow = [contentDataArray objectAtIndex:cell.tag];
            [self performSegueWithIdentifier:@"ViewTaskSegue" sender:nil];
            break;
        }
        case 2: // delete
        {
            [[TaskListModel sharedInstance] deleteTask:contentDataArray[cell.tag]];
            [self reloadContentData];
            [table reloadData];
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


@end
