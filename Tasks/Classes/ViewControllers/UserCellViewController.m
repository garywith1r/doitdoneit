//
//  UserCellViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/29/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "UserCellViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface UserCellViewController ()

@end

@implementation UserCellViewController
@synthesize avatarImage, disclosureImage, nameLabel, statsLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.avatarImage.layer.cornerRadius = 22;
    self.avatarImage.layer.masksToBounds = YES;
    
    self.avatarImage.contentMode = UIViewContentModeScaleAspectFill;
}



@end
