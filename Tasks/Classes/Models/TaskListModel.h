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

+ (TaskListModel*) sharedInstance;

- (void) storeTasksData;
- (void) storeData;

- (TaskDTO*) taskAtIndex:(int)index;
- (void) addTask:(TaskDTO*) task;
- (void) deleteTask:(TaskDTO*) task;
- (void) completeTask:(TaskDTO*) task;
- (void) completeTaskAtIndex:(int) index;
- (void) missTask:(TaskDTO*) task;

- (NSArray*) getToDoTasks;
- (void) forceRecalculateTasks;
- (NSArray*) getDoneTasks;
- (void) evaluateMissedTasks;
@end
