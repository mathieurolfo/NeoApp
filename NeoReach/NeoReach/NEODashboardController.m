//
//  NEODashboardController.m
//  NeoReach
//
//  Created by Sam Crognale on 7/21/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEODashboardController.h"
#import <MMDrawerBarButtonItem.h>
#import "NEOAppDelegate.h"
#import "NEOBrowseCampaignsController.h"

@interface NEODashboardController ()

@end

@implementation NEODashboardController


#pragma mark NavBar Methods

- (void)toggleDrawer
{
    NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate.drawer openSide] == MMDrawerSideLeft) {
        NSLog(@"%d %d", [delegate.drawer openSide], MMDrawerSideLeft);
        [delegate.drawer closeDrawerAnimated:YES completion:nil];
    } else if ([delegate.drawer openSide] == MMDrawerSideNone) {
        [delegate.drawer openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
}

#pragma mark Default Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Dashboard";
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        MMDrawerBarButtonItem *lbbi = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(toggleDrawer)];
        
        navItem.leftBarButtonItem = lbbi;
    }
    
    return self;
}


#pragma mark Dashboard Methods

- (IBAction)browseCampaigns:(id)sender {
    NEOBrowseCampaignsController *bcc = [[NEOBrowseCampaignsController alloc] init];
    
    [[self navigationController] pushViewController:bcc animated:YES];
    
}

@end
