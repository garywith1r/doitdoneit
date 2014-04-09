//
//  UsersModel.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/8/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "UsersModel.h"
#import "EGOFileManager.h"

#define LOGGED_USER_PATH_KEY @"UsersDataPath"

@interface UsersModel () {
    NSArray* storedUsers;
    NSMutableDictionary* logedUserData;
    
    NSInteger logedUserIndex;
}

@end

@implementation UsersModel
@synthesize logedUser;

UsersModel* userModelInstance;

+ (UsersModel*) sharedInstance {
    if (userModelInstance)
        return userModelInstance;
    
    userModelInstance = [[UsersModel alloc] init];
    return userModelInstance;
}

- (NSArray*) getUsers {
    if (storedUsers)
        return storedUsers;
    
    storedUsers = [[NSUserDefaults standardUserDefaults] objectForKey:@"storedUsersArray"];
    return storedUsers;
}

- (void) addUser:(NSDictionary*)userData {
    
    NSString* path = [userData objectForKey:@"UsersDataPath"];
    NSMutableDictionary* userDictionary = [NSMutableDictionary dictionaryWithDictionary:userData];
    
    NSDictionary* oldUserData = nil;
    
    if (!path || [path isEqualToString:@""]) {
        path = [EGOFileManager getAvailablePath];
        [userDictionary setObject:path forKey:@"UsersDataPath"];
        
    } else {
        for (NSDictionary* userDictionary in storedUsers) {
            if ([[userDictionary objectForKey:LOGGED_USER_PATH_KEY] isEqualToString:path]) {
                oldUserData = userDictionary;
                break;
            }
        }
    }
    
        
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:storedUsers];
    [tempArray removeObject:oldUserData];
    [tempArray addObject:[NSDictionary dictionaryWithDictionary:userDictionary]];
    
    storedUsers = [NSArray arrayWithArray:tempArray];
    [self saveUsersArray];
}

- (void) saveUsersArray {
    [[NSUserDefaults standardUserDefaults] setObject:storedUsers forKey:@"storedUsersArray"];
}

- (void) saveCurrentUserData {
    NSData * encodedData = [NSKeyedArchiver archivedDataWithRootObject:logedUserData];
    [EGOFileManager storeData:encodedData onPath:[logedUser objectForKey:@"UsersDataPath"]];
}

- (void) changeToUserAtIndex:(NSInteger)index {
    logedUser = storedUsers[index];
    NSData* data = [EGOFileManager getDataFromPath:[logedUser objectForKey:@"UsersDataPath"]];
    logedUserData = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    logedUserIndex = index;
}

@end
