//
//  StatsModel.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 2/27/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "StatsModel.h"
#import "NSDate+Reporting.h"
#import "TaskListModel.h"
#import "Constants.h"

@interface StatsModel () {
    NSDate* today;
}

@end

@implementation StatsModel
@synthesize todayCompleted, todayMissed, todayPoints;
@synthesize yesterdayCompleted, yesterdayMissed, yesterdayPoints;
@synthesize thisWeekCompleted, thisWeekMissed, thisWeekPoints;
@synthesize lastWeekCompleted, lastWeekMissed, lastWeekPoints;
@synthesize totalCompleted, totalMissed, totalPoints;

StatsModel* statsInstance;

+ (StatsModel*) sharedInstance {
    if (!statsInstance) {
        statsInstance = [[StatsModel alloc] init];
    }
    
    [statsInstance evaluateDay];
    return statsInstance;
}

- (id) init {
    if (self = [super init]) {
        [self loadData];
    }
    
    return self;
}

- (float) todayHitRate {
    if (todayCompleted + todayMissed == 0) return 0;
    return todayCompleted / (float)(todayCompleted + todayMissed) * 100;
}

- (float) yesterdayHitRate {
    if (yesterdayCompleted + yesterdayMissed == 0) return 0;
    return yesterdayCompleted / (float)(yesterdayCompleted + yesterdayMissed) * 100;
}

- (float) thisWeekHitRate {
    if (thisWeekCompleted + thisWeekMissed == 0) return 0;
    return thisWeekCompleted / (float)(thisWeekCompleted + thisWeekMissed) * 100;
}

- (float) lastWeekHitRate {
    if (lastWeekCompleted + lastWeekMissed == 0) return 0;
    return lastWeekCompleted / (float)(lastWeekCompleted + lastWeekMissed) * 100;
}

- (float) totalHitRate {
    if (totalCompleted + totalMissed == 0) return 0;
    return totalCompleted / (float)(totalCompleted + totalMissed) * 100;
}

- (void) contabilizeCompletedTask:(TaskDTO*) task {
    todayCompleted++;
    todayPoints += task.priorityPoints;
    thisWeekCompleted++;
    thisWeekPoints += task.priorityPoints;
    totalCompleted++;
    totalPoints += task.priorityPoints;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:todayCompleted forKey:@"todayCompleted"];
    [userDefaults setInteger:todayPoints forKey:@"todayPoints"];
    [userDefaults setInteger:thisWeekCompleted forKey:@"thisWeekCompleted"];
    [userDefaults setInteger:thisWeekPoints forKey:@"thisWeekPoints"];
    [userDefaults setInteger:totalCompleted forKey:@"totalCompleted"];
    [userDefaults setInteger:totalPoints forKey:@"totalPoints"];
    
    [userDefaults synchronize];
}

- (void) contabilizeDeletedTask:(TaskDTO*) task {
    if (task.status == TaskStatusComplete) {
        totalCompleted--;
        totalPoints -= task.priorityPoints;
    } else if (task.status == TaskStatusMissed) {
        totalMissed --;
    }
    
    [self recalculateVolatileStats];
}

