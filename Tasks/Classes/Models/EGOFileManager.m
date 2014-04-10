//
//  EGOFileManager.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/7/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "EGOFileManager.h"
#import "EGOCache.h"

@implementation EGOFileManager


+ (UIImage*) getImageFromPath:(NSString*)path {
    if (path && ![@"" isEqualToString:path]) {
        EGOCache* cache = [EGOCache globalCache];
        UIImage* image = [cache imageForKey:path];
        
        if (image) //cache hit.
            return image;
        
        image = [UIImage imageWithData:[[NSFileManager defaultManager] contentsAtPath:path]];
        if (image)
            [cache setObject:image forKey:path];
        
        return image;
    } else {
        return nil;
    }
}

+ (NSData*) getDataFromPath:(NSString*)path {
    if (path && ![@"" isEqualToString:path]) {
        EGOCache* cache = [EGOCache globalCache];
        NSData* data = [cache dataForKey:path];
        
        if (data) //cache hit.
            return data;
        
        data = [[NSFileManager defaultManager] contentsAtPath:path];
        [cache setObject:data forKey:path];
        
        return data;
    } else {
        return nil;
    }
}

+ (NSString*) storeImage:(UIImage*)image {
    if (image) {
        NSData *dataForPNGFile = UIImagePNGRepresentation(image);
        return [EGOFileManager storeData:dataForPNGFile];
    } else {
        return nil;
    }
}

+ (NSString*) storeData:(NSData*)data {
    if (data) {
        NSString* path = [EGOFileManager getAvailablePath];
        [self storeData:data onPath:path];
        return path;
    } else {
        return nil;
    }
}

+ (void) storeData:(NSData*)data onPath:(NSString*)path {
    if (data) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    }
}

+ (NSString*) getAvailablePath {
    NSString* filePath = @"";
    
    do {
        NSString* completeFileName = [NSString stringWithFormat:@"%u.MOV",arc4random()];
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:completeFileName];
    } while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    
    return filePath;
}

+ (void) deleteContentAtPath:(NSString*)path {
    if (path && ![@"" isEqualToString:path]) {
        [[EGOCache globalCache] removeCacheForKey:path];
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        
        if (error) {
            NSLog(@"Error deleting file at path: %@: %@",path,error.description);
        }
    }
}

@end
