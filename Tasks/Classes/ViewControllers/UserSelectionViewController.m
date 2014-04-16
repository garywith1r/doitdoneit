//
//  UserSelectionViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/8/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "UserSelectionViewController.h"
#import "SWTableViewCell.h"
#import "UsersModel.h"
#import "AddEditUserViewController.h"
#import "TaskListModel.h"

@interface UserSelectionViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate> {
    NSArray* usersArray;
    IBOutlet UITableView* table;
    IBOutlet UIView* parentsModeView;
    IBOutlet UISwitch* parentsModeSwitch;
}

@end

@implementation UserSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    usersArray = [[UsersModel sharedInstance] getUsers];
    parentsModeSwitch.on = [UsersModel sharedInstance].parentsModeEnabled;
    [table reloadData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditUserSegue"]) {
        AddEditUserViewController* vc = segue.destinationViewController;
        vc.usersDictionary = [usersArray objectAtIndex:((NSIndexPath*)sender).row];
    }
}

- (IBAction) parentsViewValueChanged {
    if (parentsModeSwitch.on) {
        [self performSegueWithIdentifier:@"ActiveParentsMode" sender:nil];
    } else {
        [UsersModel sharedInstance].parentsModeEnabled = NO;
    }
}

#pragma mark - UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return usersArray.count;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.isChangingUser && [UsersModel sharedInstance].purchasedParentsMode)
        return parentsModeView;
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isChangingUser && [UsersModel sharedInstance].purchasedParentsMode)
        return parentsModeView.frame.size.height;
    else
        return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:0.0]
                                                     icon:[UIImage imageNamed:@"Delete.png"] tag:indexPath.row];
        
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier
                                  containingTableView:tableView // For row height and selection
                                   leftUtilityButtons:leftUtilityButtons
                                  rightUtilityButtons:rightUtilityButtons];
        
        cell.delegate = self;
    }
    
    cell.textLabel.text = [[usersArray objectAtIndex:indexPath.row] objectForKey:LOGGED_USER_NAME_KEY];
    
    if (self.isChangingUser)
        cell.accessoryType = UITableViewCellAccessoryNone;
    else
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isChangingUser) {
        [[UsersModel sharedInstance] changeToUserAtIndex:indexPath.row];
        [[TaskListModel sharedInstance] loadFullData];
        [[TaskListModel sharedInstance] forceRecalculateTasks];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self performSegueWithIdentifier:@"EditUserSegue" sender:indexPath];
    }
}

@end
