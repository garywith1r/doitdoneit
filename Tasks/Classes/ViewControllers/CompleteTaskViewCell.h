//
//  CompleteTaskViewCell.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 2/26/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskDTO.h"

@protocol CompleteTaskDelegate <NSObject>

@optional
- (void) noteTextDidStartEditing;
- (void) noteTextDidEndEditing;
- (void) shouldDisposeTheCell;

@end

@interface CompleteTaskViewCell : UITableViewCell

@property (nonatomic, weak) NSObject <CompleteTaskDelegate>* delegate;
@property (nonatomic, weak) TaskDTO* task;

@end
