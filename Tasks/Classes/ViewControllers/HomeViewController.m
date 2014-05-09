//
//  HomeViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 5/9/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "HomeViewController.h"
#import "UsersModel.h"
#import "TaskListModel.h"
#import "StatsModel.h"
#import "NSDate+Reporting.h"
#import "SettingSegueTableViewCell.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView* table;
    IBOutlet UIView* tipsHeaderView;
    IBOutlet UIView* personalGoalHeaderView;
    IBOutlet UIButton* weeklyReview;
    
    IBOutlet UILabel* sampleLabel;
    
    NSString* personalGoalText;
    NSString* motivationalQuote;
    NSArray* awardsToShow;
    NSDate* quoteDate;
}

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    quoteDate = [NSDate midnightToday];
    [self newQuote];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    weeklyReview.hidden = ![UsersModel sharedInstance].purchasedWeeklyReview;
    
    NSDate* lastTimeShowedAwards = [[UsersModel sharedInstance].logedUserData objectForKey:LOGGED_USER_LAST_LOGGIN];
    
    NSArray* allAwards = [StatsModel sharedInstance].awards;
    NSMutableArray* tempAwards = [[NSMutableArray alloc] initWithCapacity:allAwards.count];
    for (NSDictionary* awardDic in allAwards) {
        NSDate* awardDate = [awardDic objectForKey:@"day"];
        if ([awardDate timeIntervalSinceDate:lastTimeShowedAwards] >= 0) {
            [tempAwards addObject:awardDic];
        }
    }
    
    if ([[NSDate midnightToday] timeIntervalSinceDate:quoteDate] != 0) {
        [self newQuote];
    }
    
    NSInteger goalPoints = [[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_GOAL_KEY];
    if (goalPoints)
        personalGoalText = [NSString stringWithFormat:@"%ld Points",(long)goalPoints];
    else
        personalGoalText = @"You haven't set a personal goal yet";
    
    
    
    [table reloadData];
}

- (void) newQuote {
    NSArray* quotes = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Quotes" ofType:@"plist"]];
    motivationalQuote = quotes[arc4random() % quotes.count];
}

#pragma mark - UITableView Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return awardsToShow.count;
            break;
        case 1:
        case 2:
            return 1;
            break;
    }
    
    return 0;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return personalGoalHeaderView;
            break;
        case 2:
            return tipsHeaderView;
            break;
        default:
            return [[UIView alloc] init];
            break;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return personalGoalHeaderView.frame.size.height;
            break;
        case 2:
            return tipsHeaderView.frame.size.height;
        default:
            return 0;
            break;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return [motivationalQuote sizeWithFont:sampleLabel.font constrainedToSize:CGSizeMake(sampleLabel.frame.size.width - 20, 999999) lineBreakMode:NSLineBreakByCharWrapping].height;
    } else {
        return tableView.rowHeight;
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingSegueTableViewCell* cell;
    
    if (indexPath.section == 0) { //awards section
        cell = [tableView dequeueReusableCellWithIdentifier:@"HomeAwardCell"];
        [(UILabel*)cell.editingAccessoryView setText:[awardsToShow[indexPath.row] objectForKey:@"text"]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCommonCell"];
        if (indexPath.section == 1)
            [cell.lblText setText:personalGoalText];
        else
            [cell.lblText setText:motivationalQuote];
    }
    
    return cell;
}

@end
