//
//  EditTaskViewController.h
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskDTO.h"

@protocol SelectDateDelegate <NSObject>

@optional
- (void) didSelectDate:(NSDate*)date;

@end


@interface SelectDateViewController : UIViewController

@property (nonatomic, weak) NSObject <SelectDateDelegate>* delegate;
@property (nonatomic, strong) NSDate* startDate;

@end
