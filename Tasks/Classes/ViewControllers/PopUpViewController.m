//
//  PopUpViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/28/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "PopUpViewController.h"


@interface PopUpViewController () {
    IBOutlet UIView* contentView;
}

@end

@implementation PopUpViewController
@synthesize delegate;

- (void) viewDidLoad {
    [super viewDidLoad];
    contentView.layer.cornerRadius = 5;
    contentView.layer.masksToBounds = YES;
}

- (void) presentOnViewController:(UIViewController*)viewController {
    [viewController.view addSubview:self.view];
    [viewController addChildViewController:self];
    
    [UIView beginAnimations:NULL context:nil];
    [UIView setAnimationDuration:0.3];
    self.view.alpha = 1;
    [UIView commitAnimations];
}

- (IBAction) doneButtonPressed {
    [self closeButtonPressed];
}

- (IBAction) closeButtonPressed {
    [UIView beginAnimations:NULL context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(viewFadedOut)];
    self.view.alpha = 0;
    [UIView commitAnimations];
    if ([self.delegate respondsToSelector:@selector(popUpWillClose)])
        [self.delegate popUpWillClose];
}

- (void) viewFadedOut {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
