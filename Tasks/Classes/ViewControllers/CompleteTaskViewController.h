//
//  CompleteTaskViewController.h
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskDTO.h"

@interface CompleteTaskViewController : UIViewController

@property (nonatomic, strong) TaskDTO* task;

+ (void) showInParentView:(UIViewController*)parent forTask:(TaskDTO*)task;

@end
