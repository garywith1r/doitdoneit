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
    
    CGFloat bestDailyCompletedTasksAmount;
    CGFloat bestWeeklyCompletedTasksAmount;
    CGFloat bestMontlyCompletedTaskAmount;
}

@end

@implementation StatsModel
@synthesize todayCompleted, todayMissed, todayPoints;
@synthesize yesterdayCompleted, yesterdayMissed, yesterdayPoints;
@synthesize thisWeekCompleted, thisWeekMissed, thisWeekPoints;
@synthesize lastWeekCompleted, lastWeekMissed, lastWeekPoints;
@synthesize thisMonthCompleted, thisMonthMissed, thisMonthPoints;
@synthesize totalCompleted, totalMissed, totalPoints;
@synthesize bestConsecutiveDays, consecutiveDays, awards;

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

- (CGFloat) todayHitRate {
    if (todayCompleted + todayMissed == 0) return 0;
    return todayCompleted / (float)(todayCompleted + todayMissed) * 100;
}

- (CGFloat) yesterdayHitRate {
    if (yesterdayCompleted + yesterdayMissed == 0) return 0;
    return yesterdayCompleted / (float)(yesterdayCompleted + yesterdayMissed) * 100;
}

- (CGFloat) thisWeekHitRate {
    if (thisWeekCompleted + thisWeekMissed == 0) return 0;
    return thisWeekCompleted / (float)(thisWeekCompleted + thisWeekMissed) * 100;
}

- (CGFloat) lastWeekHitRate {
    if (lastWeekCompleted + lastWeekMissed == 0) return 0;
    return lastWeekCompleted / (float)(lastWeekCompleted + lastWeekMissed) * 100;
}

- (CGFloat) totalHitRate {
    if (totalCompleted + totalMissed == 0) return 0;
    return totalCompleted / (float)(totalCompleted + totalMissed) * 100;
}

- (void) contabilizeCompletedTask:(TaskDTO*) task {
    todayCompleted++;
    todayPoints += task.taskPoints;
    thisWeekCompleted++;
    thisWeekPoints += task.taskPoints;
    thisMonthCompleted ++;
    thisMonthPoints += task.taskPoints;
    totalCompleted++;
    totalPoints += task.taskPoints;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:todayCompleted forKey:@"todayCompleted"];
    [userDefaults setInteger:todayPoints forKey:@"todayPoints"];
    [userDefaults setInteger:thisWeekCompleted forKey:@"thisWeekCompleted"];
    [userDefaults setInteger:thisWeekPoints forKey:@"thisWeekPoints"];
    [userDefaults setInteger:thisMonthCompleted forKey:@"thisMonthCompleted"];
    [userDefaults setInteger:thisMonthPoints forKey:@"thisMonthPoints"];
    [userDefaults setInteger:totalCompleted forKey:@"totalCompleted"];
    [userDefaults setInteger:totalPoints forKey:@"totalPoints"];
    
    
    
    NSDate* lastCompleteTaskDay = [userDefaults objectForKey:@"lastCompleteTaskDay"];
    
    //AWARD
    if ([today timeIntervalSinceDate:lastCompleteTaskDay] != 0 ) {
        if ([today timeIntervalSinceDate:lastCompleteTaskDay] == ONE_DAY) {
            consecutiveDays ++;
            if (consecutiveDays > bestConsecutiveDays) {
                bestConsecutiveDays = consecutiveDays;
                [userDefaults setInteger:bestConsecutiveDays forKey:@"bestConsecutiveDays"];
                
                NSDictionary* dic = @{@"amount":[NSNumber numberWithInteger:bestConsecutiveDays],
                                      @"type":[NSNumber numberWithInteger:ConsecutiveDaysAward],
                                      @"day":[NSDate midnightToday]};
                
                [self addAward:dic];
                
            }
        } else {
            consecutiveDays = 0;
        }
        
        [userDefaults setInteger:consecutiveDays forKey:@"consecutiveDays"];
        [userDefaults setObject:today forKey:@"lastCompleteTaskDay"];
        
    }
    
    [userDefaults synchronize];
    
}

