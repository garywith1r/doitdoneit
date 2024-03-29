//
//  AwardsViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "AwardsViewController.h"
#import "SWTableViewCell.h"
#import "MediaModel.h"
#import "StatsModel.h"
#import "UsersModel.h"
#import "DeviceDetector.h"
#import "StatsViewCell.h"
#import "NSDate+Reporting.h"

@interface AwardsViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate> {
    IBOutlet UITableView* table;
    NSArray* awardsArray;
    NSArray* sharingTextArray;
}

@end

@implementation AwardsViewController

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
    return [StatsModel sharedInstance].awards.count;
}

- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, table.frame.size.width, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
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
    StatsViewCell* statsView = [self.storyboard instantiateViewControllerWithIdentifier:@"AwardViewCell"];
    
    [cell setContentView:statsView.view];
    NSDictionary* awardDictionary = [stats.awards objectAtIndex:indexPath.row];
    
    statsView.awardLabel.text = [awardDictionary objectForKey:@"text"];
    statsView.awardDate.text = [NSDate timePassedSince:[awardDictionary objectForKey:@"day"]];
    
    cell.cellScrollView.scrollEnabled = ![[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_PRIVATE_KEY];
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
    NSDictionary* awardDictionary = [stats.awards objectAtIndex:index];
    
    return [awardDictionary objectForKey:@"text"];
}

@end
