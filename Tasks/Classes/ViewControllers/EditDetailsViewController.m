//
//  EditDetailsViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 3/27/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "EditDetailsViewController.h"
#import <CoreText/CTStringAttributes.h>

#import "DAAttributedStringFormatter.h"
#import "DAAttributedLabel.h"




#define BULLET_CODE @"\u25CF "
//regex from http://stackoverflow.com/questions/4390556/extract-url-from-string
#define HIPERLINKS_REGEX @"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|(www)?\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))"

@interface EditDetailsViewController () <UITextViewDelegate> {
    IBOutlet UITextView* detailsTextView;
    IBOutlet UIButton* bulletButton;
}

@end

@implementation EditDetailsViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [detailsTextView becomeFirstResponder];
}

- (IBAction) bulletButtonPressed {
    
    NSRange range = detailsTextView.selectedRange;
    NSString * firstHalfString = [detailsTextView.text substringToIndex:range.location];
    NSString * secondHalfString = [detailsTextView.text substringFromIndex: range.location];
    range.location = range.location + BULLET_CODE.length;
    
    
    detailsTextView.text = [NSString stringWithFormat:@"%@%@%@",firstHalfString,BULLET_CODE,secondHalfString];
    detailsTextView.selectedRange = range;
}

- (IBAction) save {
    if ([delegate respondsToSelector:@selector(hasSavedText:)])
        [delegate hasSavedText:self.textWithLinks];
    
    [self.navigationController popViewControllerAnimated:YES];
}



- (void) searchTextForHiperlinks {
    
    NSRange range = detailsTextView.selectedRange;
    
    NSMutableString* text = [[NSMutableString alloc] initWithString:detailsTextView.text];
    
    NSMutableAttributedString* attrText = [[NSMutableAttributedString alloc] initWithString:detailsTextView.text];
    
    [attrText beginEditing];
    
    [attrText addAttribute:(id)kCTFontAttributeName
                     value:detailsTextView.font
                     range:NSMakeRange(0, text.length)];
    
    NSError* error;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:HIPERLINKS_REGEX options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    if (matches.count) {
        
        DAAttributedStringFormatter* formatter = [[DAAttributedStringFormatter alloc] init];
        
        //Iterate through the matches and highlight them
        for (NSTextCheckingResult *match in matches)
        {
            NSRange matchRange = match.range;
            
            NSRange lastSpacelocation = [[text substringToIndex:match.range.location] rangeOfString:@" " options:NSBackwardsSearch];
            
            if (lastSpacelocation.location != NSNotFound) {
                matchRange = NSMakeRange(lastSpacelocation.location + 1, matchRange.location - lastSpacelocation.location - 1 + matchRange.length);
            } else {
                matchRange = NSMakeRange(0, matchRange.location + matchRange.length);
            }
            
            [attrText addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            [attrText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:matchRange];
            
            [text insertString:@"%l%u%b" atIndex:matchRange.location+matchRange.length];
            [text insertString:@"%B%1U%L" atIndex:matchRange.location];
            
        }
        
        
        [attrText endEditing];
        
        detailsTextView.attributedText = attrText;
        detailsTextView.selectedRange = range;
        
        _textWithLinks = [formatter formatString:text].mutableCopy;

        [_textWithLinks beginEditing];
        [_textWithLinks addAttribute:(id)kCTFontAttributeName
                            value:detailsTextView.font
                            range:NSMakeRange(0, _textWithLinks.length-1)];
        
        [_textWithLinks endEditing];
        
        
    }
}



#pragma mark UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    [self searchTextForHiperlinks];
}

@end
