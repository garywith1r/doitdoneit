//
//  ViewController.h
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAAttributedLabel.h"
#import "TaskDto.h"


#define NORMAL_ROW_HEIGHT 60.0
#define EXPANDED_ROW_HEIGHT 150.0

#define THUMBNAIL_FRAME CGRectMake (7,5,0,0)

#define COMPLETE_TASK_SEGUE @"CompleteTaskSegue"
#define NEW_TASK_SEGUE @"NewTaskSegue"
#define EDIT_TASK_SEGUE @"EditTaskSegue"


@interface TasksListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DAAttributedLabelDelegate> {
    NSArray* contentDataArray;
    IBOutlet UITableView* table;
    
    int tagToDeleteIndex;
    NSInteger selectedRow;
    
    TaskDTO* taskToShow;
    BOOL taskToShowIsNewCopy;
}

@property (nonatomic, weak) UINavigationController* navController;

- (void) deleteTaskOnMarkedPosition;
- (NSAttributedString*) stringWithBoldPart:(NSString*)boldPart andNormalPart:(NSString*)normalPart;



- (void) thumbnailTapped:(UIButton*)sender;

- (void) expandOrContractCell:(UIButton*) sender;
- (void) showTaskAtRow:(NSInteger)row;
- (void) hideTaskAtRow:(NSInteger)row;



@end
