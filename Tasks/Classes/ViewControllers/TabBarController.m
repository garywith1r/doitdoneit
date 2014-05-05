//
//  TabBarController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/21/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "TabBarController.h"
#import "UsersModel.h"
#import "iAd/ADBannerView.h"

@interface TabBarController () <ADBannerViewDelegate> {
    IBOutlet NSLayoutConstraint *iAdsViewHeight;
    IBOutlet UIView* iAdsView;
    IBOutlet UIView* tabBar;
    
    CGFloat iAdsViewHeightValue;
}

@end

@implementation TabBarController

- (void) viewDidLoad {
    [super viewDidLoad];
    iAdsViewHeightValue = iAdsViewHeight.constant;
    iAdsViewHeight.constant = 0;
    iAdsView.hidden = YES;
//    if ([UsersModel sharedInstance].purchasedAddsFree)
//        [self performSelector:@selector(removeAdds) withObject:nil afterDelay:0.1];
}

- (void) removeAdds {
    iAdsViewHeight.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{[self.view layoutIfNeeded];}];
    iAdsView.hidden = YES;
    
}


#pragma mark - ADBannerViewDelegate Methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (![UsersModel sharedInstance].purchasedAddsFree) {
        iAdsView.hidden = NO;
        iAdsViewHeight.constant = iAdsViewHeightValue;
        [UIView animateWithDuration:0.3 animations:^{[self.view layoutIfNeeded];}];
    }
}

@end
