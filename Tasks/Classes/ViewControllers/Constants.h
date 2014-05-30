//
//  Constants.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 2/26/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#define TASK_TITLE_MAX_CHARACTERS 140
#define TASK_NOTE_MAX_CHARACTERS 100
#define GOAL_DESCRIPTION_MAX_CHARACTERS 140
#define KEYBOARD_SIZE (216 - 49) // keyboard height - tabbar height

#define ONE_DAY 86400

#define IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


#define YELLOW_COLOR [UIColor colorWithRed:255/255.0 green:244/255.0 blue:0/255.0 alpha:1]
#define DARK_GRAY_COLOR [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1]
#define GRAY_COLOR [UIColor colorWithRed:99/255.0 green:99/255.0 blue:99/255.0 alpha:1]

#define PARENTS_CODE_DIGITS 4

#define FEEDBACK_EMAIL_RECIPIENT @"support@doitdoneitapp.com"
#define FEEDBACK_EMAIL_SUBJECT @"Do It Done It Feedback"
#define FEEDBACK_EMAIL_BODY @""

#define DEFAULT_USER_IMAGE [UIImage imageNamed:@"default_user.jpg"]
#define DEFAULT_TASK_IMAGE [UIImage imageNamed:@"default_task.jpg"]


#define FIRST_ALARM_TIME 10  * 3600
#define SECOND_ALARM_TIME 14  * 3600


#define DEFAULT_GOAL_POINTS 100
#define DEFAULT_GOAL_TEXT @"Climb every mountain,\nFord every stream,\nFollow every rainbow,\n'Till you find your dream."
#define DEFAULT_TASK_1_TITLE @"Sample Task 1"
#define DEFAULT_TASK_1_DESCRIPTION @"Every task has a title (limited to x characters) and a long description which can include links to websites (e.g. http://google.com), bullet points and in future other formatting capabilities. Clicking the links will bring up a browser. You can also attach an image or video from your media library. Tapping on the image from the 'Do It' list will enlarge the picture or play the video. Here are 3 more links to play with:\n\n● http://bing.com\n● http://ebay.com\n● http://apple.com"
#define DEFAULT_TASK_2_TITLE @"Sample Task 2"
#define DEFAULT_TASK_2_DESCRIPTION @"Slide the row from the right to left to show the 3 actions: copy, edit and delete. You can practice on this task."
#define DEFAULT_TASK_3_TITLE @"Sample Task 3"
#define DEFAULT_TASK_3_DESCRIPTION @"This task contains a short video. You can change this to one of your own."