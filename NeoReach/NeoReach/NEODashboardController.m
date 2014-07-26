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

#import "NEODashboardHeaderCell.h"
#import "NEODashboardStatsCell.h"
#import "NEODashboardPostCell.h"



@interface NEODashboardController ()
@property (strong, nonatomic) NEODashboardHeaderCell *tableHeader;
@end

@implementation NEODashboardController


#pragma mark NavBar Methods

- (void)toggleDrawer
{
    NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate.drawer openSide] == MMDrawerSideLeft) {
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
    UINib *prcNib = [UINib nibWithNibName:@"NEODashboardHeaderCell" bundle:nil];
    UINib *scNib = [UINib nibWithNibName:@"NEODashboardStatsCell" bundle:nil];
    UINib *pocNib = [UINib nibWithNibName:@"NEODashboardPostCell" bundle:nil];

    [self.tableView registerNib:prcNib forCellReuseIdentifier:@"NEODashboardHeaderCell"];
    [self.tableView registerNib:scNib forCellReuseIdentifier:@"NEODashboardStatsCell"];

    [self.tableView registerNib:pocNib forCellReuseIdentifier:@"NEODashboardPostCell"];
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
    return 30; //Stats, (29) posts
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 200.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NEODashboardHeaderCell *hc = [tableView dequeueReusableCellWithIdentifier:@"NEODashboardHeaderCell" forIndexPath:nil];
    
    hc.profileImage.image = [UIImage imageNamed:@"juliana.png"];
    [hc.browseButton addTarget:self action:@selector(browseCampaigns:) forControlEvents:UIControlEventTouchUpInside];
    _tableHeader = hc;
    return hc;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat height = 0.0;
    
    switch (indexPath.row) {
        case 0: // stats
            height = screenHeight / 4;
            break;
        default: // posts
            height = screenHeight / 12;
    }
    
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0: //stats
        {
            NEODashboardStatsCell *sc = [tableView
                                         dequeueReusableCellWithIdentifier:@"NEODashboardStatsCell"
                                         forIndexPath:indexPath];
            cell = (UITableViewCell *)sc;
            break;
        }
        default:
        {
            NEODashboardPostCell *poc = [tableView
                                         dequeueReusableCellWithIdentifier:@"NEODashboardPostCell"
                                         forIndexPath:indexPath];
            cell = (UITableViewCell *)poc;
            break;
        }
            
    }

    return cell;
}

@end
