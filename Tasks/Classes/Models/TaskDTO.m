//
//  TaskModel.m
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "TaskDTO.h"
#import "NSDate+Reporting.h"

#define DEFAULT_TIME_FOR_TASK 604800 //one week

@implementation TaskDTO

@synthesize title, currentRepetition, repeatTimes, repeatPeriod, priorityPoints;
@synthesize notes, status, rating;
@synthesize creationDate, showingDate, dueDate, completitionDate;
@synthesize timesDoneIt, timesMissedIt;


- (id) init {
    if (self = [super init]) {
        self.currentRepetition = 1;
        self.repeatTimes = 1;
        self.repeatPeriod = 0;
        self.priorityPoints = 5;
        self.status = 0;
        self.rating = 0;
        self.timesDoneIt = 0;
        self.timesMissedIt = 0;
        self.dueDate = [NSDate dateWithTimeInterval:DEFAULT_TIME_FOR_TASK sinceDate:[NSDate midnightToday]];
        self.creationDate = [NSDate date];
        self.showingDate = [NSDate midnightToday];
    }
    return self;
}

- (TaskDTO*) copy {
    TaskDTO* newTask = [[TaskDTO alloc] init];
    
    newTask.title = self.title;
    newTask.currentRepetition = self.currentRepetition;
    newTask.repeatTimes = self.repeatTimes;
    newTask.repeatPeriod = self.repeatPeriod;
    newTask.priorityPoints = self.priorityPoints;
    newTask.creationDate = self.creationDate;
    newTask.showingDate = self.showingDate;
    newTask.dueDate = self.dueDate;
    newTask.completitionDate = self.completitionDate;
    newTask.timesDoneIt = self.timesDoneIt;
    newTask.timesMissedIt = self.timesMissedIt;
    
    return newTask;
}

- (TaskDTO*) taskWithData {
    TaskDTO* newTask = [[TaskDTO alloc] init];
    
    newTask.title = self.title;
    newTask.repeatTimes = self.repeatTimes;
    newTask.repeatPeriod = self.repeatPeriod;
    newTask.priorityPoints = self.priorityPoints;
    
    return newTask;
}

- (NSDictionary*) convertToDictionary {
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:8];
    if (self.title)
        [dic setObject:self.title forKey:@"title"];
    
    [dic setObject:[NSString stringWithFormat:@"%d",self.currentRepetition] forKey:@"currentRepetition"];
    [dic setObject:[NSString stringWithFormat:@"%d",self.repeatTimes] forKey:@"repeatTimes"];
    [dic setObject:[NSString stringWithFormat:@"%d",self.repeatPeriod] forKey:@"repeatPeriod"];
    [dic setObject:[NSString stringWithFormat:@"%d",self.priorityPoints] forKey:@"priorityPoints"];

    
    if (self.notes)
        [dic setObject:self.notes forKey:@"notes"];
    [dic setObject:[NSString stringWithFormat:@"%d",self.status] forKey:@"status"];
    [dic setObject:[NSString stringWithFormat:@"%d",self.rating] forKey:@"rating"];

    
    
    [dic setObject:self.creationDate forKey:@"creationDate"];
    [dic setObject:self.showingDate forKey:@"showingDate"];
    [dic setObject:self.dueDate forKey:@"dueDate"];
    if (self.completitionDate)
        [dic setObject:self.completitionDate forKey:@"completitionDate"];
    
    [dic setObject:[NSString stringWithFormat:@"%d",self.timesDoneIt] forKey:@"timesDoneIt"];
    [dic setObject:[NSString stringWithFormat:@"%d",self.timesMissedIt] forKey:@"timesMissedIt"];
    
    return [NSDictionary dictionaryWithDictionary:dic];
}

+ (TaskDTO*) taskDtoFromDictionary:(NSDictionary*)dicctionary {
    TaskDTO* dto = [[TaskDTO alloc] init];

    dto.title = [dicctionary objectForKey:@"title"];
    dto.currentRepetition = [[dicctionary objectForKey:@"currentRepetition"] integerValue];
    dto.repeatTimes = [[dicctionary objectForKey:@"repeatTimes"] integerValue];
    dto.repeatPeriod = [[dicctionary objectForKey:@"repeatPeriod"] integerValue];
    dto.priorityPoints = [[dicctionary objectForKey:@"priorityPoints"] integerValue];
    
    dto.notes = [dicctionary objectForKey:@"notes"];
    dto.status = [[dicctionary objectForKey:@"status"] integerValue];
    dto.rating = [[dicctionary objectForKey:@"rating"] integerValue];
    
    dto.creationDate = [dicctionary objectForKey:@"creationDate"];
    dto.showingDate = [dicctionary objectForKey:@"showingDate"];
    dto.dueDate = [dicctionary objectForKey:@"dueDate"];
    dto.completitionDate = [dicctionary objectForKey:@"completitionDate"];
    
    dto.timesDoneIt = [[dicctionary objectForKey:@"timesDoneIt"] integerValue];
    dto.timesMissedIt = [[dicctionary objectForKey:@"timesMissedIt"] integerValue];
    
    return dto;
}

- (double) hitRate {
    return self.timesDoneIt / (float) (self.timesDoneIt + self.timesMissedIt) * 100;
}

@end
