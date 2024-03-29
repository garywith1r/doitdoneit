//
// NSDate+Reporting.m
//
// Created by Mel Sampat on 5/11/12.
// Copyright (c) 2012 Mel Sampat.


// MIT LICENSE:

// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
// THE SOFTWARE.

#import "NSDate+Reporting.h"

// Private Helper functions
@interface NSDate (Private)
+ (void)zeroOutTimeComponents:(NSDateComponents **)components;
+ (NSDate *)firstDayOfQuarterFromDate:(NSDate *)date;
@end

@implementation NSDate (Reporting)

+ (NSDate *)dateWithYear:(int)year month:(int)month day:(int)day {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    // Assign the year, month and day components.
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];    

    // Zero out the hour, minute and second components.    
    [self zeroOutTimeComponents:&components];
    
    // Generate a valid NSDate and return it.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    return [gregorianCalendar dateFromComponents:components];    
}

+ (NSDate *)midnightOfDate:(NSDate *)date {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Start out by getting just the year, month and day components of the specified date.
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
                                                        fromDate:date];
    // Zero out the hour, minute and second components.
    [self zeroOutTimeComponents:&components];
    
    // Convert the components back into a date and return it.
    return [gregorianCalendar dateFromComponents:components];
}

+ (NSDate *)midnightToday {
    return [self midnightOfDate:[NSDate date]];
}

+ (NSDate *)midnightTomorrow {
    NSDate *midnightToday = [self midnightToday];
    return [self oneDayAfter:midnightToday];
}

+ (NSDate *)midnightYesterday {
    NSDate *midnightToday = [self midnightToday];
    return [self oneDayBefore:midnightToday];
}

+ (NSDate *)oneDayAfter:(NSDate *)date {
	NSDateComponents *oneDayComponent = [[NSDateComponents alloc] init];
	[oneDayComponent setDay:1];
    
	NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	return [gregorianCalendar dateByAddingComponents:oneDayComponent
                                              toDate:date 
                                             options:0];
}

+ (NSDate *)oneDayBefore:(NSDate *)date {
    NSDateComponents *oneDayComponent = [[NSDateComponents alloc] init];
	[oneDayComponent setDay:-1];
    
	NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	return [gregorianCalendar dateByAddingComponents:oneDayComponent
                                              toDate:date
                                             options:0];
}

+ (NSDate* )firstDayOfWeekFromDate:(NSDate*)date {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components =
    [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:date];
    NSInteger day = [components day];
    NSInteger weekday = [components weekday];
    
    [components setDay:(day - weekday + 1)];
    
    return [gregorian dateFromComponents:components];
}

+ (NSDate*) firstDayOfCurrentWeek {
    return [self firstDayOfWeekFromDate:[NSDate date]];
}

+ (NSDate*) firstDayOfLastWeek {
    NSDate* date = [self firstDayOfCurrentWeek];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components =
    [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit) fromDate:date];
    NSInteger day = [components day];
    
    [components setDay:(day - 7)];
    
    return [gregorian dateFromComponents:components];
}

+ (NSDate*) firstDayOfNextWeek {
    NSDate* date = [self firstDayOfCurrentWeek];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components =
    [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit) fromDate:date];
    NSInteger day = [components day];
    
    [components setDay:(day + 7)];
    
    return [gregorian dateFromComponents:components];
}

+ (NSDate *)firstDayOfCurrentMonth {
    return [self firstDayOfMonthFromDay:[NSDate date]];
}

+ (NSDate *)firstDayOfMonthFromDay:(NSDate *)currentDate {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Start out by getting just the year, month and day components of the current date.    
    
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
                                                        fromDate:currentDate];
    
    // Change the Day component to 1 (for the first day of the month), and zero out the time components.
    [components setDay:1];
    [self zeroOutTimeComponents:&components];
    
    return [gregorianCalendar dateFromComponents:components];
}

+ (NSDate *)firstDayOfPreviousMonth {
    // Set up a "minus one month" component.
    NSDateComponents *minusOneMonthComponent = [[NSDateComponents alloc] init];
	[minusOneMonthComponent setMonth:-1];
    
    // Subtract 1 month from today's date. This gives us "one month ago today".
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDate *oneMonthAgoToday = [gregorianCalendar dateByAddingComponents:minusOneMonthComponent
                                                                  toDate:currentDate
                                                                 options:0];
    
    // Now extract the year, month and day components of oneMonthAgoToday.
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit 
                                                        fromDate:oneMonthAgoToday];    
    
    // Change the day to 1 (since we want the first day of the previous month).
    [components setDay:1];
    
    // Zero out the time components so we get midnight.
    [self zeroOutTimeComponents:&components];
    
    // Finally, create a new NSDate from components and return it.
    return [gregorianCalendar dateFromComponents:components];    
}

+ (NSDate *)firstDayOfNextMonth {
    NSDate *firstDayOfCurrentMonth = [self firstDayOfCurrentMonth];
    return [self firstDayOfNextMonthFromDay:firstDayOfCurrentMonth];
}

+ (NSDate *)firstDayOfNextMonthFromDay:(NSDate *)date {
    // Set up a "plus 1 month" component.
    NSDateComponents *plusOneMonthComponent = [[NSDateComponents alloc] init];
	[plusOneMonthComponent setMonth:1];
    
    // Add 1 month to firstDayOfCurrentMonth.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate* nextMonth = [gregorianCalendar dateByAddingComponents:plusOneMonthComponent
                                              toDate:date
                                             options:0];
    
    return [self firstDayOfMonthFromDay:nextMonth];
}

