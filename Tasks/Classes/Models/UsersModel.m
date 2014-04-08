//
//  UsersModel.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/8/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "UsersModel.h"
#import "EGOFileManager.h"

@interface UsersModel () {
    NSArray* storedUsers;
    NSDictionary* logedUser;
    NSMutableDictionary* logedUserData;
    
    NSInteger logedUserIndex;
}

@end

@implementation UsersModel

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
    NSMutableDictionary* userDictionary = [NSMutableDictionary dictionaryWithDictionary:userData];
    NSString* path = [EGOFileManager getAvailablePath];
    [userDictionary setObject:path forKey:@"UsersDataPath"];
    
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:storedUsers];
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
