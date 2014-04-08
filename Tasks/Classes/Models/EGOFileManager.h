//
//  EGOFileManager.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/7/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EGOFileManager : NSObject

+ (UIImage*) getImageFromPath:(NSString*)path;
+ (NSData*) getDataFromPath:(NSString*)path;

+ (NSString*) storeImage:(UIImage*)image;
+ (NSString*) storeData:(NSData*)data;

+ (NSString*) getAvailablePath;
+ (void) deleteContentAtPath:(NSString*)path;

@end
