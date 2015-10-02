//
//  HackSilverAppDelegate.h
//  HackSilver
//
//  Created by Matthew French on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenu.h"

@class AppDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    MainMenu *mainMenu;
}

@property (strong, nonatomic) UIWindow *window;

@end
