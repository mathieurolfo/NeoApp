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

#import "NEOUser.h"


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
    NSLog(@"view did load");
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

}


-(void)loadProfileInformation
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.sessionConfig;
    _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    
    NSString *requestString = @"https://api.neoreach.com/account";
    NSURL *url = [NSURL URLWithString:requestString];
    NSLog(@"making profile info request");
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        //load response into a dictionary
        NSDictionary *profileJSON =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        NSLog(@"populating user profile dick");
        [self populateUserProfileWithDictionary:profileJSON];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            delegate.webView = nil;
            NSLog(@"Webview deleted");
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NEODashboardHeaderCell *hc = [tableView dequeueReusableCellWithIdentifier:@"NEODashboardHeaderCell" forIndexPath:nil];
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    
    
    if (user.firstName && user.lastName) {
        hc.nameLabel.text = [NSString stringWithFormat:@"%@ %@",
                             user.firstName, user.lastName];

    } else {
        hc.nameLabel.text = @"Loading name...";
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

-(void)populateUserProfileWithDictionary:(NSDictionary *)dict
{
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    
    //Most profile information is in data.Profile[0]
    NSDictionary *profileDict = [[[dict objectForKey:@"data"] objectForKey:@"Profile"] objectAtIndex:0];
    
    user.firstName = [profileDict valueForKeyPath:@"name.first"];
    user.lastName = [profileDict valueForKeyPath:@"name.last"];

    
    //Profile picture URL is in the 'facebook.com' entry of data.Publishers
    NSArray *publishers = [[dict objectForKey:@"data"] objectForKey:@"Publishers"];
    
    for (int i=0; i < [publishers count]; i++) {
        NSDictionary *publisher = [publishers objectAtIndex:i];
        NSString *publisherName = [publisher valueForKeyPath:@"name"];
        if ([publisherName isEqualToString:@"facebook.com"]) {
            user.profilePictureURL = [publisher valueForKeyPath:@"pic"];
            user.profilePicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user.profilePictureURL]]];
            break;
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // We only support single touches, so anyObject retrieves just that touch from touches
    UITouch *touch = [touches anyObject];
    NSLog(@"view %i", [touch view].tag);
}




@end
