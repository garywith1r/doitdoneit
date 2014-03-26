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

@synthesize title, currentRepetition, repeatTimes, repeatPeriod, taskPoints, description;
@synthesize notes, status, rating;
@synthesize creationDate, showingDate, dueDate, completitionDate;
@synthesize timesDoneIt, timesMissedIt;


- (id) init {
    if (self = [super init]) {
        self.currentRepetition = 1;
        self.repeatTimes = 1;
        self.repeatPeriod = 0;
        self.taskPoints = 1;
        self.status = 0;
        self.rating = 0;
        self.dueDate = [NSDate dateWithTimeInterval:DEFAULT_TIME_FOR_TASK sinceDate:[NSDate midnightToday]];
        self.creationDate = [NSDate date];
        self.showingDate = [NSDate midnightToday];
        self.thumbImage = nil;
        self.videoUrl = nil;
        self.description = nil;
    }
    return self;
}

- (TaskDTO*) copy {
    TaskDTO* newTask = [[TaskDTO alloc] init];
    
    newTask.title = self.title;
    newTask.currentRepetition = self.currentRepetition;
    newTask.repeatTimes = self.repeatTimes;
    newTask.repeatPeriod = self.repeatPeriod;
    newTask.taskPoints = self.taskPoints;
    newTask.thumbImage = self.thumbImage;
    newTask.videoUrl = self.videoUrl;
    newTask.description = self.description;
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
    newTask.taskPoints = self.taskPoints;
    newTask.thumbImage = self.thumbImage;
    newTask.description = self.description;
    
    if (self.videoUrl) {
        //save video to app's directory.
        NSData *videoData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoUrl isDirectory:NO]];
        [[NSFileManager defaultManager] createFileAtPath:newTask.videoUrl contents:videoData attributes:nil];
    }
    
    return newTask;
}

- (void) setRepeatTimes:(NSInteger)_repeatTimes {
    repeatTimes = _repeatTimes;
    if (_repeatTimes <= 0) {
        self.timesDoneIt = self.timesMissedIt = nil;
        return;
    }
    
    
    NSMutableArray* tempHits = [NSMutableArray arrayWithCapacity:_repeatTimes];
    int x = 0;
    
    for (; x < self.timesDoneIt.count; x++) {
        [tempHits setObject:self.timesDoneIt[x] atIndexedSubscript:x];
    }
    
    for (; x < _repeatTimes; x++) {
        [tempHits setObject:[NSNumber numberWithInt:0] atIndexedSubscript:x];
    }
    
    self.timesDoneIt = tempHits;
    tempHits = nil;
    
    NSMutableArray* tempMiss = [NSMutableArray arrayWithCapacity:_repeatTimes];
    x = 0;
    
    for (; x < self.timesMissedIt.count; x++) {
        [tempMiss setObject:self.timesMissedIt[x] atIndexedSubscript:x];
    }
    
    for (; x < _repeatTimes; x++) {
        [tempMiss setObject:[NSNumber numberWithInt:0] atIndexedSubscript:x];
    }
    
    self.timesMissedIt = tempMiss;
    tempMiss = nil;
}

- (void) incrementDoneItBy:(int)increment {
    int doneIt = [self.timesDoneIt[self.currentRepetition - 1] intValue] + increment;
    [self.timesDoneIt replaceObjectAtIndex:(self.currentRepetition -1) withObject:[NSNumber numberWithInt:doneIt]];
}

- (void) incrementMissedItBy:(int)increment {
    int missed = [self.timesMissedIt[self.currentRepetition - 1] intValue] + increment;
    [self.timesMissedIt replaceObjectAtIndex:(self.currentRepetition -1) withObject:[NSNumber numberWithInt:missed]];
}

- (double) hitRate {
    float doneIt = [self.timesDoneIt[self.currentRepetition - 1] floatValue];
    float missedIt = [self.timesMissedIt[self.currentRepetition - 1] floatValue];
    
    if (doneIt + missedIt)
        return doneIt / (doneIt + missedIt) * 100;
    
    return 0;
}


