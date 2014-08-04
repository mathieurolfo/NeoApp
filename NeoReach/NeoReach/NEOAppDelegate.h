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
#import "NEOUser.h"
#import "NEOWebViewController.h"

@interface NEOAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MMDrawerController *drawer;
@property (strong, nonatomic) UINavigationController *rootNav;
@property (strong, nonatomic) NEOLoginController *login;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NEOUser *user;
@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfig;


-(void)enableDrawerAccess;
-(void)disableDrawerAccess;


@end
