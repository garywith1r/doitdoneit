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
    IBOutlet UIView* iAdsView;
}

@end

@implementation TabBarController

- (void) viewDidLoad {
    [super viewDidLoad];
    if ([UsersModel sharedInstance].purchasedAddsFree)
        [self removeAdds];
}

- (void) removeAdds {
    iAddsViewHeight.constant = 0;
    iAdsView.hidden = YES;
}

- (void) changeUser {
    UserSelectionViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserSelectionViewController"];
    vc.isChangingUser = YES;
    [((UINavigationController*)self.destinationViewController) pushViewController:vc animated:YES];
}

@end
