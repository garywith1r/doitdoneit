//
//  SettingsTableViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/30/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "UsersModel.h"
#import "SettingSwitchTableViewCell.h"
#import "SettingSegueTableViewCell.h"

@interface SettingsTableViewController () {
    IBOutlet UISwitch* privateAccountMode;
    IBOutlet UISwitch* parentsModeFeature;
    
    NSArray* contentArray;
}

@end

@implementation SettingsTableViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshContentArray];
    [self.tableView reloadData];
    privateAccountMode.on = [[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_PRIVATE_KEY];
    parentsModeFeature.on = [UsersModel sharedInstance].parentsModeEnabled;
}

- (IBAction) privateAccountSwitchChanged {
    [[UsersModel sharedInstance].logedUserData setInteger:privateAccountMode.on forKey:LOGGED_USER_PRIVATE_KEY];
}

- (IBAction) parentsModeFeatureSwitchChange {
    if ([UsersModel sharedInstance].parentsModeEnabled) {
        if (![UsersModel sharedInstance].parentsModeActive) {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enable Parent mode on user selection screen in order to switch it off" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            parentsModeFeature.on = YES;
            return;
        }
    }
    [UsersModel sharedInstance].parentsModeEnabled = parentsModeFeature.on;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return contentArray.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    
    NSDictionary* settingDicc = contentArray[indexPath.row];
    NSString* type = [settingDicc objectForKey:@"Type"];
    
    if (!type || [@"" isEqualToString:type]) {
        SettingSegueTableViewCell* tempCell = (SettingSegueTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SettingSegueCell"];
        tempCell.lblText.text = [settingDicc objectForKey:@"Text"];
        cell = tempCell;
    } else if ([@"PrivateAccount" isEqualToString:type]) {
        SettingSwitchTableViewCell* tempCell = (SettingSwitchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SettingSwitchSegue"];
        tempCell.lblText.text = [settingDicc objectForKey:@"Text"];
        privateAccountMode = tempCell.swtCell;
        privateAccountMode.on = [[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_PRIVATE_KEY];
        [privateAccountMode addTarget:self action:@selector(privateAccountSwitchChanged) forControlEvents:UIControlEventValueChanged];
        cell = tempCell;
        
    } else if ([@"EnableParentsMode" isEqualToString:type]) {
        SettingSwitchTableViewCell* tempCell = (SettingSwitchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SettingSwitchSegue"];
        tempCell.lblText.text = [settingDicc objectForKey:@"Text"];
        parentsModeFeature = tempCell.swtCell;
        [parentsModeFeature addTarget:self action:@selector(parentsModeFeatureSwitchChange) forControlEvents:UIControlEventValueChanged];
        parentsModeFeature.on = [UsersModel sharedInstance].parentsModeEnabled;
        cell = tempCell;
    }
    
    
    return cell;
}

- (void) tableView:(UITableView*)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [table deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* settingDicc = contentArray[indexPath.row];
    NSString* segue = [settingDicc objectForKey:@"Segue"];
    if (segue && ![@""isEqualToString:segue])
        [self performSegueWithIdentifier:segue sender:nil];
}


- (void) refreshContentArray {
    NSMutableArray* tempArray = [[NSMutableArray alloc] initWithCapacity:8];
    
    [tempArray addObject:@{@"Text":@"Introduction",@"Segue":@"IntroductionSegue"}];
    
    [tempArray addObject:@{@"Text":@"User Profile(s)",@"Segue":@"EditUsersSegue"}];
    
    [tempArray addObject:@{@"Text":@"Reminders",@"Segue":@"RemindersSegue"}];
    
    if ([UsersModel sharedInstance].purchasedParentsMode)
        [tempArray addObject:@{@"Text":@"Set Parents Pincode",@"Segue":@"SetUpParentsPincode"}];
    
    if ([UsersModel sharedInstance].purchasedWeeklyReview)
        [tempArray addObject:@{@"Text":@"Review Recipients",@"Segue":@"ReviewRecipientsSegue"}];
    
    [tempArray addObject:@{@"Text":@"Set Goal",@"Segue":@"SetGoalSegue"}];
    
    [tempArray addObject:@{@"Text":@"Account is Private",@"Type":@"PrivateAccount"}];
    
    if ([UsersModel sharedInstance].purchasedParentsMode)
        [tempArray addObject:@{@"Text":@"Family Mode Enabled",@"Type":@"EnableParentsMode"}];
    
    contentArray = [NSArray arrayWithArray:tempArray];
}


@end
