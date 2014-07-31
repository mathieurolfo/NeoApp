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

    [self loadProfileInformation];
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    }); */
    
    }

-(void)loadProfileInformation
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //NeoReach API protocol
    NSString *testXAuth = @"53d6b32fbedda4bd15649f59";
    NSString *testXDigest = @"BbgtaMoTDepnHFahq3YVGZ3Kjmjda96q";
    config.HTTPAdditionalHeaders = @{@"X-Auth":testXAuth,
                                     @"X-Digest":testXDigest};
    
    //should there be a delegate for this?
    _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    
    //creating URL for the actual request
    //NSString *requestString = @"https://api.neoreach.com/account";
    NSString *requestString = @"https://api.neoreach.com/campaigns?skip=0&limit=10";
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSLog(@"making call to NeoReach server");
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        //load response into a dictionary
        NSDictionary *profileJSON =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        delegate.userProfileDictionary = [[NSMutableDictionary alloc] initWithDictionary:profileJSON copyItems:YES];
        
        NSLog(@"%@", delegate.userProfileDictionary);
        //NSLog(@"%@", [profileJSON valueForKeyPath:@"data.Profile.name"]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    [dataTask resume];
    
    

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

  	NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
  	NSLog(@"inside dashboard");
	
  	NSString *string = [[delegate.userProfileDictionary valueForKeyPath:@"data.Profile.name.first"] objectAtIndex:0];
	NSLog(@"onamae wa %@", string);

	
  	NSString *username = [NSString stringWithFormat:@"%@ %@", [[delegate.userProfileDictionary valueForKeyPath:@"data.Profile.name.first"] objectAtIndex:0], [[delegate.userProfileDictionary valueForKeyPath:@"data.Profile.name.last"] objectAtIndex:0]];
            
            hc.nameLabel.text = username;



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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView reloadData];
}

@end
