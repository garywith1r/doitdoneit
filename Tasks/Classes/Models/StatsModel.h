//
//  StatsModel.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 2/27/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskDTO.h"

@interface StatsModel : NSObject

@property (nonatomic, readonly) int todayCompleted;
@property (nonatomic, readonly) int todayMissed;
@property (nonatomic, readonly) int todayPoints;

@property (nonatomic, readonly) int yesterdayCompleted;
@property (nonatomic, readonly) int yesterdayMissed;
@property (nonatomic, readonly) int yesterdayPoints;

@property (nonatomic, readonly) int thisWeekCompleted;
@property (nonatomic, readonly) int thisWeekMissed;
@property (nonatomic, readonly) int thisWeekPoints;

@property (nonatomic, readonly) int lastWeekCompleted;
@property (nonatomic, readonly) int lastWeekMissed;
@property (nonatomic, readonly) int lastWeekPoints;

@property (nonatomic, readonly) int totalCompleted;
@property (nonatomic, readonly) int totalMissed;
@property (nonatomic, readonly) int totalPoints;

@property (nonatomic, readonly) float todayHitRate;
@property (nonatomic, readonly) float yesterdayHitRate;
@property (nonatomic, readonly) float thisWeekHitRate;
@property (nonatomic, readonly) float lastWeekHitRate;
@property (nonatomic, readonly) float totalHitRate;

+ (StatsModel*) sharedInstance;

- (void) contabilizeCompletedTask:(TaskDTO*) task;
- (void) contabilizeMissedTask:(TaskDTO*) task;
- (void) contabilizeDeletedTask:(TaskDTO*) task;

- (void) recalculateVolatileStats;



@end
