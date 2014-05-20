//
//  EditDetailsViewController.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 3/27/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskDTO.h"
//regex from http://stackoverflow.com/questions/4390556/extract-url-from-string
#define HIPERLINKS_REGEX @"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))"

@interface EditDetailsViewController : UIViewController

@property (nonatomic, strong) TaskDTO* dto;

@end
