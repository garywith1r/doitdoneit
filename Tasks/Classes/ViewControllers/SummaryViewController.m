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
#import "CacheFileManager.h"
#import "TabBarController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "UserSelectionViewController.h"
#import "DeviceDetector.h"

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
    btnImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDictionary* currentUser = [UsersModel sharedInstance].logedUser;
    
    
    StatsModel* statsModel = [StatsModel sharedInstance];
    
    nameLabel.text = [currentUser objectForKey:LOGGED_USER_NAME_KEY];
    NSString* baseText = nil;
    if ([DeviceDetector isPad])
        baseText = @"%ld Done today, %ld this week. Hit rate %.1f%%";
    else
        baseText = @"%ld Done today, %ld this\nweek. Hit rate %.1f%%";
    
    statsLabel.text = [NSString stringWithFormat:baseText,(long)statsModel.todayCompleted, (long)statsModel.thisWeekCompleted, [statsModel thisWeekHitRate]];
    UIImage* image = [CacheFileManager getImageFromPath:[currentUser objectForKey:LOGGED_USER_IMAGE_KEY]];
    
    if (image) {
        [btnImage setImage:image forState:UIControlStateNormal];
    } else {
        [btnImage setImage:DEFAULT_USER_IMAGE forState:UIControlStateNormal];
    }
}

- (IBAction) changeUser {
    UserSelectionViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserSelectionViewController"];
    vc.isChangingUser = YES;
    UINavigationController* mainVC = (UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [mainVC pushViewController:vc animated:YES];
}

@end
