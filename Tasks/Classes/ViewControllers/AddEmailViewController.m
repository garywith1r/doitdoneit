//
//  AddEmailViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 5/10/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "AddEmailViewController.h"
#import "AddEmailPopUpViewController.h"
#import "SWTableViewCell.h"
#import "StatsViewCell.h"
#import "UsersModel.h"
#import "Constants.h"

@interface AddEmailViewController () <AddEmailPopUpViewDelegate, PopUpDelegate, SWTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView* table;
    IBOutlet UIView* noEmailsView;
    IBOutlet UIButton* noEmailsButton;
    IBOutlet UIView* footerView;
    IBOutlet UIButton* footerViewButton;
    
    
    NSMutableArray* emails;
    NSString* editingEmail;
}

@end

@implementation AddEmailViewController

- (void) viewDidLoad {
    noEmailsView.layer.borderColor = YELLOW_COLOR.CGColor;
    noEmailsView.layer.borderWidth = 1.0;
    noEmailsView.layer.masksToBounds = YES;
    
    noEmailsButton.layer.borderColor = YELLOW_COLOR.CGColor;
    noEmailsButton.layer.borderWidth = 1.0;
    noEmailsButton.layer.masksToBounds = YES;
    
    footerViewButton.layer.borderColor = YELLOW_COLOR.CGColor;
    footerViewButton.layer.borderWidth = 1.0;
    footerViewButton.layer.masksToBounds = YES;
    
    emails = [NSMutableArray arrayWithArray:[[UsersModel sharedInstance].logedUserData objectForKey:LOGGED_USER_RECIPIENTS_LIST]];
    
    BOOL hasEmails = emails.count != 0;
    
    table.hidden = !hasEmails;
    noEmailsView.hidden = noEmailsButton.hidden = hasEmails;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

- (void) orientationChanged:(NSNotification *)note {
    [table reloadData];
}

- (IBAction) addEmail {
    [self showPopUpForEmail:nil];
}

- (void) showPopUpForEmail:(NSString*) email {
    AddEmailPopUpViewController* popUP = [self.storyboard instantiateViewControllerWithIdentifier:@"AddEmailPopUpViewController"];
    popUP.email = email;
    popUP.delegate = self;
    if ([DeviceDetector isPad])
        [popUP presentOnMainWindow];
    else
        [popUP presentOnViewController:self];
}

- (void) removeEmailAtIndex:(NSInteger)index {
    [emails removeObjectAtIndex:index];
    [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    if (emails.count == 0) {
        table.hidden = YES;
        noEmailsView.hidden = noEmailsButton.hidden = NO;
    }
    [[UsersModel sharedInstance].logedUserData setObject:[NSArray arrayWithArray:emails] forKey:LOGGED_USER_RECIPIENTS_LIST];
}

#pragma mark - UITableView Methods

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return footerView.frame.size.height;
}

- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return footerView;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return emails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil) {
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:0.0]
                                                     icon:[UIImage imageNamed:@"Edit.png"] tag:indexPath.row];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:0.0]
                                                     icon:[UIImage imageNamed:@"Delete.png"] tag:indexPath.row];
        
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier
                                  containingTableView:tableView // For row height and selection
                                   leftUtilityButtons:leftUtilityButtons
                                  rightUtilityButtons:rightUtilityButtons];
        
        cell.delegate = self;
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        cell.textLabel.numberOfLines = 0;
    }
    
    StatsViewCell* statsView = [self.storyboard instantiateViewControllerWithIdentifier:@"EmailViewCell"];
    
    CGRect frame = statsView.view.frame;
    frame.size.width = table.frame.size.width;
    frame.size.height = tableView.rowHeight;
    statsView.view.frame = frame;
    
    [cell setContentView:statsView.view];
    
    statsView.awardLabel.text = emails[indexPath.row];    
    
    cell.tag = indexPath.row;
    
    return cell;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:{ // Edit
            editingEmail = emails[index];
            [self showPopUpForEmail:editingEmail];
            break;
        }
        case 1: // Delete
        {
            [self removeEmailAtIndex:cell.tag];
            break;
        }
        default:
            break;
    }
}

#pragma mark - AddEmailPopUpDelegate Methods

- (void) doneWithEmail:(NSString *)email {
    if (editingEmail)
        [emails replaceObjectAtIndex:[emails indexOfObject:editingEmail] withObject:email];
    else
        [emails addObject:email];
    table.hidden = NO;
    noEmailsView.hidden = noEmailsButton.hidden = YES;
    [[UsersModel sharedInstance].logedUserData setObject:[NSArray arrayWithArray:emails] forKey:LOGGED_USER_RECIPIENTS_LIST];
    [table reloadData];
}

- (void) popUpWillClose {
    editingEmail = nil;
}

@end
