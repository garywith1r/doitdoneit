//
//  CompleteTaskViewCell.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 2/26/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "CompleteTaskViewCell.h"
#import "TaskListModel.h"
#import "Constants.h"
#import "MediaModel.h"

@interface CompleteTaskViewCell () {
    IBOutletCollection(UIButton) NSArray* ratingButtons;
    IBOutlet UITextField* txtNotes;
    
    int ratingTemp;
}

@end

@implementation CompleteTaskViewCell

- (void) resetContent {
    [self setRating:0];
    txtNotes.text = @"";
}

- (IBAction) ratingButtonPressed:(UIButton*) sender {
    [self setRating:(int)sender.tag];
}

- (void) setRating:(int)rating {
    int x = 0;
    for (; x < rating; x++) {
        [[ratingButtons objectAtIndex:x] setSelected:YES];
    }
    
    for (; x < ratingButtons.count; x++) {
        [[ratingButtons objectAtIndex:x] setSelected:NO];
    }
    
    ratingTemp = rating;
}

- (IBAction) skipTask {
    [[TaskListModel sharedInstance] missTask:self.task];
    if ([self.delegate respondsToSelector:@selector(shouldDisposeTheCellForTask:)])
        [self.delegate shouldDisposeTheCellForTask:self.task];
}

- (IBAction) completeTask {
    self.task.rating = ratingTemp;
    self.task.notes = txtNotes.text;
    [[TaskListModel sharedInstance] completeTask:self.task];
    if ([self.delegate respondsToSelector:@selector(shouldDisposeTheCellForTask:)])
        [self.delegate shouldDisposeTheCellForTask:self.task];
}

- (IBAction) shareOnFacebook {
    [MediaModel postMessageToFacebook:[NSString stringWithFormat:@"I Just completed %@",self.task.title]];
}

- (IBAction) shareOnTwitter {
    [MediaModel postMessageToTwitter:[NSString stringWithFormat:@"I Just completed %@",self.task.title]];
}

#pragma mark - UITextField Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return newText.length <= TASK_NOTE_MAX_CHARACTERS;
}


- (IBAction) textDidStartEditing {
    if ([self.delegate respondsToSelector:@selector(noteTextDidStartEditing)])
        [self.delegate noteTextDidStartEditing];
}

- (IBAction) textDidEndEditing {
    if ([self.delegate respondsToSelector:@selector(noteTextDidEndEditing)])
        [self.delegate noteTextDidEndEditing];
}

@end
