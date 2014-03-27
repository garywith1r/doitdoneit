//
//  EditDetailsViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 3/27/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "EditDetailsViewController.h"

#define BULLET_CODE @"\u25CF "

@interface EditDetailsViewController () <UITextViewDelegate> {
    IBOutlet UITextView* detailsTextView;
    IBOutlet UIButton* bulletButton;
    IBOutlet UIButton* hiperlinkButton;
}

@end

@implementation EditDetailsViewController

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
    // Do any additional setup after loading the view.
}

- (IBAction) bulletButtonPressed {
    
    NSRange range = detailsTextView.selectedRange;
    NSString * firstHalfString = [detailsTextView.text substringToIndex:range.location];
    NSString * secondHalfString = [detailsTextView.text substringFromIndex: range.location];
    range.location = range.location + BULLET_CODE.length;
    
    
    detailsTextView.text = [NSString stringWithFormat:@"%@%@%@",firstHalfString,BULLET_CODE,secondHalfString];
    detailsTextView.selectedRange = range;
}

- (IBAction) hiperlinkButtonPressed {}

@end