- (void) recalculateVolatileStats {
    
    todayCompleted = todayPoints = todayMissed = 0;
    yesterdayCompleted = yesterdayPoints = yesterdayMissed = 0;
    thisWeekCompleted = thisWeekPoints = thisWeekMissed = 0;
    lastWeekCompleted = lastWeekPoints = lastWeekMissed = 0;
    
    NSArray* tasksToRecalculate = [[TaskListModel sharedInstance] getDoneTasks];
    for (TaskDTO* task in tasksToRecalculate) {
        
        if (task.status == TaskStatusMissed) {
            totalMissed --; //because it'll be counted again
            [self contabilizeMissedTask:task storingData:NO];
        } else {
        
            //check if it was completed today
            if (([task.completitionDate timeIntervalSinceDate:today] > 0) && ([task.completitionDate timeIntervalSinceDate:[NSDate midnightTomorrow]] < 0)) {
                todayCompleted++;
                todayPoints += task.priorityPoints;
                thisWeekCompleted++;
                thisWeekPoints += task.priorityPoints;
            } else
                
            //check if it was completed yesterday
            if (([task.completitionDate timeIntervalSinceDate:[NSDate oneDayBefore:today]] > 0) && ([task.completitionDate timeIntervalSinceDate:[NSDate midnightToday]] < 0)) {
                yesterdayCompleted++;
                yesterdayPoints += task.priorityPoints;
                thisWeekCompleted++;
                thisWeekPoints += task.priorityPoints;
            } else
                
            //check if it was completed this week
            if (([task.completitionDate timeIntervalSinceDate:[NSDate firstDayOfCurrentWeek]] > 0) && ([task.completitionDate timeIntervalSinceDate:[NSDate firstDayOfNextWeek]] < 0)) {
                thisWeekCompleted++;
                thisWeekPoints += task.priorityPoints;
            } else
                
            //check if it was completed on previous week
            if (([task.completitionDate timeIntervalSinceDate:[NSDate firstDayOfLastWeek]] > 0) && ([task.completitionDate timeIntervalSinceDate:[NSDate firstDayOfCurrentWeek]] < 0)) {
                lastWeekCompleted++;
                lastWeekPoints += task.priorityPoints;
            }
            
        }
        
    }
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:todayCompleted forKey:@"todayCompleted"];
    [userDefaults setInteger:todayPoints forKey:@"todayPoints"];
    [userDefaults setInteger:yesterdayCompleted forKey:@"yesterdayCompleted"];
    [userDefaults setInteger:yesterdayPoints forKey:@"yesterdayPoints"];
    [userDefaults setInteger:thisWeekCompleted forKey:@"thisWeekCompleted"];
    [userDefaults setInteger:thisWeekPoints forKey:@"thisWeekPoints"];
    [userDefaults setInteger:lastWeekCompleted forKey:@"lastWeekCompleted"];
    [userDefaults setInteger:lastWeekPoints forKey:@"lastWeekPoints"];
    [userDefaults setInteger:totalCompleted forKey:@"totalCompleted"];
    [userDefaults setInteger:totalPoints forKey:@"totalPoints"];
    
    [userDefaults setInteger:todayMissed forKey:@"todayMissed"];
    [userDefaults setInteger:yesterdayMissed forKey:@"yesterdayMissed"];
    [userDefaults setInteger:thisWeekMissed forKey:@"thisWeekMissed"];
    [userDefaults setInteger:lastWeekMissed forKey:@"lastWeekMissed"];
    [userDefaults setInteger:totalMissed forKey:@"totalMissed"];
    
    [userDefaults synchronize];
    
}

- (void) contabilizeMissedTask:(TaskDTO *)task {
    [self contabilizeMissedTask:task storingData:YES];
}

- (void) contabilizeMissedTask:(TaskDTO *)task storingData:(BOOL)save {
   
    
    if ([task.dueDate timeIntervalSinceDate:[NSDate midnightToday]] > 0) {
        //task skiped, so it's today.
        todayMissed ++;
        thisWeekMissed ++;
        totalMissed ++;
    } else
    //task was missed by due date
     totalMissed ++;
    
    //check if it was missed today
    if (([task.dueDate timeIntervalSinceDate:today] < 0) && ([task.completitionDate timeIntervalSinceDate:[NSDate midnightYesterday]] > 0)) {
        todayMissed ++;
        thisWeekMissed ++;
    } else
        
    //check if it was missed yesterday
    if (([task.dueDate timeIntervalSinceDate:[NSDate midnightYesterday]] < 0) && ([task.dueDate timeIntervalSinceDate:[NSDate oneDayBefore:[NSDate midnightYesterday]]] > 0)) {
        yesterdayMissed ++;
        thisWeekMissed ++;
    } else
        
    //check if it was missed this week
    if (([task.dueDate timeIntervalSinceDate:[NSDate firstDayOfCurrentWeek]] > 0) && ([task.dueDate timeIntervalSinceDate:[NSDate firstDayOfNextWeek]] < 0)) {
        thisWeekMissed ++;
    } else
        
    //check if it was missed on previous week
    if (([task.dueDate timeIntervalSinceDate:[NSDate firstDayOfLastWeek]] > 0) && ([task.dueDate timeIntervalSinceDate:[NSDate firstDayOfCurrentWeek]] < 0)) {
        lastWeekMissed ++;
    }
    
    
    if (save) {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:todayMissed forKey:@"todayMissed"];
        [userDefaults setInteger:yesterdayMissed forKey:@"yesterdayMissed"];
        [userDefaults setInteger:thisWeekMissed forKey:@"thisWeekMissed"];
        [userDefaults setInteger:lastWeekMissed forKey:@"lastWeekMissed"];
        [userDefaults setInteger:totalMissed forKey:@"totalMissed"];
        
        
        [userDefaults synchronize];
    }
}

