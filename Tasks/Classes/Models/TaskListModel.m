//
//  TaskListModel.m
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "TaskListModel.h"
#import "NSDate+Reporting.h"
#import "StatsModel.h"
#import "Constants.h"

#define TASKS_ARRAY_KEY @"tasksList"
#define COMPLETED_TASKS_ARRAY_KEY @"completedTasksList"
#define MISSED_TASKS_ARRAY_KEY  @"missedTasksList"

@interface TaskListModel () {
    NSMutableArray* tasks;
    NSMutableArray* completedTasks;
    NSMutableArray* missedTasks;
    
    NSArray* toDoTasks;
    NSArray* doneTasks;
}

@end

@implementation TaskListModel

TaskListModel* instance;

+ (TaskListModel*) sharedInstance {
    if (!instance) {
        instance = [[TaskListModel alloc] init];
    }
    return instance;
}

- (id) init {
    if (self = [super init]) {
        [self loadTasksData];
        [self loadCompletedTasksData];
        [self loadMissedTasksData];
    }
    return self;
}

- (void) loadTasksData {
    tasks = [self loadTaskArrayForKey:TASKS_ARRAY_KEY];
}

- (void) loadCompletedTasksData {
    completedTasks = [self loadTaskArrayForKey:COMPLETED_TASKS_ARRAY_KEY];
}

- (void) loadMissedTasksData {
    missedTasks = [self loadTaskArrayForKey:MISSED_TASKS_ARRAY_KEY];
}

- (void) storeTasksData {
    [self saveTasksArray:tasks withKey:TASKS_ARRAY_KEY];
}

- (void) storeCompletedTasksData {
    [self saveTasksArray:completedTasks withKey:COMPLETED_TASKS_ARRAY_KEY];
}

- (void) storeMissedTasksData {
    [self saveTasksArray:missedTasks withKey:MISSED_TASKS_ARRAY_KEY];
}

- (void) saveTasksArray:(NSArray*)array withKey:(NSString*) key {
    
    NSMutableArray* storeArray = [NSMutableArray arrayWithCapacity:array.count];
    
    for (TaskDTO* task in array) {
        [storeArray addObject:[task convertToDictionary]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:storeArray] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSMutableArray*) loadTaskArrayForKey:(NSString*) key {
    NSArray* storedArray = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    NSMutableArray* tempArray = [NSMutableArray arrayWithCapacity:storedArray.count];
    
    for (NSDictionary* dic in storedArray) {
        [tempArray addObject:[TaskDTO taskDtoFromDictionary:dic]];
    }
    
    return tempArray;
}

- (NSMutableArray*) sortTaskArraysByShowingDate:(NSMutableArray*)originalArray {
    return  [NSMutableArray arrayWithArray:[originalArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        //sort by dueDate and priorityPoints
        NSDate *first = [(TaskDTO*) a showingDate];
        NSDate *second = [(TaskDTO*)b showingDate];
        return [first compare:second];
    }]];
}

- (NSMutableArray*) sortTaskArraysByDueDate:(NSMutableArray*)originalArray {
    return  [NSMutableArray arrayWithArray:[originalArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        //sort by dueDate and priorityPoints
        NSDate *first = [(TaskDTO*) a dueDate];
        NSDate *second = [(TaskDTO*)b dueDate];
        NSComparisonResult comparisonResult = [first compare:second];
        
        if (comparisonResult == NSOrderedSame) {
            if ([a taskPoints] < [b taskPoints]) {
                return NSOrderedDescending;
            } else if ([a taskPoints] > [b taskPoints]) {
                return NSOrderedAscending;
            } else {
                return [[a title] compare:[b title]];
            }
        }
        return comparisonResult;
    }]];
}

- (NSMutableArray*) sortTaskArraysByCompletitionDate:(NSMutableArray*)originalArray {
    return  [NSMutableArray arrayWithArray:[originalArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        //sort by dueDate and priorityPoints
        NSDate *first = [(TaskDTO*) a completitionDate];
        NSDate *second = [(TaskDTO*)b completitionDate];
        return [second compare:first];
    }]];
}

#pragma mark - TaskManagment Methods

- (void) addTask:(TaskDTO*) task {
    if ([tasks containsObject:task])
        [tasks removeObject:task];
        
        
    [tasks addObject:task];
    tasks = [self sortTaskArraysByShowingDate:tasks];
    [self storeTasksData];
    toDoTasks = nil;
    
}

- (void) deleteTask:(TaskDTO*) deletingTask {
    //if two tasks were created at the same time, then are the same task
    NSMutableArray* tempArray = [[NSMutableArray alloc] initWithCapacity:[tasks count]];
    
    if ([tasks containsObject:deletingTask]) {
        for (TaskDTO* task in tasks) {
            if ([task.creationDate timeIntervalSinceDate:deletingTask.creationDate] == 0) {
                [tempArray addObject:task];
            }
        }
        
        [tasks removeObjectsInArray:tempArray];
        
        toDoTasks = nil;
        [self storeTasksData];
        
    } else if ([completedTasks containsObject:deletingTask]) {
        [completedTasks removeObject:deletingTask];
        doneTasks = nil;
        [self storeCompletedTasksData];
    } else if ([missedTasks containsObject:deletingTask]) {
        [missedTasks removeObject:deletingTask];
        doneTasks = nil;
        [self storeCompletedTasksData];
    }
    
    [[StatsModel sharedInstance] contabilizeDeletedTask:deletingTask];
}

- (TaskDTO*) taskAtIndex:(int)index {
    return [tasks objectAtIndex:index];
}

