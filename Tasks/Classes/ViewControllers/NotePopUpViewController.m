//
//  NotePopUpViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 5/1/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "NotePopUpViewController.h"
#import "Constants.h"

@interface NotePopUpViewController () <UITextViewDelegate> {
    IBOutlet UITextView* textView;
}

@end

@implementation NotePopUpViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    textView.text = self.task.notes;
}

- (BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString* newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return newText.length <= TASK_NOTE_MAX_CHARACTERS;
}

- (IBAction) doneButtonPressed {
    self.task.notes = textView.text;
    [super doneButtonPressed];
}

@end
