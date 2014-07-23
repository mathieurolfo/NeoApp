//
//  NEOLoginController.m
//  NeoReach
//
//  Created by Sam Crognale on 7/21/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOLoginController.h"
#import "NEODashboardController.h"
#import "NEOAppDelegate.h"

@interface NEOLoginController ()

@end

@implementation NEOLoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.logInOutInfoLabel.text = @"";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logInPressed:(id)sender {
    NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.rootNav) {
        NEODashboardController *dashboard = [[NEODashboardController alloc] init];
        delegate.rootNav = [[UINavigationController alloc] initWithRootViewController:dashboard];
    }
    
    delegate.drawer.centerViewController = delegate.rootNav;
    delegate.drawer.openDrawerGestureModeMask = MMOpenDrawerGestureModeBezelPanningCenterView |
                                                MMOpenDrawerGestureModePanningNavigationBar;
    
    delegate.drawer.closeDrawerGestureModeMask = MMCloseDrawerGestureModeTapCenterView |
                                                 MMCloseDrawerGestureModePanningDrawerView |
                                                 MMCloseDrawerGestureModePanningCenterView |
                                                 MMCloseDrawerGestureModeTapNavigationBar |
                                                 MMCloseDrawerGestureModePanningNavigationBar;
    
}



@end
