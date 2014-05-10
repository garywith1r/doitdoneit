//
//  WeeklyReviewViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 5/10/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "WeeklyReviewViewController.h"
#import "NSDate+Reporting.h"
#import "Constants.h"
#import "TaskListModel.h"
#import "UsersModel.h"
#import "WeeklyReviewTableViewCell.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface WeeklyReviewViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate> {
    IBOutlet UIImageView* weekStatsImg;
    IBOutlet UILabel* weekLbl;
    IBOutlet UILabel* weekStatsLbl;
    IBOutlet UIButton* nextWeekButton;
    IBOutlet UITableView* table;
    
    NSDate* currentFirstDate;
    
    NSArray* currentWeekArray;
    
    NSInteger currentWeekCompletedTasks;
    NSInteger currentWeekPoints;
    double currentWeekHitRate;
    
}

@end

@implementation WeeklyReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentFirstDate = [NSDate firstDayOfCurrentWeek];
    [self showReviewForWeekStartingOn:currentFirstDate];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self showReviewForWeekStartingOn:currentFirstDate];
}

- (IBAction) prevWeek {
    currentFirstDate = [currentFirstDate dateByAddingTimeInterval:-ONE_DAY*7];
    [self showReviewForWeekStartingOn:currentFirstDate];
}

- (IBAction) newxtWeek {
    currentFirstDate = [currentFirstDate dateByAddingTimeInterval:ONE_DAY*7];
    [self showReviewForWeekStartingOn:currentFirstDate];
}

- (void) showReviewForWeekStartingOn:(NSDate*)date {
    currentWeekArray = [[TaskListModel sharedInstance] getWeeksArrayFrom:date];
    if ([date timeIntervalSinceDate:[NSDate firstDayOfCurrentWeek]] == 0) {
        nextWeekButton.enabled = NO;
        weekLbl.text = @"Weekly Review ● This week";
    } else {
        NSDateFormatter* dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"MMM, dd"];
        weekLbl.text = [NSString stringWithFormat:@"Weekly Review ● %@ - %@",[dateFormater stringFromDate:date],[dateFormater stringFromDate:[date dateByAddingTimeInterval:ONE_DAY*6]]];
        nextWeekButton.enabled = YES;
    }
    
    int cantTasks = 0;
    currentWeekCompletedTasks = 0;
    currentWeekPoints = 0;
    for (NSArray* dayArray in currentWeekArray) {
        for (TaskDTO* task in dayArray) {
            if (task.status == TaskStatusComplete) {
                currentWeekCompletedTasks ++;
                currentWeekPoints += task.taskPoints;
            }
            cantTasks++;
        }
        
    }
    if (cantTasks)
        currentWeekHitRate = currentWeekCompletedTasks  * 100 / (double) cantTasks;
    else
        currentWeekHitRate = 0;
    
    weekStatsImg.image = [TaskDTO getImageForHitRate:currentWeekHitRate];
    weekStatsLbl.text = [NSString stringWithFormat:@"Tasks: %ld  Points: %ld  Hit rate: %.1f%%",(long)currentWeekCompletedTasks, (long)currentWeekPoints, currentWeekHitRate];
    
    [table reloadData];
}

- (IBAction) emailReview {
    NSDateFormatter* dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"MMM, dd"];
    NSString* subject = [NSString stringWithFormat:@"Weekly Review ● %@ - %@",[dateFormater stringFromDate:currentFirstDate],[dateFormater stringFromDate:[currentFirstDate dateByAddingTimeInterval:ONE_DAY*6]]];
    NSString* body = @"";
    for (int x = 0; x < 7; x++) {
        NSArray* dayArray = currentWeekArray[x];
        switch (x) {
            case 0:
                body = [body stringByAppendingString:@"Sunday\n"];
                break;
            case 1:
                body = [body stringByAppendingString:@"Monday\n"];
                break;
            case 2:
                body = [body stringByAppendingString:@"Tuesday\n"];
                break;
            case 3:
                body = [body stringByAppendingString:@"Wednesday\n"];
                break;
            case 4:
                body = [body stringByAppendingString:@"Thursday\n"];
                break;
            case 5:
                body = [body stringByAppendingString:@"Friday\n"];
                break;
            case 6:
                body = [body stringByAppendingString:@"Saturday\n"];
                break;
                
            default:
                break;
        }
        
        for (TaskDTO* task in dayArray) {
            body = [body stringByAppendingString:[NSString stringWithFormat:@"%@ %ld Stars\n",task.title, (long)task.rating]];
            if (task.notes && ![@"" isEqualToString:task.notes]) {
                body = [body stringByAppendingString:[NSString stringWithFormat:@"%@\n",task.notes]];
            }
            body = [body stringByAppendingString:@"\n"];
        }
        
        body = [body stringByAppendingString:@"\n\n"];
    }
    
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    
    picker.mailComposeDelegate = self;
    picker.modalPresentationStyle = UIModalPresentationPageSheet;
    [picker setToRecipients:[[UsersModel sharedInstance].logedUserData objectForKey:LOGGED_USER_RECIPIENTS_LIST]];
    [picker setSubject:subject];
    [picker setMessageBody:body isHTML:NO];
    
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - UITableView Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [currentWeekArray[section] count];
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 280, 21)];
    [label setFont:[UIFont systemFontOfSize:14]];
    label.textColor = YELLOW_COLOR;
    switch (section) {
        case 0:
            label.text = @"Sunday";
            break;
        case 1:
            label.text = @"Monday";
            break;
        case 2:
            label.text = @"Tuesday";
            break;
        case 3:
            label.text = @"Wednesday";
            break;
        case 4:
            label.text = @"Thursday";
            break;
        case 5:
            label.text = @"Friday";
            break;
        case 6:
            label.text = @"Saturday";
            break;
            
        default:
            break;
    }
    
    headerView.backgroundColor = GRAY_COLOR;
    [headerView addSubview:label];
    return headerView;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeeklyReviewTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"WeeklyReviewTableViewCell"];
    TaskDTO* task = currentWeekArray[indexPath.section][indexPath.row];
    cell.taskTitle.text = task.title;
    cell.taskNote.text = task.notes;
    cell.taskStars.text = [NSString stringWithFormat:@"%ld Stars",(long)task.rating];
    
    return cell;
    
}

#pragma mark - MFMailComposeDelegate Method

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed");
            break;
        default:
            NSLog(@"Mail not sent");
            break;
    }
    
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
