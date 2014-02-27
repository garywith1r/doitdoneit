//
//  StatsViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 2/27/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "StatsViewController.h"
#import "SWTableViewCell.h"
#import "MediaModel.h"
#import "StatsModel.h"
#import "DeviceDetector.h"

@interface StatsViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate> {
    IBOutlet UITableView* table;
}

@end

@implementation StatsViewController

- (void) viewDidLoad {
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillAppear:) name: UIApplicationWillEnterForegroundNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [table reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil) {
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:0.0]
                                                     icon:[UIImage imageNamed:@"FacebookIcon.png"] tag:indexPath.row];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:0.0]
                                                     icon:[UIImage imageNamed:@"TwitterIcon.png"] tag:indexPath.row];
        
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier
                                  containingTableView:tableView // For row height and selection
                                   leftUtilityButtons:leftUtilityButtons
                                  rightUtilityButtons:rightUtilityButtons];
        
        cell.delegate = self;
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        cell.textLabel.numberOfLines = 0;
    }
    
    StatsModel* stats = [StatsModel sharedInstance];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"Completed Today %d, Points %d\nHit Rate %.1f",stats.todayCompleted,stats.todayPoints, stats.todayHitRate];
            break;
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"Completed Yesterday %d, Points %d\nHit Rate %.1f",stats.yesterdayCompleted,stats.yesterdayPoints, stats.yesterdayHitRate];
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"Completed This Week %d, Points %d\nHit Rate %.1f",stats.thisWeekCompleted,stats.thisWeekPoints, stats.thisWeekHitRate];
            break;
        case 3:
            cell.textLabel.text = [NSString stringWithFormat:@"Completed Last Week %d, Points %d\nHit Rate %.1f",stats.lastWeekCompleted,stats.lastWeekPoints, stats.lastWeekHitRate];
            break;
        case 4:
            cell.textLabel.text = [NSString stringWithFormat:@"Completed Overall %d, Points %d\nHit Rate %.1f",stats.totalCompleted,stats.totalPoints, stats.totalHitRate];
            break;
            
        default:
            break;
    }
    
    
    return cell;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0: // Facebook
            [MediaModel postMessageToFacebook:[self getMessageToShareForIndex:(int)cell.tag]];
            break;
        case 1: // Twitter
        {
            [MediaModel postMessageToTwitter:[self getMessageToShareForIndex:(int)cell.tag]];
        }
        default:
            break;
    }
}

- (NSString*) getMessageToShareForIndex:(int)index {
    
    StatsModel* stats = [StatsModel sharedInstance];
    
    switch (index) {
        case 0:
            return [NSString stringWithFormat:@"I've completed %d tasks today, and won %d Points\nHit Rate %.1f",stats.todayCompleted,stats.todayPoints, stats.todayHitRate];;
            break;
        case 1:
            return [NSString stringWithFormat:@"I've completed %d tasks yesterday, won win %d Points\nHit Rate %.1f",stats.yesterdayCompleted,stats.yesterdayPoints, stats.yesterdayHitRate];;
            break;
        case 2:
            return [NSString stringWithFormat:@"I've completed %d tasks this week, won win %d Points\nHit Rate %.1f",stats.thisWeekCompleted,stats.thisWeekPoints, stats.thisWeekHitRate];;
            break;
        case 3:
            return [NSString stringWithFormat:@"I've completed %d tasks last week, won win %d Points\nHit Rate %.1f",stats.lastWeekCompleted,stats.lastWeekPoints, stats.lastWeekHitRate];;
            break;
        case 4:
            return [NSString stringWithFormat:@"I've completed %d tasks overall, won win %d Points\nHit Rate %.1f",stats.totalCompleted,stats.totalPoints, stats.totalHitRate];;
            break;
            
        default:
            break;
    }
    
    return @"";
}

@end
