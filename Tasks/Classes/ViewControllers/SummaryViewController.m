//
//  SummaryViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/9/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SummaryViewController.h"
#import "UsersModel.h"
#import "StatsModel.h"
#import "EGOFileManager.h"
#import "TabBarController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@interface SummaryViewController () {
    IBOutlet UIButton* btnImage;
    IBOutlet UILabel* nameLabel;
    IBOutlet UILabel* statsLabel;
}

@end

@implementation SummaryViewController


- (void) viewDidLoad {
    [super viewDidLoad];
    
    btnImage.layer.cornerRadius = 34;
    btnImage.layer.masksToBounds = YES;
    btnImage.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDictionary* currentUser = [UsersModel sharedInstance].logedUser;
    
    
    StatsModel* statsModel = [StatsModel sharedInstance];
    
    nameLabel.text = [currentUser objectForKey:LOGGED_USER_NAME_KEY];
    statsLabel.text = [NSString stringWithFormat:@"%d Done today, %d this\nweek. Hit rate %.1f%%",statsModel.todayCompleted, statsModel.thisWeekCompleted, [statsModel thisWeekHitRate]];
    UIImage* image = [EGOFileManager getImageFromPath:[currentUser objectForKey:LOGGED_USER_IMAGE_KEY]];
    
    if (image) {
        [btnImage setImage:image forState:UIControlStateNormal];
    } else {
        [btnImage setImage:DEFAULT_USER_IMAGE forState:UIControlStateNormal];
    }
}

- (IBAction) changeUser {
    TabBarController* tabBar = (TabBarController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [tabBar changeUser];
}

@end
