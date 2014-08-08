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

#include <dispatch/dispatch.h> //for semaphores

@interface NEOBrowseCampaignsController ()
@property NSUInteger campaignIndex;
@property NSMutableArray *campaigns;
@property bool campaignsLoaded; // Need this to differentiate between 0 campaigns and campaigns loading

@property (weak, nonatomic) NEOBrowseGenLinkCell *genLinkCell; //need a reference to this to update its contents when generating a link
@end

@implementation NEOBrowseCampaignsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Browse";
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
            height = 32.0 + [self heightForPromotionText]; // 8.0 + 16.0 + 8.0
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
    NEOCampaign *campaign = nil;
    if ([_campaigns count] > 0) {
        campaign = [_campaigns objectAtIndex:_campaignIndex];
    }
    
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
        {
            NEOBrowseLogosCell *lc = [tableView
                                      dequeueReusableCellWithIdentifier:@"NEOBrowseLogosCell"
                                      forIndexPath:indexPath];
            
            [lc.nextButton addTarget:self action:@selector(goToNextCampaign:) forControlEvents:UIControlEventTouchUpInside];
            [lc.backButton addTarget:self action:@selector(goToPreviousCampaign:) forControlEvents:UIControlEventTouchUpInside];
            
            if (campaign)
            {
                lc.nameLabel.text = campaign.name;
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
            
            if (campaign)
            {
                dc.promotionLabel.text = campaign.promotion;
                dc.CPCLabel.text = [NSString stringWithFormat:@"$%.2f/click",campaign.costPerClick];
            } else {
                dc.promotionLabel.text = @"";
                dc.CPCLabel.text = @"";
                }
            
            cell = (UITableViewCell *)dc;
            break;
        }
        case 2:
        {
            NEOBrowseGenLinkCell *glc = [tableView
                                        dequeueReusableCellWithIdentifier:@"NEOBrowseGenLinkCell"
                                        forIndexPath:indexPath];
            
            glc.linkURL = campaign.referralURL;
                [glc.generateLinkButton addTarget:self action:@selector(generateReferralURL:) forControlEvents:UIControlEventTouchUpInside];
            glc.campaignExists = (campaign != nil);
            _genLinkCell = glc;
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
    _campaignsLoaded = NO;
    
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.login.sessionConfig;
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
        _campaignsLoaded = YES;
        
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
        NEOCampaign *campaign = [[NEOCampaign alloc] init];

        campaign.costPerClick = [[[campaignsJSON objectAtIndex:i] valueForKey:@"cpc"] floatValue];
        
        // Most information is in "campaign" field
        NSDictionary *campaignDict = [[campaignsJSON objectAtIndex:i] objectForKey:@"campaign"];
        campaign.ID = [campaignDict valueForKey:@"_id"];
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
        
        

        [self fetchReferralURLForCampaign:campaign];
        [_campaigns addObject:campaign];


    }
    
}

-(void)fetchReferralURLForCampaign:(NEOCampaign *)campaign
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.login.sessionConfig;
    _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    
    NSString *requestString = [NSString stringWithFormat:@"http://api.neoreach.com/tracker/%@",campaign.ID];
    
    NSURL *url = [NSURL URLWithString:requestString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        NSDictionary *dict =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        

        
        NSDictionary *trackerData = [dict objectForKey:@"data"];
        
        if (![trackerData isEqual:[NSNull null]]) {
            campaign.referralURL = [trackerData objectForKey:@"link"];
        } else {
            campaign.referralURL = nil;
        }

        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    [dataTask resume];
}

-(IBAction)generateReferralURL:(id)sender
{
    NEOCampaign *campaign = [_campaigns objectAtIndex:_campaignIndex];
    NSURL *URL = [NSURL URLWithString:
                  [NSString stringWithFormat:@"https://api.neoreach.com/tracker/%@",campaign.ID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.login.sessionConfig;
    if (!_session) {
               _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    }
    
    NSURLSessionDataTask *postDataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        NSDictionary *dict =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        NSString *referralURL = [[dict objectForKey:@"data"] valueForKey:@"link"];
        campaign.referralURL = referralURL;
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
    [postDataTask resume];
    
    
    
    
}

-(CGFloat)heightForPromotionText
{
    if ([_campaigns count] == 0) return 0.0;

    UILabel *label = [[UILabel alloc] init];
    
    label.text = [[_campaigns objectAtIndex:_campaignIndex] promotion];
    label.font = [UIFont fontWithName:@"Lato-Regular" size:16.0];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;

    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 16.0, 9999); // margins of 8 on both sides
    CGSize expectSize = [label sizeThatFits:maximumLabelSize];
    
    return expectSize.height;
}


@end
