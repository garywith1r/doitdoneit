//
//  DeviceDetector.h
//  Utilities
//
//  Created by Gonzalo Hardy on 6/27/13.
//  Copyright (c) 2013 GoNXaS. All rights reserved.
//

#import "DeviceDetector.h"

@implementation DeviceDetector

+ (BOOL)isPhone
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}

+ (BOOL)isPad
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

@end
