//
//  CompleteTaskViewCell.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 2/26/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskDTO.h"

#define COMPLETE_TASK_VIEW_CELL_HEIGHT 175

@protocol CompleteTaskDelegate <NSObject>

@optional
- (void) noteTextDidStartEditing;
- (void) noteTextDidEndEditing;
- (void) shouldDisposeTheCellForTask:(TaskDTO*)task;

@end

@interface CompleteTaskViewCell : UITableViewCell

- (void) resetContent;

@property (nonatomic, weak) NSObject <CompleteTaskDelegate>* delegate;
@property (nonatomic, strong) TaskDTO* task;

@end
