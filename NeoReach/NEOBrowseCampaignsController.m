//
//  NEOBrowseCampaignsController.m
//  NeoReach
//
//  Created by Sam Crognale on 7/21/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOBrowseCampaignsController.h"
#import "NEOBrowseLogosCell.h"
#import "NEOBrowseDetailsCell.h"
#import "NEOBrowseGenLinkCell.h"

#import "NEOAppDelegate.h"

#import "NEOCampaign.h"

@interface NEOBrowseCampaignsController ()
@property NSUInteger campaignIndex;
@property NSMutableArray *campaigns;
@property bool campaignsLoaded; // Need this to differentiate between 0 campaigns and campaigns loading
@end

@implementation NEOBrowseCampaignsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;        navItem.title = @"Browse";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    _campaigns = [[NSMutableArray alloc] init];
    _campaignIndex = 0;
    _campaignsLoaded = NO;
    
    // Register the NIB files for the browse campaign cells
    UINib *lcNib = [UINib nibWithNibName:@"NEOBrowseLogosCell" bundle:nil];
    UINib *dcNib = [UINib nibWithNibName:@"NEOBrowseDetailsCell" bundle:nil];
    UINib *glcNib = [UINib nibWithNibName:@"NEOBrowseGenLinkCell" bundle:nil];
    
    [self.tableView registerNib:lcNib forCellReuseIdentifier:@"NEOBrowseLogosCell"];
    [self.tableView registerNib:dcNib forCellReuseIdentifier:@"NEOBrowseDetailsCell"];
    [self.tableView registerNib:glcNib forCellReuseIdentifier:@"NEOBrowseGenLinkCell"];
    
    [self loadCampaigns];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3; //Logo, details, generate link
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat height = 0.0;
    
    switch (indexPath.row) {
        case 0: // Logo
            height = screenHeight / 3;
            break;
        case 1: // Details
            height = screenHeight / 3;
            break;
        case 2: // Generate link
            height = screenHeight / 12;
            break;
        default: // ?
            height = 0.0;
    }
    
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
        {
            NEOBrowseLogosCell *lc = [tableView
                                      dequeueReusableCellWithIdentifier:@"NEOBrowseLogosCell"
                                      forIndexPath:indexPath];
            
            [lc.nextButton addTarget:self action:@selector(goToNextCampaign:) forControlEvents:UIControlEventTouchUpInside];
            [lc.backButton addTarget:self action:@selector(goToPreviousCampaign:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([_campaigns count] > 0)
            {
                lc.nameLabel.text = [(NEOCampaign *)[_campaigns objectAtIndex:_campaignIndex] name];
            } else {
                if (_campaignsLoaded) {
                    lc.nameLabel.text = @"No campaigns!";
                } else {
                    lc.nameLabel.text = @"Loading campaign...";
                }
                
            }
            
            cell = (UITableViewCell *)lc;
            break;
        }
        case 1:
        {
            NEOBrowseDetailsCell *dc = [tableView
                                        dequeueReusableCellWithIdentifier:@"NEOBrowseDetailsCell"
                                        forIndexPath:indexPath];
            
            if ([_campaigns count] > 0)
            {
                dc.promotionLabel.text = [(NEOCampaign *)[_campaigns objectAtIndex:_campaignIndex] promotion];
            } else {
                dc.promotionLabel.text = @"";
                }
            
            cell = (UITableViewCell *)dc;
            break;
        }
        case 2:
        {
            NEOBrowseDetailsCell *glc = [tableView
                                        dequeueReusableCellWithIdentifier:@"NEOBrowseGenLinkCell"
                                        forIndexPath:indexPath];
            
            cell = (UITableViewCell *)glc;
            break;
        }
    }
    
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(IBAction)goToNextCampaign:(id)sender
{
    if (_campaignIndex < [_campaigns count] - 1) {
    _campaignIndex++;
    } else {
        _campaignIndex = 0;
    }
    
    [self.tableView reloadData];

}


-(IBAction)goToPreviousCampaign:(id)sender
{
    if (_campaignIndex > 0) {
        _campaignIndex--;
    } else {
        _campaignIndex = [_campaigns count] - 1;
    }
    
    [self.tableView reloadData];
}

-(void) loadCampaigns
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.sessionConfig;
    _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    
    NSString *requestString = @"https://api.neoreach.com/campaigns?skip=0&limit=1000000";
    NSURL *url = [NSURL URLWithString:requestString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        NSDictionary *dict =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        

        [self populateCampaignsWithDictionary:dict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    [dataTask resume];

}

-(void)populateCampaignsWithDictionary:(NSDictionary *)dict
{
    NSArray *campaignsJSON = [[dict objectForKey:@"data"] objectForKey:@"Campaigns"];
    
    for (int i = 0; i < [campaignsJSON count]; i++) {
        NSDictionary *campaignDict = [[campaignsJSON objectAtIndex:i] objectForKey:@"campaign"];
        
        NEOCampaign *campaign = [[NEOCampaign alloc] init];
        campaign.name = [campaignDict valueForKey:@"name"];
        campaign.promotion = [campaignDict valueForKey:@"promotion"];
        
        //Image is stored in Files[0]
        // TODO load image from URL
        // *** not tested, Files are all empty for some reason ***
        NSArray *files = [campaignDict objectForKey:@"Files"];
        if ([files count] > 0) {
            NSString *imageID = [[campaignDict objectForKey:@"Files"] objectAtIndex:0];
            campaign.imageURL = [NSString stringWithFormat:@"https://app.neoreach.com/file/read/%@",imageID];
        }
        
        [_campaigns addObject:campaign];
        _campaignsLoaded = YES;


    }
    
}

@end