- (void) completeTask:(TaskDTO*) task {
    [task incrementDoneItBy:1];

    [[StatsModel sharedInstance] contabilizeCompletedTask:task];
    
    task.status = TaskStatusComplete;
    task.completitionDate = [NSDate date];
    
    [tasks removeObject:task];
    [completedTasks addObject:task];
    completedTasks = [self sortTaskArraysByShowingDate:completedTasks];
    
    [self addTask:[self createNextTaskTo:task]];
    
    [self storeTasksData];
    [self storeCompletedTasksData];
    toDoTasks = nil;
    doneTasks = nil;
}

- (void) missTask:(TaskDTO*) task {
    [task incrementMissedItBy:1];
    [[StatsModel sharedInstance] contabilizeMissedTask:task];
    [tasks removeObject:task];
    [missedTasks addObject:task];
    
    
    task.completitionDate = [NSDate date];
    task.status = TaskStatusMissed;
    //create the task for the next repetition of the completed Task
    
    
    [self addTask:[self createNextTaskTo:task]];
    
    [self storeTasksData];
    toDoTasks = nil;
    doneTasks = nil;
}

- (void) completeTaskAtIndex:(int) index {
    [self completeTask:tasks[index]];
}

- (NSArray*) getToDoTasks {
    if (toDoTasks)
        return toDoTasks;
    
    NSDate* today  = [NSDate midnightToday];
    
    NSMutableArray* tempTodaysTaks = [[NSMutableArray alloc] initWithCapacity:[tasks count]];
    //I already know that the array is sorted by date, and that there no missed tasks in it.
    for (TaskDTO* task in tasks) {
        if ([task.showingDate timeIntervalSinceDate:today] <= 0) {
            [tempTodaysTaks addObject:task];
        } else {
            //no more tasks for today.
            break;
        }
    }
    
    
    toDoTasks = [NSArray arrayWithArray:[self sortTaskArraysByDueDate:tempTodaysTaks]];
    
    
    return toDoTasks;
}

- (void) forceRecalculateTasks {
    toDoTasks = nil;
    doneTasks = nil;
}

- (NSArray*) getDoneTasks {
    if (doneTasks)
        return doneTasks;
    
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:completedTasks];
    [tempArray addObjectsFromArray:missedTasks];
    
    doneTasks = [self sortTaskArraysByCompletitionDate:tempArray];
    
    return doneTasks;
}

- (void) evaluateMissedTasks {
    BOOL hasChanges = NO;
    
    NSMutableArray* tempArray = [[NSMutableArray alloc] initWithCapacity:tasks.count];
    
    //I already know that the array is sorted by date, so I just need to remove all tasks with due date previous than today.
    for (TaskDTO* task in tasks) {
        if ([self hasMissedIt:task]) {
            [tempArray addObject:task];
            hasChanges = YES;
        }
    }
    
    if (hasChanges) {
        for (TaskDTO* task in tempArray) {
            
            //count the mised task, remove from tasks array and add it ot missed array
            [task incrementMissedItBy:1];
            [[StatsModel sharedInstance] contabilizeMissedTask:task];
            
            task.completitionDate = [NSDate date];
            task.status = TaskStatusMissed;
            
            [tasks removeObject:task];
            [missedTasks addObject:task];
            
            //for each task, we'll add as missed the remaining repetitions and create the new task.
            TaskDTO* newTask = [self createNextTaskTo:task];
            
            //check if the next task due date hasn't passed yet. Miss as many tasks as necesary
            while ([self hasMissedIt:newTask]) {
                newTask.completitionDate = [NSDate date];
                [missedTasks addObject:newTask];
                
                newTask.completitionDate = [NSDate date];
                newTask.status = TaskStatusMissed;
                
                
                [newTask incrementMissedItBy:1];
                [[StatsModel sharedInstance] contabilizeMissedTask:newTask];
                
                newTask = [self createNextTaskTo:newTask];
            }
            
            [self addTask:newTask];
        }
        //sort and store missing's task array.
        missedTasks = [self sortTaskArraysByShowingDate:missedTasks];
        
        //store changes
        [self storeMissedTasksData];
        [self storeTasksData];
    }
}

- (BOOL) hasMissedIt:(TaskDTO*) task {
    return [[NSDate midnightToday] timeIntervalSinceDate:task.dueDate] > 0;
}

- (TaskDTO*) createNextTaskTo:(TaskDTO*)task {
    TaskDTO* newTask = [task copy];
    
    if (task.currentRepetition < task.repeatTimes) {
        newTask.currentRepetition++;
    } else {
        newTask.currentRepetition = 1;
        
        if (newTask.repeatPeriod == Weekly) {
            //86400 = 1 day in seconds
            newTask.showingDate = [NSDate dateWithTimeInterval:ONE_DAY sinceDate:task.dueDate];
            // 604800 = 7 days in seconds
            newTask.dueDate = [NSDate dateWithTimeInterval:604800 sinceDate:task.dueDate];
        } else if (newTask.repeatPeriod == Fortnightly) {
            //86400 = 1 day in seconds
            newTask.showingDate = [NSDate dateWithTimeInterval:ONE_DAY sinceDate:task.dueDate];
            //1209600 = 14 days in seconds
            newTask.dueDate = [NSDate dateWithTimeInterval:1209600 sinceDate:task.dueDate];
        } else if (newTask.repeatPeriod == Monthly) {
            newTask.showingDate = [NSDate firstDayOfNextMonthFromDay:task.dueDate];
            newTask.dueDate = [NSDate oneDayBefore:[NSDate firstDayOfNextMonthFromDay:newTask.showingDate]];
        }
    }
    
    return newTask;
}
@end
