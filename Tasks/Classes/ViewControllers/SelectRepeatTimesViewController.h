//
//  SelectRepeatTimesViewController.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/23/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "PopUpViewController.h"

@protocol SelectRepeatTimesDelegate <NSObject>

- (void) selectedRepeatTimes:(NSInteger) repeatTimes perTimeInterval:(NSInteger)timeInterval;

@end

@interface SelectRepeatTimesViewController : PopUpViewController
@property (nonatomic, weak) NSObject <PopUpDelegate, SelectRepeatTimesDelegate>* delegate;


- (void) setInitialTimes:(NSInteger)times andInitialTimeInterval:(NSInteger)interval;

@end
