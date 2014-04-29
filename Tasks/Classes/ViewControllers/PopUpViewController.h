//
//  PopUpViewController.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/28/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol PopUpDelegate

@optional
- (void) popUpWillClose;

@end

@interface PopUpViewController : UIViewController

@property (nonatomic, weak) NSObject <PopUpDelegate>* delegate;

- (void) presentOnViewController:(UIViewController*)viewController;
- (IBAction) doneButtonPressed;
- (IBAction) closeButtonPressed;
@end
