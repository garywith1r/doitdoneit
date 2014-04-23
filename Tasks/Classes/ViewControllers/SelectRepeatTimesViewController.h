//
//  SelectRepeatTimesViewController.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/23/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectRepeatTimesDelegate <NSObject>

- (void) selectedRepeatTimes:(NSInteger) repeatTimes perTimeInterval:(NSInteger)timeInterval;

@end

@interface SelectRepeatTimesViewController : UIViewController
@property (nonatomic, weak) NSObject <SelectRepeatTimesDelegate>* delegate;

- (void) presentOnViewController:(UIViewController*)viewController;
- (void) setInitialTimes:(NSInteger)times andInitialTimeInterval:(NSInteger)interval;

@end