- (void) contabilizeDeletedTask:(TaskDTO*) task {
    if (task.status == TaskStatusComplete) {
        totalCompleted--;
        totalPoints -= task.taskPoints;
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
                todayPoints += task.taskPoints;
                thisWeekCompleted++;
                thisWeekPoints += task.taskPoints;
            } else
                
            //check if it was completed yesterday
            if (([task.completitionDate timeIntervalSinceDate:[NSDate oneDayBefore:today]] > 0) && ([task.completitionDate timeIntervalSinceDate:[NSDate midnightToday]] < 0)) {
                yesterdayCompleted++;
                yesterdayPoints += task.taskPoints;
                thisWeekCompleted++;
                thisWeekPoints += task.taskPoints;
            } else
                
            //check if it was completed this week
            if (([task.completitionDate timeIntervalSinceDate:[NSDate firstDayOfCurrentWeek]] >= 0) && ([task.completitionDate timeIntervalSinceDate:[NSDate firstDayOfNextWeek]] < 0)) {
                thisWeekCompleted++;
                thisWeekPoints += task.taskPoints;
            } else
                
            //check if it was completed on previous week
            if (([task.completitionDate timeIntervalSinceDate:[NSDate firstDayOfLastWeek]] >= 0) && ([task.completitionDate timeIntervalSinceDate:[NSDate firstDayOfCurrentWeek]] < 0)) {
                lastWeekCompleted++;
                lastWeekPoints += task.taskPoints;
            }
            
            //check if it was missed on this month
            if ([task.dueDate timeIntervalSinceDate:[NSDate firstDayOfCurrentMonth]] > 0) {
                thisMonthCompleted ++;
            } else
            //check if it was missed on previous month
            if (([task.dueDate timeIntervalSinceDate:[NSDate firstDayOfPreviousMonth]] > 0) && ([task.dueDate timeIntervalSinceDate:[NSDate firstDayOfCurrentMonth]] < 0)) {
                    //        thisMonthMissed ++;
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
    } else
    
    //check if it was missed on this month
    if ([task.dueDate timeIntervalSinceDate:[NSDate firstDayOfCurrentMonth]] > 0) {
        thisMonthMissed ++;
    } else
        
    //check if it was missed on previous month
    if (([task.dueDate timeIntervalSinceDate:[NSDate firstDayOfPreviousMonth]] > 0) && ([task.dueDate timeIntervalSinceDate:[NSDate firstDayOfCurrentMonth]] < 0)) {
//        thisMonthMissed ++;
    }
    
    
    if (save) {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:todayMissed forKey:@"todayMissed"];
        [userDefaults setInteger:yesterdayMissed forKey:@"yesterdayMissed"];
        [userDefaults setInteger:thisWeekMissed forKey:@"thisWeekMissed"];
        [userDefaults setInteger:lastWeekMissed forKey:@"lastWeekMissed"];
        [userDefaults setInteger:thisMonthMissed forKey:@"thisMonthMissed"];
        [userDefaults setInteger:totalMissed forKey:@"totalMissed"];
        
        [userDefaults synchronize];
    }
}

- (void) loadData {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    today = [userDefaults objectForKey:@"storedToday"];
    
    todayCompleted = [userDefaults integerForKey:@"todayCompleted"];
    todayMissed = [userDefaults integerForKey:@"todayMissed"];
    todayPoints = [userDefaults integerForKey:@"todayPoints"];
    
    yesterdayCompleted = [userDefaults integerForKey:@"yesterdayCompleted"];
    yesterdayMissed = [userDefaults integerForKey:@"yesterdayMissed"];
    yesterdayPoints = [userDefaults integerForKey:@"yesterdayPoints"];
    
    thisWeekCompleted = [userDefaults integerForKey:@"thisWeekCompleted"];
    thisWeekMissed = [userDefaults integerForKey:@"thisWeekMissed"];
    thisWeekPoints = [userDefaults integerForKey:@"thisWeekPoints"];
    
    lastWeekCompleted = [userDefaults integerForKey:@"lastWeekCompleted"];
    lastWeekMissed = [userDefaults integerForKey:@"lastWeekMissed"];
    lastWeekPoints = [userDefaults integerForKey:@"lastWeekPoints"];
    
    thisMonthCompleted = [userDefaults integerForKey:@"thisMonthCompleted"];
    thisMonthMissed = [userDefaults integerForKey:@"thisMonthMissed"];
    thisMonthPoints = [userDefaults integerForKey:@"thisMonthPoints"];
    
    totalCompleted = [userDefaults integerForKey:@"totalCompleted"];
    totalMissed = [userDefaults integerForKey:@"totalMissed"];
    totalPoints = [userDefaults integerForKey:@"totalPoints"];
    
    
    bestDailyCompletedTasksAmount = [userDefaults floatForKey:@"bestDaily"];
    bestWeeklyCompletedTasksAmount = [userDefaults floatForKey:@"bestWeekly"];
    bestMontlyCompletedTaskAmount = [userDefaults floatForKey:@"bestMontly"];
    
    awards = [userDefaults objectForKey:@"AwardsArray"];
    [userDefaults synchronize];
}

