//
//  InAppPurhcaseViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/25/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "InAppPurhcaseViewController.h"

@interface InAppPurhcaseViewController () {
    IBOutlet UILabel* lblTitle;
    IBOutlet UILabel* lblDescription;
}

@end

@implementation InAppPurhcaseViewController
@synthesize inAppDictionary;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    lblTitle.text = [self.inAppDictionary objectForKey:@"Name"];
    lblDescription.text = [self.inAppDictionary objectForKey:@"Description"];
}


- (IBAction) purchaseButtonPressed {
    
}

- (IBAction) cancelButtonPressed {
    
}



@end
