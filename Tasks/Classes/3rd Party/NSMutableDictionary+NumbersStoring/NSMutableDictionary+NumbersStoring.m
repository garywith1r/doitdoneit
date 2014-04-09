//
//  NSMutableDictionary+NumbersStoring.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/9/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "NSMutableDictionary+NumbersStoring.h"

@implementation NSMutableDictionary (NumbersStoring)

- (void) setInteger:(NSInteger)integer forKey:(NSString *)key {
    NSNumber* number = [NSNumber numberWithInteger:integer];
    [self setObject:number forKey:key];
}

- (NSInteger) integerForKey:(NSString*)key {
    NSNumber* number = [self objectForKey:key];
    return [number integerValue];
}


- (void) setFloat:(CGFloat)integer forKey:(NSString *)key {
    NSNumber* number = [NSNumber numberWithFloat:integer];
    [self setObject:number forKey:key];
}

- (CGFloat) floatForKey:(NSString*)key {
    NSNumber* number = [self objectForKey:key];
    return [number floatValue];
}

@end
