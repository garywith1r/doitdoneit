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
    
    IBOutlet NSLayoutConstraint* weeklyButtonHeightContrait;
    
    NSString* personalGoalText;
    NSString* personalGoalDescription;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillAppear:) name: UIApplicationWillEnterForegroundNotification object:nil];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([UsersModel sharedInstance].purchasedWeeklyReview) {
        weeklyReview.hidden = NO;
        weeklyButtonHeightContrait.constant = 25;
    } else {
        weeklyReview.hidden = YES;
        weeklyButtonHeightContrait.constant = 0;
    }
    
    
    NSDate* lastTimeShowedAwards = [[UsersModel sharedInstance].logedUserData objectForKey:LOGGED_USER_LAST_LOGGIN];
    
    NSArray* allAwards = [StatsModel sharedInstance].awards;
    
    if (lastTimeShowedAwards) {
        NSMutableArray* tempAwards = [[NSMutableArray alloc] initWithCapacity:allAwards.count];
        for (NSDictionary* awardDic in allAwards) {
            NSDate* awardDate = [awardDic objectForKey:@"day"];
            if ([awardDate timeIntervalSinceDate:lastTimeShowedAwards] >= 0) {
                [tempAwards addObject:awardDic];
            }
        }
        awardsToShow = [NSArray arrayWithArray:tempAwards];
    } else {
        awardsToShow = allAwards;
    }
    
    if ([[NSDate midnightToday] timeIntervalSinceDate:quoteDate] != 0) {
        [self newQuote];
    }
    
    NSInteger goalPoints = [[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_GOAL_KEY];
    if (goalPoints) {
        personalGoalText = [NSString stringWithFormat:@"%ld Points, Currently %ld points",(long)goalPoints,(long)[StatsModel sharedInstance].totalPoints];
    } else {
        personalGoalText = @"You haven't set a personal goal yet";
    }
    
    personalGoalDescription = [[UsersModel sharedInstance].logedUserData objectForKey:LOGGED_USER_GOAL_DESCRIPTION_KEY];
    
    if (!personalGoalDescription)
        personalGoalDescription = @"";
    
    
    
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
    if (indexPath.section == 1) {
        return [personalGoalDescription sizeWithFont:sampleLabel.font constrainedToSize:CGSizeMake(sampleLabel.frame.size.width - 20, 999999) lineBreakMode:NSLineBreakByCharWrapping].height + 43;
    } else if (indexPath.section == 2) {
        return [motivationalQuote sizeWithFont:sampleLabel.font constrainedToSize:CGSizeMake(sampleLabel.frame.size.width - 20, 999999) lineBreakMode:NSLineBreakByCharWrapping].height + 20;
    } else {
        return tableView.rowHeight;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingSegueTableViewCell* cell;
    
    if (indexPath.section == 0) { //awards section
        cell = [tableView dequeueReusableCellWithIdentifier:@"HomeAwardCell"];
        [cell.lblText setText:[awardsToShow[indexPath.row] objectForKey:@"text"]];
    } else if (indexPath.section == 1) { //Goal section
        cell = [tableView dequeueReusableCellWithIdentifier:@"HomeGoalCell"];
        [cell.lblText setText:personalGoalDescription];
        [cell.lblText2 setText:personalGoalText];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCommonCell"];
        [cell.lblText setText:motivationalQuote];
    }
    
    return cell;
}

@end
