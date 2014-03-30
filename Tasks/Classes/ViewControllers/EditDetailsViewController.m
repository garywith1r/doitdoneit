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
#define HIPERLINKS_REGEX @"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))"

@interface EditDetailsViewController () <UITextViewDelegate> {
    IBOutlet UITextView* detailsTextView;
    IBOutlet UIButton* bulletButton;
    
    NSMutableArray* linksOnText;
}

@end

@implementation EditDetailsViewController
@synthesize dto;

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
    
    if (dto.detailsLinksArray)
        linksOnText = [[NSMutableArray alloc] initWithArray:dto.detailsLinksArray];
    else
        linksOnText = [[NSMutableArray alloc] init];
    
    detailsTextView.attributedText = dto.detailsText;
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
    
    dto.detailsText = detailsTextView.attributedText;
    dto.detailsLinksArray = [NSArray arrayWithArray:linksOnText];
    
    [self.navigationController popViewControllerAnimated:YES];
}



- (void) searchTextForHiperlinks {
    
    NSRange range = detailsTextView.selectedRange;
    
    NSMutableString* text = [[NSMutableString alloc] initWithString:detailsTextView.text];
    
    NSError* error;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:HIPERLINKS_REGEX options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    [linksOnText removeAllObjects];
    
    if (matches.count) {
        
        DAAttributedStringFormatter* formatter = [[DAAttributedStringFormatter alloc] init];
        formatter.colors = @[[UIColor blackColor], [UIColor blueColor]];
        
        //Iterate through the matches and highlight them
        NSMutableArray* attributesArray = [[NSMutableArray alloc] initWithCapacity:matches.count * 2];
        for (int x = 0; x < matches.count; x++)
        {
            NSRange matchRange = ((NSTextCheckingResult*)matches[x]).range;
            
            NSNumber* location = [NSNumber numberWithInt:matchRange.location];
            NSNumber* lenght = [NSNumber numberWithInt:matchRange.length];
            
            /* we'll add attributes to both texts at the end, because the mutable attributed string returned by the DAAttributedStringFormatter can't be stored with colour / underline attributes, so we'll use the standar ones.
             */
            [attributesArray addObject:@{@"attribute":NSForegroundColorAttributeName,@"value":[UIColor blueColor],@"location":location,@"length":lenght}];
            [attributesArray addObject:@{@"attribute":NSUnderlineStyleAttributeName,@"value":[NSNumber numberWithInt:1],@"location":location,@"length":lenght}];
            
            
            //have to fix the location because we're adding text for each link. 8 is the amount of characters added per link.
            matchRange.location = matchRange.location + 8*x;
            
            [linksOnText addObject: [text substringWithRange:matchRange]];
            
            [text insertString:@"%l%b" atIndex:matchRange.location+matchRange.length];
            [text insertString:@"%B%L" atIndex:matchRange.location];

            
        }
        
        
        
        
        NSMutableAttributedString* attrText = [formatter formatString:text].mutableCopy;
        

        [attrText beginEditing];
        
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
    [self searchTextForHiperlinks];
}

@end
