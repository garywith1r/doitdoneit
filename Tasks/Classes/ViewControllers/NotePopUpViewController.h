//
//  NotePopUpViewController.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 5/1/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "PopUpViewController.h"
#import "TaskDTO.h"

@interface NotePopUpViewController : PopUpViewController

@property (nonatomic, weak) TaskDTO* task;

@end
