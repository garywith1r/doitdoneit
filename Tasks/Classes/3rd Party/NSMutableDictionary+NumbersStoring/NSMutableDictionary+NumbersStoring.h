//
//  NSMutableDictionary+NumbersStoring.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/9/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (NumbersStoring)

- (void) setInteger:(NSInteger)integer forKey:(NSString *)key;

- (NSInteger) integerForKey:(NSString*)key;


- (void) setFloat:(CGFloat)integer forKey:(NSString *)key;

- (CGFloat) floatForKey:(NSString*)key;

@end
