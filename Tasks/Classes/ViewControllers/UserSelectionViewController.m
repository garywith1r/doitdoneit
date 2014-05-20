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
#import "TaskListModel.h"
#import "NewUserPopUP.h"
#import "UserCellViewController.h"
#import "CacheFileManager.h"
#import "Constants.h"
#import "StatsModel.h"


#define DELETE_TASK_ALERT_TAG 125

@interface UserSelectionViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, PopUpDelegate> {
    NSArray* usersArray;
    IBOutlet UITableView* table;
    IBOutlet UIView* headersView;
    
    IBOutlet UIView* footerView;
    IBOutlet UISwitch* parentModeSwitch;
    
    NSInteger userIndexToDelete;
    
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
    [table reloadData];
    parentModeSwitch.on = [UsersModel sharedInstance].parentsModeActive;
}

- (IBAction) backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) switchstatusChanged {
    if (parentModeSwitch.on) {
        [self performSegueWithIdentifier:@"ActiveParentsMode" sender:nil];
    } else {
        [UsersModel sharedInstance].parentsModeActive = NO;
    }
}

#pragma mark - UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return usersArray.count + [UsersModel sharedInstance].purchasedMultiUser;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return headersView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return headersView.frame.size.height;
}

- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.isChangingUser && [UsersModel sharedInstance].parentsModeEnabled)
        return footerView;
    else {
        UIView* view = [[UIView alloc] initWithFrame:footerView.frame];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
        return footerView.frame.size.height;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([UsersModel sharedInstance].purchasedMultiUser && (indexPath.row == 0)) {
        return [table dequeueReusableCellWithIdentifier:@"NewUserCell"];
    }
    static NSString *cellIdentifier = @"Cell";
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSUInteger row = indexPath.row - [UsersModel sharedInstance].purchasedMultiUser;
    
    if (cell == nil) {
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:0.0]
                                                     icon:[UIImage imageNamed:@"Delete.png"] tag:row];
        
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier
                                  containingTableView:tableView // For row height and selection
                                   leftUtilityButtons:leftUtilityButtons
                                  rightUtilityButtons:rightUtilityButtons];
        
        cell.delegate = self;
        cell.cellScrollView.scrollEnabled = !self.isChangingUser;
        cell.tag = indexPath.row - [UsersModel sharedInstance].purchasedMultiUser;
    }
    
    NSDictionary* usersDict = [usersArray objectAtIndex:row];
    UserCellViewController* cellView = [self.storyboard instantiateViewControllerWithIdentifier:@"UserCellViewController"];
    
    [cell setContentView:cellView.view];

    cellView.nameLabel.text = [usersDict objectForKey:LOGGED_USER_NAME_KEY];
    NSString* imagePath = [usersDict objectForKey:LOGGED_USER_IMAGE_KEY];
    
    if (imagePath && ![@"" isEqualToString:imagePath]) {
        cellView.avatarImage.image = [CacheFileManager getImageFromPath:imagePath];
    } else {
        cellView.avatarImage.image = DEFAULT_USER_IMAGE;
    }
    
    cellView.disclosureImage.hidden = self.isChangingUser;
    cellView.statsLabel.hidden = !self.isChangingUser;
    
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([UsersModel sharedInstance].purchasedMultiUser && (indexPath.row == 0) ) {
        NewUserPopUP* newUser = [self.storyboard instantiateViewControllerWithIdentifier:@"NewUserPopUp"];
        newUser.delegate = self;
        [newUser presentOnViewController:self];
        
    } else if (self.isChangingUser) {
        
        //add reminders for current user and save all changes done.
        [[UsersModel sharedInstance] addRemindersForMainTask];
        [[UsersModel sharedInstance] saveCurrentUserData];
        
        
        [[UsersModel sharedInstance] changeToUserAtIndex:indexPath.row - [UsersModel sharedInstance].purchasedMultiUser];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NewUserPopUP* newUser = [self.storyboard instantiateViewControllerWithIdentifier:@"NewUserPopUp"];
        newUser.usersDictionary = [usersArray objectAtIndex:(indexPath.row - [UsersModel sharedInstance].purchasedMultiUser)];
        newUser.delegate = self;
        [newUser presentOnViewController:self];     
    }
}


#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:{ // Delete
            userIndexToDelete = cell.tag;
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to completely delete this user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            alert.tag = DELETE_TASK_ALERT_TAG;
            [alert show];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == DELETE_TASK_ALERT_TAG) {
        if (buttonIndex == 1) {
            [[UsersModel sharedInstance] deleteUserAtIndex:userIndexToDelete];
            [self viewWillAppear:NO];
        }
    }
}


#pragma pragma mark - PopUpDelegate
- (void) popUpWillClose {
    [self viewWillAppear:NO];
}


@end
