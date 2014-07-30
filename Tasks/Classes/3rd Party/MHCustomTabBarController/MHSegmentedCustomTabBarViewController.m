//
//  MHSegmentedCustomTabBarViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 7/24/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "MHSegmentedCustomTabBarViewController.h"

#define BORDER_COLOR [UIColor colorWithRed:255/255.0 green:244/255.0 blue:0/255.0 alpha:1]
#define SELECTED_BACKGROUND_COLOR [UIColor colorWithRed:255/255.0 green:244/255.0 blue:0/255.0 alpha:1]

@interface MHSegmentedCustomTabBarViewController () {
    NSMutableArray* layersArray;
    UIButton* selectedButton;
}

@end

@implementation MHSegmentedCustomTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    layersArray = [[NSMutableArray alloc] initWithCapacity:self.buttons.count];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    for (UIButton* button in self.buttons)
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.buttons.count)
        [self buttonSelected:self.buttons[0]];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.destinationViewController.view setNeedsDisplay];
    [super viewDidAppear:animated];
    [self orientationChanged:nil];
}

- (void) orientationChanged:(NSNotification *)note {
    [self maskButtons];
    [self buttonSelected:selectedButton];
}

- (void) maskButtons {
    for (CAShapeLayer* layer in layersArray) {
        [layer removeFromSuperlayer];
    }
    
    [layersArray removeAllObjects];
    
    for (int x = 0; x< self.buttons.count; x++) {
        
        UIButton* button = self.buttons[x];
        
        //
        // Create your mask first
        //
        UIRectCorner corners = 0;
        if (x == 0)
            corners = UIRectCornerBottomLeft|UIRectCornerTopLeft;
            
        else if (x == self.buttons.count-1)
            corners = UIRectCornerBottomRight|UIRectCornerTopRight;
        
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds
                                                       byRoundingCorners:corners
                                                             cornerRadii:CGSizeMake(6.0f, 6.0f)];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = button.bounds;
        maskLayer.path = maskPath.CGPath;
        button.layer.mask = maskLayer;
        
        //
        // And then create the outline layer
        //
        CAShapeLayer *shape = [CAShapeLayer layer];
        shape.frame = button.bounds;
        shape.path = maskPath.CGPath;
        shape.lineWidth = 3.0f;
        shape.fillColor = [UIColor clearColor].CGColor;
        shape.strokeColor = BORDER_COLOR.CGColor;
        [button.layer addSublayer:shape];
        [layersArray addObject:shape];
    }
}

- (IBAction)buttonSelected:(UIButton*)pressedButton {
    for (UIButton* button in self.buttons) {
        if (button == pressedButton)
            [button setBackgroundColor:SELECTED_BACKGROUND_COLOR];
        else
            [button setBackgroundColor:[UIColor clearColor]];
    }
    
    selectedButton = pressedButton;
}
@end
