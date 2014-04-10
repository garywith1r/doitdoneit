//
//  SummaryViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/9/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SummaryViewController.h"
#import "UsersModel.h"
#import "EGOFileManager.h"
#import "MHCustomTabBarController.h"

@interface SummaryViewController () {
    IBOutlet UIButton* btnImage;
    IBOutlet UILabel* nameLabel;
    IBOutlet UILabel* statsLabel;
}

@end

@implementation SummaryViewController


- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDictionary* currentUser = [UsersModel sharedInstance].logedUser;
    
    nameLabel.text = [currentUser objectForKey:LOGGED_USER_NAME_KEY];
    UIImage* image = [EGOFileManager getImageFromPath:[currentUser objectForKey:LOGGED_USER_IMAGE_KEY]];
    if (image) {
        [btnImage setTitle:@"" forState:UIControlStateNormal];
        btnImage.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [btnImage setImage:image forState:UIControlStateNormal];
    }
}

- (IBAction) changeUser {
    MHCustomTabBarController* tabBar = [self.storyboard instantiateInitialViewController];
    [tabBar changeUser];
}

@end
