//
//  PopViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/29/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "PopViewController.h"

@interface PopViewController ()

@end

@implementation PopViewController

- (IBAction) popViewController {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([viewControllers containsObject:self])
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

@end
