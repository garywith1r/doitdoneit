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
#import "UsersModel.h"
#import "NSMutableDictionary+NumbersStoring.h"

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
    
    NSMutableDictionary* userData = [UsersModel sharedInstance].logedUserData;
    [userData setInteger:todayCompleted forKey:@"todayCompleted"];
    [userData setInteger:todayPoints forKey:@"todayPoints"];
    [userData setInteger:thisWeekCompleted forKey:@"thisWeekCompleted"];
    [userData setInteger:thisWeekPoints forKey:@"thisWeekPoints"];
    [userData setInteger:thisMonthCompleted forKey:@"thisMonthCompleted"];
    [userData setInteger:thisMonthPoints forKey:@"thisMonthPoints"];
    [userData setInteger:totalCompleted forKey:@"totalCompleted"];
    [userData setInteger:totalPoints forKey:@"totalPoints"];
    
    
    
    NSDate* lastCompleteTaskDay = [userData objectForKey:@"lastCompleteTaskDay"];
    
    //AWARD
    if ([today timeIntervalSinceDate:lastCompleteTaskDay] != 0 ) {
        if ([today timeIntervalSinceDate:lastCompleteTaskDay] == ONE_DAY) {
            consecutiveDays ++;
            if (consecutiveDays > bestConsecutiveDays) {
                bestConsecutiveDays = consecutiveDays;
                [userData setInteger:bestConsecutiveDays forKey:@"bestConsecutiveDays"];
                
                NSDictionary* dic = @{@"amount":[NSNumber numberWithInteger:bestConsecutiveDays],
                                      @"type":[NSNumber numberWithInteger:ConsecutiveDaysAward],
                                      @"day":[NSDate midnightToday]};
                
                [self addAward:dic];
                
            }
        } else {
            consecutiveDays = 0;
        }
        
        [userData setInteger:consecutiveDays forKey:@"consecutiveDays"];
        [userData setObject:today forKey:@"lastCompleteTaskDay"];
        
    }
    
    //AWARD
    if (([[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_GOAL_KEY] != 0) && (totalPoints >= [[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_GOAL_KEY])) {
        NSDictionary* dic = @{@"amount":[NSNumber numberWithInteger:[[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_GOAL_KEY]],
                              @"type":[NSNumber numberWithInteger:UserGoalAward],
                              @"day":[NSDate date]};
        [self addAward:dic];
    }
    
    [[UsersModel sharedInstance] saveCurrentUserData];
    
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
    
    NSMutableDictionary* userData = [UsersModel sharedInstance].logedUserData;
    [userData setInteger:todayCompleted forKey:@"todayCompleted"];
    [userData setInteger:todayPoints forKey:@"todayPoints"];
    [userData setInteger:yesterdayCompleted forKey:@"yesterdayCompleted"];
    [userData setInteger:yesterdayPoints forKey:@"yesterdayPoints"];
    [userData setInteger:thisWeekCompleted forKey:@"thisWeekCompleted"];
    [userData setInteger:thisWeekPoints forKey:@"thisWeekPoints"];
    [userData setInteger:lastWeekCompleted forKey:@"lastWeekCompleted"];
    [userData setInteger:lastWeekPoints forKey:@"lastWeekPoints"];
    [userData setInteger:totalCompleted forKey:@"totalCompleted"];
    [userData setInteger:totalPoints forKey:@"totalPoints"];
    
    [userData setInteger:todayMissed forKey:@"todayMissed"];
    [userData setInteger:yesterdayMissed forKey:@"yesterdayMissed"];
    [userData setInteger:thisWeekMissed forKey:@"thisWeekMissed"];
    [userData setInteger:lastWeekMissed forKey:@"lastWeekMissed"];
    [userData setInteger:totalMissed forKey:@"totalMissed"];
    
    [[UsersModel sharedInstance] saveCurrentUserData];
    
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
        NSMutableDictionary* userData = [UsersModel sharedInstance].logedUserData;
        [userData setInteger:todayMissed forKey:@"todayMissed"];
        [userData setInteger:yesterdayMissed forKey:@"yesterdayMissed"];
        [userData setInteger:thisWeekMissed forKey:@"thisWeekMissed"];
        [userData setInteger:lastWeekMissed forKey:@"lastWeekMissed"];
        [userData setInteger:thisMonthMissed forKey:@"thisMonthMissed"];
        [userData setInteger:totalMissed forKey:@"totalMissed"];
        
        [[UsersModel sharedInstance] saveCurrentUserData];
    }
}

- (void) loadData {
    NSMutableDictionary* userData = [UsersModel sharedInstance].logedUserData;
    
    today = [userData objectForKey:@"storedToday"];
    
    todayCompleted = [userData integerForKey:@"todayCompleted"];
    todayMissed = [userData integerForKey:@"todayMissed"];
    todayPoints = [userData integerForKey:@"todayPoints"];
    
    yesterdayCompleted = [userData integerForKey:@"yesterdayCompleted"];
    yesterdayMissed = [userData integerForKey:@"yesterdayMissed"];
    yesterdayPoints = [userData integerForKey:@"yesterdayPoints"];
    
    thisWeekCompleted = [userData integerForKey:@"thisWeekCompleted"];
    thisWeekMissed = [userData integerForKey:@"thisWeekMissed"];
    thisWeekPoints = [userData integerForKey:@"thisWeekPoints"];
    
    lastWeekCompleted = [userData integerForKey:@"lastWeekCompleted"];
    lastWeekMissed = [userData integerForKey:@"lastWeekMissed"];
    lastWeekPoints = [userData integerForKey:@"lastWeekPoints"];
    
    thisMonthCompleted = [userData integerForKey:@"thisMonthCompleted"];
    thisMonthMissed = [userData integerForKey:@"thisMonthMissed"];
    thisMonthPoints = [userData integerForKey:@"thisMonthPoints"];
    
    totalCompleted = [userData integerForKey:@"totalCompleted"];
    totalMissed = [userData integerForKey:@"totalMissed"];
    totalPoints = [userData integerForKey:@"totalPoints"];
    
    
    bestDailyCompletedTasksAmount = [userData floatForKey:@"bestDaily"];
    bestWeeklyCompletedTasksAmount = [userData floatForKey:@"bestWeekly"];
    bestMontlyCompletedTaskAmount = [userData floatForKey:@"bestMontly"];
    
    awards = [userData objectForKey:@"AwardsArray"];
    [[UsersModel sharedInstance] saveCurrentUserData];
}

- (void) evaluateDay {
    if (today && ([today timeIntervalSinceDate:[NSDate midnightToday]] != 0)) {
        
        NSMutableDictionary* userData = [UsersModel sharedInstance].logedUserData;
        
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
            [userData setFloat:todayCompleted forKey:@"bestDaily"];
            
            
            
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
                [userData setFloat:bestWeeklyCompletedTasksAmount forKey:@"bestDaily"];
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
                
                
                [userData setFloat:bestMontlyCompletedTaskAmount forKey:@"bestMontly"];
            }
            thisMonthPoints = thisMonthCompleted = thisMonthMissed = 0;
        }
        
        today = [NSDate midnightToday];
    
        
        [userData setObject:today forKey:@"storedToday"];
        
        [userData setInteger:todayCompleted forKey:@"todayCompleted"];
        [userData setInteger:todayMissed forKey:@"todayMissed"];
        [userData setInteger:todayPoints forKey:@"todayPoints"];
        
        [userData setInteger:yesterdayCompleted forKey:@"yesterdayCompleted"];
        [userData setInteger:yesterdayMissed forKey:@"yesterdayMissed"];
        [userData setInteger:yesterdayPoints forKey:@"yesterdayPoints"];
        
        [userData setInteger:thisWeekCompleted forKey:@"thisWeekCompleted"];
        [userData setInteger:thisWeekPoints forKey:@"thisWeekPoints"];
        [userData setInteger:thisWeekMissed forKey:@"thisWeekMissed"];
        
        [userData setInteger:lastWeekCompleted forKey:@"lastWeekCompleted"];
        [userData setInteger:lastWeekMissed forKey:@"lastWeekMissed"];
        [userData setInteger:lastWeekPoints forKey:@"lastWeekPoints"];
        
        [userData setInteger:thisMonthCompleted forKey:@"thisMonthCompleted"];
        [userData setInteger:thisMonthMissed forKey:@"thisMonthMissed"];
        [userData setInteger:thisMonthPoints forKey:@"thisMonthPoints"];
        
        [userData setInteger:totalCompleted forKey:@"totalCompleted"];
        [userData setInteger:totalMissed forKey:@"totalMissed"];
        [userData setInteger:totalPoints forKey:@"totalPoints"];
        
    } else if (!today) {
        today = [NSDate midnightToday];
        [[UsersModel sharedInstance].logedUserData setObject:today forKey:@"storedToday"];
    }
    
    [[UsersModel sharedInstance] saveCurrentUserData];
    
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
    [[UsersModel sharedInstance].logedUserData setObject:awards forKey:@"AwardsArray"];
}

- (void) addUserGoal:(NSDictionary*)awardDic {
    BOOL alreadySuppered = NO;
    
    for (NSDictionary* award in awards) {
        if (([[award objectForKey:@"type"] integerValue] == UserGoalAward) &&
            ([[award objectForKey:@"amount"] integerValue] == [[awardDic objectForKey:@"amount"] integerValue])){
            alreadySuppered = YES;
            break;
        }
    }
    
    if (!alreadySuppered) {
        [self addAward:awardDic];
    }

}

@end
