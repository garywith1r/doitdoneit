//
//  EditDetailsViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 3/27/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "EditDetailsViewController.h"
#import <CoreText/CTStringAttributes.h>

#import "Constants.h"


#define BULLET_TEXT @"\\*"
#define BULLET_CODE @"\u25CF "
//regex from http://stackoverflow.com/questions/4390556/extract-url-from-string
#define HIPERLINKS_REGEX @"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))"

@interface EditDetailsViewController () <UITextViewDelegate> {
    IBOutlet UITextView* detailsTextView;
    IBOutlet UILabel* tipsLabel;
    
    NSMutableArray* linksOnText;
}

@end

@implementation EditDetailsViewController
@synthesize dto;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [detailsTextView becomeFirstResponder];
    
    if (dto.detailsLinksArray)
        linksOnText = [[NSMutableArray alloc] initWithArray:dto.detailsLinksArray];
    else
        linksOnText = [[NSMutableArray alloc] init];
    
    detailsTextView.attributedText = dto.detailsText;
    
    tipsLabel.layer.borderColor = YELLOW_COLOR.CGColor;
    tipsLabel.layer.borderWidth = 2.0;
}


- (IBAction) doneButtonPressed {
    
    dto.detailsText = detailsTextView.attributedText;
    dto.detailsLinksArray = [NSArray arrayWithArray:linksOnText];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) searchTextForHiperlinks {
    
    NSRange range = detailsTextView.selectedRange;
    
    NSString* text = detailsTextView.text;
    
    NSError* error;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:HIPERLINKS_REGEX options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    [linksOnText removeAllObjects];
    
    if (matches.count) {
        
        //Iterate through the matches and highlight them
        NSMutableArray* attributesArray = [[NSMutableArray alloc] initWithCapacity:matches.count * 2];
        for (int x = 0; x < matches.count; x++)
        {
            NSRange matchRange = ((NSTextCheckingResult*)matches[x]).range;
            
            NSNumber* location = [NSNumber numberWithInteger:matchRange.location];
            NSNumber* lenght = [NSNumber numberWithInteger:matchRange.length];
            
            [attributesArray addObject:@{@"attribute":NSForegroundColorAttributeName,@"value":YELLOW_COLOR,@"location":location,@"length":lenght}];
            
        }
        
        
        NSMutableAttributedString* attrText = [[NSMutableAttributedString alloc] initWithString:text];
        [attrText beginEditing];
        
        //add default font.
        [attrText addAttribute:(id)kCTFontAttributeName
                         value:detailsTextView.font
                         range:NSMakeRange(0, attrText.length)];
        
        //add attributes to the links
        for (NSDictionary* attributeDicc in attributesArray) {
            
            [attrText addAttribute:[attributeDicc objectForKey:@"attribute"]
                             value:[attributeDicc objectForKey:@"value"]
                             range:NSMakeRange([[attributeDicc objectForKey:@"location"] intValue], [[attributeDicc objectForKey:@"length"] intValue])];
        }
        
        
        
        [attrText endEditing];
        
        
        detailsTextView.attributedText = attrText;
        detailsTextView.selectedRange = range;
    }
}



#pragma mark UITextViewDelegate Methods
- (void)textViewDidChange:(UITextView *)textView {
    
    textView.text = [textView.text stringByReplacingOccurrencesOfString:BULLET_TEXT withString:BULLET_CODE];
    [self searchTextForHiperlinks];
}

@end