+ (NSDate *)firstDayOfCurrentQuarter {
    return [self firstDayOfQuarterFromDate:[NSDate date]];
}

+ (NSDate *)firstDayOfPreviousQuarter {
    NSDate *firstDayOfCurrentQuarter = [self firstDayOfCurrentQuarter];
    
    // Set up a "minus one day" component.
    NSDateComponents *minusOneDayComponent = [[NSDateComponents alloc] init];
	[minusOneDayComponent setDay:-1];
    
    // Subtract 1 day from firstDayOfCurrentQuarter.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *lastDayOfPreviousQuarter = [gregorianCalendar dateByAddingComponents:minusOneDayComponent
                                                                          toDate:firstDayOfCurrentQuarter
                                                                         options:0];    
    return [self firstDayOfQuarterFromDate:lastDayOfPreviousQuarter];
}

+ (NSDate *)firstDayOfNextQuarter {
    NSDate *firstDayOfCurrentQuarter = [self firstDayOfCurrentQuarter];
    
    // Set up a "plus 3 months" component.
    NSDateComponents *plusThreeMonthsComponent = [[NSDateComponents alloc] init];
	[plusThreeMonthsComponent setMonth:3];
    
    // Add 3 months to firstDayOfCurrentQuarter.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorianCalendar dateByAddingComponents:plusThreeMonthsComponent
                                              toDate:firstDayOfCurrentQuarter
                                             options:0];
}

+ (NSDate *)firstDayOfCurrentYear {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Start out by getting just the year, month and day components of the current date.    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
                                                        fromDate:currentDate];
    
    // Change the Day and Month components to 1 (for the first day of the year), and zero out the time components.
    [components setDay:1];
    [components setMonth:1];
    [self zeroOutTimeComponents:&components];
    
    return [gregorianCalendar dateFromComponents:components];    
}

+ (NSDate *)firstDayOfPreviousYear {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                        fromDate:currentDate];
    [components setDay:1];
    [components setMonth:1];
    [components setYear:components.year - 1];
    
    // Zero out the time components so we get midnight.
    [self zeroOutTimeComponents:&components];
    return [gregorianCalendar dateFromComponents:components];
}

+ (NSDate *)firstDayOfNextYear {
    NSDate *firstDayOfCurrentYear = [self firstDayOfCurrentYear];
    
    // Set up a "plus 1 year" component.
    NSDateComponents *plusOneYearComponent = [[NSDateComponents alloc] init];
	[plusOneYearComponent setYear:1];
    
    // Add 1 year to firstDayOfCurrentYear.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorianCalendar dateByAddingComponents:plusOneYearComponent
                                              toDate:firstDayOfCurrentYear
                                             options:0];
}

#ifdef DEBUG
- (void)logWithComment:(NSString *)comment {
    NSString *output = [NSDateFormatter localizedStringFromDate:self
                                                      dateStyle:NSDateFormatterMediumStyle 
                                                      timeStyle:NSDateFormatterMediumStyle];
    NSLog(@"%@: %@", comment, output);
}
#endif

#pragma mark - Private Helper functions

+ (void)zeroOutTimeComponents:(NSDateComponents **)components {
    [*components setHour:0];
    [*components setMinute:0];
    [*components setSecond:0];
}

+ (NSDate *)firstDayOfQuarterFromDate:(NSDate *)date {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSMonthCalendarUnit | NSYearCalendarUnit
                                                        fromDate:date];
    
    NSInteger quarterNumber = floor((components.month - 1) / 3) + 1;
    // NSLog(@"Quarter number: %d", quarterNumber);
    
    NSInteger firstMonthOfQuarter = (quarterNumber - 1) * 3 + 1;
    [components setMonth:firstMonthOfQuarter];
    [components setDay:1];
    
    // Zero out the time components so we get midnight.    
    [self zeroOutTimeComponents:&components];
    return [gregorianCalendar dateFromComponents:components];    
}


+ (NSString*) timePassedSince:(NSDate*)date {
    
    int timeSince = ceil([[NSDate date] timeIntervalSinceDate:date] /60.0);
    NSString* timeSinceText = @"";
    
    if (timeSince < 2)
        timeSinceText = [timeSinceText stringByAppendingString:@"a few moments ago."];
    
    else if (timeSince < 60)
        timeSinceText = [timeSinceText stringByAppendingString:[NSString stringWithFormat:@"%d mins ago.", timeSince]];
    
    else {
        timeSince = ceil(timeSince / 60.0);
        
        if (timeSince == 1)
            timeSinceText = [timeSinceText stringByAppendingString:@"an hour ago."];
        
        else if (timeSince < 24)
            timeSinceText = [timeSinceText stringByAppendingString:[NSString stringWithFormat:@"%d hours ago.",timeSince]];
        
        else {
            timeSince = ceil(timeSince / 24.0);
            
            if (timeSince == 1)
                timeSinceText = [timeSinceText stringByAppendingString:@"yesterday."];
            
            else
                timeSinceText = [timeSinceText stringByAppendingString:[NSString stringWithFormat:@"%d days ago.",timeSince]];
        }
        
    }
    
    return timeSinceText;
}

@end
