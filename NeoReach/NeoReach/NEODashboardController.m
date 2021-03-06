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
#import "UIWebView+Clean.h"
#import "NEOUser.h"
#import "NEOCampaign.h"


@interface NEODashboardController ()
@property (strong, nonatomic) NEODashboardHeaderCell *tableHeader;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *currentCampaigns;
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

    _refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(controlInitRefreshDashboard) forControlEvents:UIControlEventValueChanged];

    // Register the NIB files for the dashboard cells
    UINib *prcNib = [UINib nibWithNibName:@"NEODashboardHeaderCell" bundle:nil];
    UINib *scNib = [UINib nibWithNibName:@"NEODashboardStatsCell" bundle:nil];
    UINib *pocNib = [UINib nibWithNibName:@"NEODashboardPostCell" bundle:nil];

    
    [self.tableView registerNib:prcNib forCellReuseIdentifier:@"NEODashboardHeaderCell"];
    [self.tableView registerNib:scNib forCellReuseIdentifier:@"NEODashboardStatsCell"];

    [self.tableView registerNib:pocNib forCellReuseIdentifier:@"NEODashboardPostCell"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDashboard) name:@"profileUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(campaignsPulledOrUpdated) name:@"campaignsPulled" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(campaignsPulledOrUpdated) name:@"campaignURLGenerated" object:nil];


    [self updateCurrentCampaigns];
    
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.user pullCampaigns];
    delegate.rootNav.navigationBar.translucent = NO;
    [delegate.rootNav.navigationBar setTitleTextAttributes:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [UIFont fontWithName:@"Lato-Hairline" size:18.0], NSFontAttributeName, nil]];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
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
        NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Dashboard";
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        MMDrawerBarButtonItem *lbbi = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(toggleDrawer)];
        
        navItem.leftBarButtonItem = lbbi;
        delegate.rootNav.navigationBar.translucent = NO;
        }
    return self;
}

#pragma mark Dashboard Methods

/* This method initiates a refreshing of the dashboard by pulling down on the dashboard. It calls the pullProfileInfo method, which pulls data from the server then issues a notification to call refreshDashboard, which actually reloads the table view.
 */
-(void)controlInitRefreshDashboard
{
    [self.refreshControl endRefreshing];
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.user pullProfileInfo];
    [delegate.user pullCampaigns];
}

-(void)campaignsPulledOrUpdated
{
    [self updateCurrentCampaigns];
    [self refreshDashboard];
}

-(void)updateCurrentCampaigns {
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    _currentCampaigns = [[NSMutableArray alloc] initWithArray:user.campaigns];
    
    NSMutableArray *futureCampaigns = [[NSMutableArray alloc] init];
    for (int i = 0; i < [_currentCampaigns count]; i++) {
        NEOCampaign *campaign = _currentCampaigns[i];
        if (campaign.referralURL == nil) {
            [futureCampaigns addObject:campaign];
        }
    }
    [_currentCampaigns removeObjectsInArray:futureCampaigns];
}

-(void)refreshDashboard
{
    [self.tableView reloadData];
    
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.webView cleanForDealloc];
    
    delegate.webView = nil;
}

- (IBAction)browseCampaigns:(id)sender {
    NEOBrowseCampaignsController *bcc = [[NEOBrowseCampaignsController alloc] init];
    
    NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate disableDrawerAccess];
    
    [[self navigationController] pushViewController:bcc animated:YES];
}

-(void)forceUpdateProfile
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UIAlertView *newAccountAlert = [[UIAlertView alloc] initWithTitle:@"Welcome!" message:@"Please fill in some account information to get started with NeoReach." delegate:delegate.drawer.leftDrawerViewController cancelButtonTitle:nil otherButtonTitles:@"Edit Profile", nil];
    [newAccountAlert show];
}

#pragma mark TableViewDelegate Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + [_currentCampaigns count]; //Stats, posts
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 150.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NEODashboardHeaderCell *hc = [tableView dequeueReusableCellWithIdentifier:@"NEODashboardHeaderCell" forIndexPath:nil];
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    
    if (user.firstName && user.lastName) {
        hc.nameLabel.text = [NSString stringWithFormat:@"%@ %@",
                             user.firstName, user.lastName];
        //hc.nameLabel.textColor = [UIColor whiteColor];
        

    } else {
        hc.nameLabel.text = @"Loading...";
    }
        
    if (user.profilePicture) {
        hc.profileImage.image = user.profilePicture;
    } else {
        // What to display before profile picture is loaded?
    }

    [hc.browseButton addTarget:self action:@selector(browseCampaigns:) forControlEvents:UIControlEventTouchUpInside];
    _tableHeader = hc;
    
    
    return hc;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    switch (indexPath.row) {
        case 0: // stats
            height = 160.0;
            break;
        default: // posts
            height = 40.0;
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
            NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
            sc.totalClicksLabel.text = [NSString stringWithFormat:@"\u25B2%lu", (unsigned long)user.totalClicks];
            sc.totalEarningsLabel.text = [NSString stringWithFormat:@"$%.02f",user.totalEarnings];
            
            cell = (UITableViewCell *)sc;
            break;
        }
        default:
        {
            NEODashboardPostCell *poc = [tableView
                                         dequeueReusableCellWithIdentifier:@"NEODashboardPostCell"
                                         forIndexPath:indexPath];
            NEOCampaign *campaign = _currentCampaigns[indexPath.row - 1];
            poc.campaignLabel.text = campaign.name;
            poc.clicksLabel.text = [NSString stringWithFormat:@"\u25B2%lu",(unsigned long)campaign.totalClicks];
            
            poc.campaignLabel.font = [UIFont fontWithName:@"Lato-Light" size:16.0];
            
            cell = (UITableViewCell *)poc;
            break;
        }
            
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView reloadData];
}


@end
