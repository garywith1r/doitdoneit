//
//  TaskListModel.h
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskDTO.h"


@interface TaskListModel : NSObject

@property (nonatomic) NSInteger totalMissedTasks;
@property (nonatomic) NSInteger totalCompletedTasks;

+ (TaskListModel*) sharedInstance;

- (void) storeTasksData;

- (TaskDTO*) taskAtIndex:(int)index;
- (void) addTask:(TaskDTO*) task;
- (void) deleteTask:(TaskDTO*) task;
- (void) completeTask:(TaskDTO*) task;
- (void) completeTaskAtIndex:(int) index;

- (NSArray*) getToDoTasks;
- (void) forceRecalculateTasks;
- (NSArray*) getDoneTasks;
- (void) evaluateMissedTasks;
@end
