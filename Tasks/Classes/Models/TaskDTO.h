//
//  TaskModel.h
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATE_FORMAT @"EEE, d MMMM"

enum TaskStatus {
    TaskStatusIncomplete = 0,
    TaskStatusComplete,
    TaskStatusMissed
};

enum TaskRepeatPeriod {
    Weekly = 0,
    Fortnightly,
    Monthly,
    Quarterly,
    Yearly
};

@interface TaskDTO : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic) NSInteger currentRepetition;
@property (nonatomic) NSInteger repeatTimes;
@property (nonatomic) enum TaskRepeatPeriod repeatPeriod;
@property (nonatomic) NSInteger taskPoints;
@property (nonatomic, strong) NSString* thumbImagePath;
@property (nonatomic, strong) UIImage* thumbImage;
@property (nonatomic, strong) NSString* videoUrl;

@property (nonatomic, strong) NSAttributedString* detailsText;
@property (nonatomic, strong) NSArray* detailsLinksArray;

@property (nonatomic, strong) NSString* notes;
@property (nonatomic) enum TaskStatus status;
@property (nonatomic) NSInteger rating;

@property (nonatomic, strong) NSDate* creationDate;
@property (nonatomic, strong) NSDate* showingDate;
@property (nonatomic, strong) NSDate* dueDate;
@property (nonatomic, strong) NSDate* completitionDate;

@property (nonatomic, strong) NSMutableArray* timesDoneIt;
@property (nonatomic, strong) NSMutableArray* timesMissedIt;

+ (TaskDTO*) taskDtoFromDictionary:(NSDictionary*)diccionary;
- (TaskDTO*) taskWithData;
- (NSDictionary*) convertToDictionary;

- (NSString*) forceVideoUrl;

- (void) incrementDoneItBy:(int)increment;
- (void) incrementMissedItBy:(int)increment;
- (double) hitRate;
- (UIImage*) getHitRateImage;


- (NSString*) repeatTimesDisplayText;
@end
