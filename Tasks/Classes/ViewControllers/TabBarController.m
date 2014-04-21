//
//  TabBarController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/21/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "TabBarController.h"
#import "UserSelectionViewController.h"
#import "UsersModel.h"

@interface TabBarController () {
    IBOutlet NSLayoutConstraint *iAddsViewHeight;
}

@end

@implementation TabBarController

- (void) viewDidLoad {
    [super viewDidLoad];
    if ([UsersModel sharedInstance].purchasedAddsFree)
        [self removeAdds:NO];
}

- (void) removeAdds:(BOOL)animating {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3 * animating];
    iAddsViewHeight.constant = 0;
    [UIView commitAnimations];
}

- (void) changeUser {
    UserSelectionViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserSelectionViewController"];
    vc.isChangingUser = YES;
    [((UINavigationController*)self.destinationViewController) pushViewController:vc animated:YES];
}

@end