- (void) loadData {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    today = [userDefaults objectForKey:@"storedToday"];
    
    todayCompleted = (int)[userDefaults integerForKey:@"todayCompleted"];
    todayMissed = (int)[userDefaults integerForKey:@"todayMissed"];
    todayPoints = (int)[userDefaults integerForKey:@"todayPoints"];
    
    yesterdayCompleted = (int)[userDefaults integerForKey:@"yesterdayCompleted"];
    yesterdayMissed = (int)[userDefaults integerForKey:@"yesterdayMissed"];
    yesterdayPoints = (int)[userDefaults integerForKey:@"yesterdayPoints"];
    
    thisWeekCompleted = (int)[userDefaults integerForKey:@"thisWeekCompleted"];
    thisWeekMissed = (int)[userDefaults integerForKey:@"thisWeekMissed"];
    thisWeekPoints = (int)[userDefaults integerForKey:@"thisWeekPoints"];
    
    lastWeekCompleted = (int)[userDefaults integerForKey:@"lastWeekCompleted"];
    lastWeekMissed = (int)[userDefaults integerForKey:@"lastWeekMissed"];
    lastWeekPoints = (int)[userDefaults integerForKey:@"lastWeekPoints"];
    
    totalCompleted = (int)[userDefaults integerForKey:@"totalCompleted"];
    totalMissed = (int)[userDefaults integerForKey:@"totalMissed"];
    totalPoints = (int)[userDefaults integerForKey:@"totalPoints"];
    
    [userDefaults synchronize];
}

- (void) evaluateDay {
    if (today && ([today timeIntervalSinceDate:[NSDate midnightToday]] != 0)) {
        
        if ([today timeIntervalSinceDate:[NSDate midnightYesterday]] <= ONE_DAY) {
            //has passed one day, so today is yesterday.
            yesterdayCompleted = todayCompleted;
            yesterdayMissed = todayMissed;
            yesterdayPoints = todayPoints;
            
        } else {
            //has passed more than a day.
            yesterdayCompleted = yesterdayMissed = yesterdayPoints = 0;
        }
        todayCompleted = todayPoints = todayMissed = 0;
        
        
        if ([[NSDate firstDayOfWeekFromDate:today] timeIntervalSinceDate:[NSDate firstDayOfCurrentWeek]] == 0) {
            //we're on the same week
        } else {
            if ([[NSDate firstDayOfWeekFromDate:today] timeIntervalSinceDate:[NSDate firstDayOfLastWeek]] == 0) {
                //we're on the next week
                lastWeekCompleted = thisWeekCompleted;
                lastWeekMissed = thisWeekMissed;
                lastWeekPoints = thisWeekPoints;
            } else {
                //more than a week has passed
                lastWeekCompleted = lastWeekMissed = lastWeekPoints = 0;
            }
            thisWeekPoints = thisWeekCompleted = thisWeekMissed = 0;
        }
        
        today = [NSDate midnightToday];
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:today forKey:@"storedToday"];
        
        [userDefaults setInteger:todayCompleted forKey:@"todayCompleted"];
        [userDefaults setInteger:todayMissed forKey:@"todayMissed"];
        [userDefaults setInteger:todayPoints forKey:@"todayPoints"];
        
        [userDefaults setInteger:yesterdayCompleted forKey:@"yesterdayCompleted"];
        [userDefaults setInteger:yesterdayMissed forKey:@"yesterdayMissed"];
        [userDefaults setInteger:yesterdayPoints forKey:@"yesterdayPoints"];
        
        [userDefaults setInteger:thisWeekCompleted forKey:@"thisWeekCompleted"];
        [userDefaults setInteger:thisWeekPoints forKey:@"thisWeekPoints"];
        [userDefaults setInteger:thisWeekMissed forKey:@"thisWeekMissed"];
        
        [userDefaults setInteger:lastWeekCompleted forKey:@"lastWeekCompleted"];
        [userDefaults setInteger:lastWeekMissed forKey:@"lastWeekMissed"];
        [userDefaults setInteger:lastWeekPoints forKey:@"lastWeekPoints"];
        
        [userDefaults setInteger:totalCompleted forKey:@"totalCompleted"];
        [userDefaults setInteger:totalMissed forKey:@"totalMissed"];
        [userDefaults setInteger:totalPoints forKey:@"totalPoints"];
        
        [userDefaults synchronize];
    } else if (!today) {
        today = [NSDate midnightToday];
    }
    
    
}

@end
