//
//  TopLeftLabel.m
//  NearEducation
//
//  Created by German Marquez on 02/08/12.
//
//

#import "TopLeftLabel.h"

@implementation TopLeftLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) drawTextInRect:(CGRect)inFrame {
    CGRect      draw = [self textRectForBounds:inFrame limitedToNumberOfLines:[self numberOfLines]];
    
    draw.origin = CGPointZero;
    
    [super drawTextInRect:draw];
}

@end
