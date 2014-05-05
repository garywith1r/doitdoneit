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
#import "EGOFileManager.h"
#import "Constants.h"

@interface UserSelectionViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, PopUpDelegate> {
    NSArray* usersArray;
    IBOutlet UITableView* table;
    IBOutlet UIView* headersView;
    
    IBOutlet UIView* footerView;
    IBOutlet UISwitch* parentModeSwitch;
    
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
    else
        return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.isChangingUser && [UsersModel sharedInstance].parentsModeEnabled)
        return footerView.frame.size.height;
    else
        return 0.0;
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
    }
    
    NSDictionary* usersDict = [usersArray objectAtIndex:row];
    UserCellViewController* cellView = [self.storyboard instantiateViewControllerWithIdentifier:@"UserCellViewController"];
    
    [cell setContentView:cellView.view];

    cellView.nameLabel.text = [usersDict objectForKey:LOGGED_USER_NAME_KEY];
    NSString* imagePath = [usersDict objectForKey:LOGGED_USER_IMAGE_KEY];
    
    if (imagePath && ![@"" isEqualToString:imagePath]) {
        cellView.avatarImage.image = [EGOFileManager getImageFromPath:imagePath];
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
        [[UsersModel sharedInstance] changeToUserAtIndex:indexPath.row - [UsersModel sharedInstance].purchasedMultiUser];
        [[TaskListModel sharedInstance] loadFullData];
        [[TaskListModel sharedInstance] forceRecalculateTasks];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NewUserPopUP* newUser = [self.storyboard instantiateViewControllerWithIdentifier:@"NewUserPopUp"];
        newUser.usersDictionary = [usersArray objectAtIndex:(indexPath.row - [UsersModel sharedInstance].purchasedMultiUser)];
        newUser.delegate = self;
        [newUser presentOnViewController:self];     
    }
}

#pragma pragma mark - PopUpDelegate
- (void) popUpWillClose {
    [self viewWillAppear:NO];
}

@end
