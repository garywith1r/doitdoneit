//
//  MediaModel.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 2/27/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaModel : NSObject

+ (void) postMessageToFacebook:(NSString*)message;
+ (void)postMessageToTwitter:(NSString*)message;

@end
