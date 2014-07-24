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
#import "NEODashboardBrowseCampaignsCell.h"
#import "NEOBrowseCampaignsController.h"

@interface NEODashboardController ()

@end

@implementation NEODashboardController


#pragma mark NavBar Methods

- (void)toggleDrawer
{
    NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate.drawer openSide] == MMDrawerSideLeft) {
        NSLog(@"%d %ld", (int)[delegate.drawer openSide], (long) MMDrawerSideLeft);
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
    

    // Register the NIB files for the dashboard cells
    UINib *nib = [UINib nibWithNibName:@"NEODashboardBrowseCampaignsCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"NEODashboardBrowseCampaignsCell"];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate enableDrawerAccess];
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
    
    NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate disableDrawerAccess];
    
    [[self navigationController] pushViewController:bcc animated:YES];
}

#pragma mark TableViewDelegate Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3; //Stats, profile, (one) post
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NEODashboardBrowseCampaignsCell *bcc = [tableView
                         dequeueReusableCellWithIdentifier:@"NEODashboardBrowseCampaignsCell" forIndexPath:indexPath];

    [bcc.browseButton addTarget:self action:@selector(browseCampaigns:) forControlEvents:UIControlEventTouchUpInside];
    return bcc;
}


@end