- (void) evaluateDay {
    if (today && ([today timeIntervalSinceDate:[NSDate midnightToday]] != 0)) {
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        if ([[NSDate midnightToday] timeIntervalSinceDate:today] <= ONE_DAY) {
            //has passed one day, so today is yesterday.
            yesterdayCompleted = todayCompleted;
            yesterdayMissed = todayMissed;
            yesterdayPoints = todayPoints;
        } else {
            //has passed more than a day.
            yesterdayCompleted = yesterdayMissed = yesterdayPoints = 0;
        }
        
        //AWARD
        if (bestDailyCompletedTasksAmount < todayCompleted) {
            NSDictionary* dic = @{@"amount":[NSNumber numberWithInteger:todayCompleted],
                                  @"type":[NSNumber numberWithInteger:HighestDailyPointsAward],
                                  @"day":[NSDate midnightToday]};
            
            [self addAward:dic];
            
            bestDailyCompletedTasksAmount = todayCompleted;
            [userDefaults setFloat:todayCompleted forKey:@"bestDaily"];
            
            
            
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
            
            //AWARD 
            if (bestWeeklyCompletedTasksAmount < thisWeekCompleted) {
                NSDictionary* dic = @{@"amount":[NSNumber numberWithInteger:thisWeekCompleted],
                                      @"type":[NSNumber numberWithInteger:HighestWeeklyPointsAward],
                                      @"day":[NSDate midnightToday]};
                
                [self addAward:dic];
                
                bestWeeklyCompletedTasksAmount = thisWeekCompleted;
                [userDefaults setFloat:bestWeeklyCompletedTasksAmount forKey:@"bestDaily"];
            }
            
            thisWeekPoints = thisWeekCompleted = thisWeekMissed = 0;
        }
        
        if ([[NSDate firstDayOfMonthFromDay:today] timeIntervalSinceDate:[NSDate firstDayOfCurrentMonth]] == 0) {
            //we're on the same month.
        } else {
            //AWARD
            if (bestMontlyCompletedTaskAmount < thisMonthCompleted) {
                bestMontlyCompletedTaskAmount = thisMonthCompleted;
                
                NSDictionary* dic = @{@"amount":[NSNumber numberWithInteger:bestMontlyCompletedTaskAmount],
                                      @"type":[NSNumber numberWithInteger:HighestMonthlyPointsAward],
                                      @"day":[NSDate midnightToday]};
                [self addAward:dic];
                
                
                [userDefaults setFloat:bestMontlyCompletedTaskAmount forKey:@"bestMontly"];
            }
            thisMonthPoints = thisMonthCompleted = thisMonthMissed = 0;
        }
        
        today = [NSDate midnightToday];
    
        
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
        
        [userDefaults setInteger:thisMonthCompleted forKey:@"thisMonthCompleted"];
        [userDefaults setInteger:thisMonthMissed forKey:@"thisMonthMissed"];
        [userDefaults setInteger:thisMonthPoints forKey:@"thisMonthPoints"];
        
        [userDefaults setInteger:totalCompleted forKey:@"totalCompleted"];
        [userDefaults setInteger:totalMissed forKey:@"totalMissed"];
        [userDefaults setInteger:totalPoints forKey:@"totalPoints"];
        
        [userDefaults synchronize];
    } else if (!today) {
        today = [NSDate midnightToday];
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:today forKey:@"storedToday"];
        [userDefaults synchronize];
    }
    
}



- (void) addAward:(NSDictionary*)awardDic {
    NSMutableArray* tempArray = [[NSMutableArray alloc] initWithCapacity:awards.count];
    
    enum AwardType type = [[awardDic objectForKey:@"type"] intValue];
    
    for (NSDictionary* award in awards) {
        if ([[award objectForKey:@"type"] integerValue] != type)
             [tempArray addObject:award];
    }
    
    [tempArray insertObject:awardDic atIndex:0];
    
    self.awards = [NSArray arrayWithArray:tempArray];
    
    [[NSUserDefaults standardUserDefaults] setObject:awards forKey:@"AwardsArray"];
             
}

@end
