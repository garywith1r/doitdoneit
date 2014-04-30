//
//  SettingsTableViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/30/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "UsersModel.h"

@interface SettingsTableViewController () {
    IBOutlet UISwitch* privateAccountMode;
    IBOutlet UISwitch* parentsModeFeature;
}

@end

@implementation SettingsTableViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    privateAccountMode.on = [[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_PRIVATE_KEY];
    parentsModeFeature.on = [UsersModel sharedInstance].parentsModeEnabled;
}

- (IBAction) privateAccountSwitchChanged {
    [[UsersModel sharedInstance].logedUserData setInteger:privateAccountMode.on forKey:LOGGED_USER_PRIVATE_KEY];
}

- (IBAction) parentsModeFeatureSwitchChange {
    [UsersModel sharedInstance].parentsModeEnabled = parentsModeFeature.on;
}


@end
