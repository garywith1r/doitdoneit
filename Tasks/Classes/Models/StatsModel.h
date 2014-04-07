//
//  StatsModel.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 2/27/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskDTO.h"

enum AwardType {
    ConsecutiveDaysAward = 0,
    HighestHitRateAward,
    HighestDailyPointsAward,
    HighestWeeklyPointsAward,
    HighestMonthlyPointsAward
};

@interface StatsModel : NSObject

@property (nonatomic, readonly) NSInteger todayCompleted;
@property (nonatomic, readonly) NSInteger todayMissed;
@property (nonatomic, readonly) NSInteger todayPoints;

@property (nonatomic, readonly) NSInteger yesterdayCompleted;
@property (nonatomic, readonly) NSInteger yesterdayMissed;
@property (nonatomic, readonly) NSInteger yesterdayPoints;

@property (nonatomic, readonly) NSInteger thisWeekCompleted;
@property (nonatomic, readonly) NSInteger thisWeekMissed;
@property (nonatomic, readonly) NSInteger thisWeekPoints;

@property (nonatomic, readonly) NSInteger lastWeekCompleted;
@property (nonatomic, readonly) NSInteger lastWeekMissed;
@property (nonatomic, readonly) NSInteger lastWeekPoints;

@property (nonatomic, readonly) NSInteger thisMonthCompleted;
@property (nonatomic, readonly) NSInteger thisMonthMissed;
@property (nonatomic, readonly) NSInteger thisMonthPoints;

@property (nonatomic, readonly) NSInteger totalCompleted;
@property (nonatomic, readonly) NSInteger totalMissed;
@property (nonatomic, readonly) NSInteger totalPoints;

@property (nonatomic, readonly) CGFloat todayHitRate;
@property (nonatomic, readonly) CGFloat yesterdayHitRate;
@property (nonatomic, readonly) CGFloat thisWeekHitRate;
@property (nonatomic, readonly) CGFloat lastWeekHitRate;
@property (nonatomic, readonly) CGFloat totalHitRate;

@property (nonatomic, readonly) NSInteger consecutiveDays;
@property (nonatomic, readonly) NSInteger bestConsecutiveDays;
@property (nonatomic, strong) NSArray* awards;

+ (StatsModel*) sharedInstance;

- (void) contabilizeCompletedTask:(TaskDTO*) task;
- (void) contabilizeMissedTask:(TaskDTO*) task;
- (void) contabilizeDeletedTask:(TaskDTO*) task;

- (void) recalculateVolatileStats;



@end
