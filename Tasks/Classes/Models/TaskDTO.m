//
//  TaskModel.m
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "TaskDTO.h"
#import "NSDate+Reporting.h"
#import "CacheFileManager.h"
#import "TaskListModel.h"
#import <MediaPlayer/MediaPlayer.h>

#define DEFAULT_TIME_FOR_TASK 604800 //one week

@interface TaskDTO () {
    UIImage* thumb;
}

@end

@implementation TaskDTO

@synthesize title, currentRepetition, repeatTimes, repeatPeriod, taskPoints;
@synthesize detailsText;
@synthesize notes, status, rating;
@synthesize creationDate, showingDate, dueDate, completitionDate;
@synthesize timesDoneIt, timesMissedIt;


- (id) init {
    if (self = [super init]) {
        self.title = @"";
        self.currentRepetition = 1;
        self.repeatTimes = 2;
        self.repeatPeriod = Weekly;
        self.taskPoints = 5;
        self.status = 0;
        self.rating = 0;
        self.dueDate = [NSDate dateWithTimeInterval:DEFAULT_TIME_FOR_TASK sinceDate:[NSDate midnightToday]];
        self.creationDate = [NSDate date];
        self.showingDate = [NSDate midnightToday];
        self.thumbImage = nil;
        self.videoUrl = nil;
        self.detailsText = nil;
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
    newTask.thumbImagePath = self.thumbImagePath;
    newTask.videoUrl = self.videoUrl;
    newTask.detailsText = self.detailsText;
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
    newTask.detailsText = self.detailsText;

    
    
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
    if (self.thumbImagePath)
        [dic setObject:self.thumbImagePath forKey:@"imagePath"];
    if (self.videoUrl)
        [dic setObject:self.videoUrl forKey:@"videoUrl"];
    
    if (self.detailsText) {
        NSData *detailsData = [NSKeyedArchiver archivedDataWithRootObject:self.detailsText];
        [dic setObject:detailsData forKey:@"detailsWithLinks"];
    }

    
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
    NSData* tempData;
    
    tempString = [dicctionary objectForKey:@"title"];
    if (tempString)
        dto.title = tempString;
    else
        dto.title = @"";
    
    dto.currentRepetition = [[dicctionary objectForKey:@"currentRepetition"] integerValue];
    dto.repeatTimes = [[dicctionary objectForKey:@"repeatTimes"] integerValue];
    dto.repeatPeriod = [[dicctionary objectForKey:@"repeatPeriod"] intValue];
    dto.taskPoints = [[dicctionary objectForKey:@"priorityPoints"] integerValue];
    
    tempString = [dicctionary objectForKey:@"imagePath"];
    if (tempString)
        dto.thumbImagePath = tempString;
    else
        dto.thumbImagePath = nil;
    
    tempString = [dicctionary objectForKey:@"videoUrl"];
    if (tempString)
        dto.videoUrl = tempString;
    else
        dto.videoUrl = nil;

    
    
    tempData = [dicctionary objectForKey:@"detailsWithLinks"];
    if (tempData)
        dto.detailsText = [NSKeyedUnarchiver unarchiveObjectWithData:tempData];
    
    
    
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


-(NSString*) forceVideoUrl {
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




- (UIImage*) thumbImage {
    if (thumb)
        return thumb;
    
    thumb = [CacheFileManager getImageFromPath:self.thumbImagePath];
    
    return thumb;
}

- (void) setThumbImage:(UIImage *)thumbImage {
    
    NSString* oldPath = self.thumbImagePath;
    thumb = thumbImage;
    if (thumbImage)
        self.thumbImagePath = [CacheFileManager storeImage:thumbImage];
    else
        self.thumbImagePath = nil;
    
    if (oldPath && ![@"" isEqualToString:oldPath])
        [[TaskListModel sharedInstance] checkIfImagePathIsStillInUse:oldPath];
}

- (void) addVideoFromUrl:(NSURL *)url {
    //get thumbnail image
    UIImage* thumbImage;
    
    MPMoviePlayerController *theMovie = [[MPMoviePlayerController alloc] initWithContentURL:url];
    theMovie.view.frame = [UIScreen mainScreen].bounds;
    theMovie.controlStyle = MPMovieControlStyleNone;
    theMovie.shouldAutoplay=NO;
    thumbImage = [theMovie thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionExact];
    
    
    //save video to app's directory.
    NSData *videoData = [NSData dataWithContentsOfURL:url];
    [[NSFileManager defaultManager] createFileAtPath:[self forceVideoUrl] contents:videoData attributes:nil];
    [self setThumbImage:thumbImage];
}

- (void) setVideoUrl:(NSString *)videoUrl {
    NSString* oldPath = self.videoUrl;
    _videoUrl = videoUrl;
    if (oldPath && ![@"" isEqualToString:oldPath])
        [[TaskListModel sharedInstance] checkIfVideoPathIsStillInUse:oldPath];
    
}

- (NSString*) repeatTimesDisplayText {
    NSString* displayText = [NSString stringWithFormat:@"%ld",(long)self.repeatTimes];
    if (self.repeatTimes == 1)
        displayText = [displayText stringByAppendingString:@" time "];
    else
        displayText = [displayText stringByAppendingString:@" times "];
        
        
    switch (self.repeatPeriod) {
        case Weekly:
            displayText = [displayText stringByAppendingString:@" per week"];
            break;
        case Fortnightly:
            displayText = [displayText stringByAppendingString:@" per fortnight"];
            break;
        case Monthly:
            displayText = [displayText stringByAppendingString:@" per month"];
            break;
        case Quarterly:
            displayText = [displayText stringByAppendingString:@" per quarter"];
            break;
        case Yearly:
            displayText = [displayText stringByAppendingString:@" per year"];
            break;
    }
    
    return displayText;
}


- (UIImage*) getHitRateImage {
    return [TaskDTO getImageForHitRate:[self hitRate]];
    
    
    
}

+ (UIImage*) getImageForHitRate: (double) hitRate {
    if (hitRate >= 65) {
        return [UIImage imageNamed:@"face_happy.png"];
    } else if (hitRate >= 45) {
        return [UIImage imageNamed:@"face_indifferent.png"];
    } else if (hitRate >= 15) {
        return [UIImage imageNamed:@"face_perplexed.png"];
    } else {
        return [UIImage imageNamed:@"face_sad.png"];
    }
}


@end
