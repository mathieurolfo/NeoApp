//
//  NEOAppDelegate.h
//  NeoReach
//
//  Created by Sam Crognale on 7/10/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MMDrawerController/MMDrawerController.h>
#import "NEOLoginController.h"


@interface NEOAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MMDrawerController *drawer;
@property (strong, nonatomic) UINavigationController *rootNav;
@property (strong, nonatomic) NEOLoginController *login;
@property (strong, nonatomic) NSMutableDictionary *userProfileDictionary;


-(void)enableDrawerAccess;
-(void)disableDrawerAccess;

@end