#pragma mark - Storage Methods
- (NSDictionary*) convertToDictionary {
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:8];
    if (self.title)
        [dic setObject:self.title forKey:@"title"];
    
    [dic setObject:[NSString stringWithFormat:@"%d",(int)self.currentRepetition] forKey:@"currentRepetition"];
    [dic setObject:[NSString stringWithFormat:@"%d",(int)self.repeatTimes] forKey:@"repeatTimes"];
    [dic setObject:[NSString stringWithFormat:@"%d",(int)self.repeatPeriod] forKey:@"repeatPeriod"];
    [dic setObject:[NSString stringWithFormat:@"%d",(int)self.taskPoints] forKey:@"priorityPoints"];
    
    if (self.thumbImage)
        [dic setObject:UIImagePNGRepresentation(self.thumbImage) forKey:@"thumb"];
    if (self.videoUrl)
        [dic setObject:self.videoUrl forKey:@"videoUrl"];

    
    if (self.notes)
        [dic setObject:self.notes forKey:@"notes"];
    [dic setObject:[NSString stringWithFormat:@"%d",(int)self.status] forKey:@"status"];
    [dic setObject:[NSString stringWithFormat:@"%d",(int)self.rating] forKey:@"rating"];

    
    
    [dic setObject:self.creationDate forKey:@"creationDate"];
    [dic setObject:self.showingDate forKey:@"showingDate"];
    [dic setObject:self.dueDate forKey:@"dueDate"];
    if (self.completitionDate)
        [dic setObject:self.completitionDate forKey:@"completitionDate"];
    
    [dic setObject:[NSArray arrayWithArray:self.timesDoneIt] forKey:@"timesDoneIt"];
    [dic setObject:[NSArray arrayWithArray:self.timesMissedIt] forKey:@"timesMissedIt"];
    
    return [NSDictionary dictionaryWithDictionary:dic];
}

+ (TaskDTO*) taskDtoFromDictionary:(NSDictionary*)dicctionary {
    TaskDTO* dto = [[TaskDTO alloc] init];
    
    NSString* tempString;
    NSData* tempImage;
    
    tempString = [dicctionary objectForKey:@"title"];
    if (tempString)
        dto.title = tempString;
    else
        dto.title = @"";
    
    dto.currentRepetition = [[dicctionary objectForKey:@"currentRepetition"] integerValue];
    dto.repeatTimes = [[dicctionary objectForKey:@"repeatTimes"] integerValue];
    dto.repeatPeriod = [[dicctionary objectForKey:@"repeatPeriod"] intValue];
    dto.taskPoints = [[dicctionary objectForKey:@"priorityPoints"] integerValue];
    
    tempImage = [dicctionary objectForKey:@"thumb"];
    if (tempString)
        dto.thumbImage = [UIImage imageWithData:tempImage];
    else
        dto.thumbImage = nil;
    
    tempString = [dicctionary objectForKey:@"videoUrl"];
    if (tempString)
        dto.videoUrl = tempString;
    else
        dto.videoUrl = nil;
    
    
    
    dto.notes = [dicctionary objectForKey:@"notes"];
    dto.status = [[dicctionary objectForKey:@"status"] intValue];
    dto.rating = [[dicctionary objectForKey:@"rating"] integerValue];
    
    dto.creationDate = [dicctionary objectForKey:@"creationDate"];
    dto.showingDate = [dicctionary objectForKey:@"showingDate"];
    dto.dueDate = [dicctionary objectForKey:@"dueDate"];
    dto.completitionDate = [dicctionary objectForKey:@"completitionDate"];
    
    dto.timesDoneIt = [NSMutableArray arrayWithArray:[dicctionary objectForKey:@"timesDoneIt"] ];
    dto.timesMissedIt = [NSMutableArray arrayWithArray:[dicctionary objectForKey:@"timesMissedIt"]];
    
    return dto;
}


- (NSString*) videoUrl {
    if (_videoUrl)
        return _videoUrl;
    
    NSString* filePath = @"";
    
    do {
        NSString* completeFileName = [NSString stringWithFormat:@"%u.MOV",arc4random()];
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:completeFileName];
    } while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    
    self.videoUrl = filePath;
    return filePath;
}



@end
