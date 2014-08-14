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
@property (strong, nonatomic) UIRefreshControl *refreshControl;
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
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(controlInitRefreshCampaigns) forControlEvents:UIControlEventValueChanged];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(campaignsPulled) name:@"campaignsPulled" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(campaignURLGenerated) name:@"campaignURLGenerated" object:nil];

    
    [self loadCampaigns];
}

- (void) campaignsPulled
{
    _campaignsLoaded = YES;
    [self.tableView reloadData];

}


-(void)controlInitRefreshCampaigns
{
    [self.refreshControl endRefreshing];
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
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    
    NEOCampaign *campaign = nil;
    if ([[user campaigns] count] > 0) {
        campaign = user.campaigns[_campaignIndex];
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
            
            glc.campaignExists = (campaign != nil);
            glc.linkURL = campaign.referralURL;
            [glc.generateLinkButton addTarget:self action:@selector(generateReferralURL:) forControlEvents:UIControlEventTouchUpInside];
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
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];

    if (_campaignIndex < [user.campaigns count] - 1) {
    _campaignIndex++;
    } else {
        _campaignIndex = 0;
    }
    
    [self.tableView reloadData];
}

-(IBAction)goToPreviousCampaign:(id)sender
{
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];

    if (_campaignIndex > 0) {
        _campaignIndex--;
    } else {
        _campaignIndex = [user.campaigns count] - 1;
    }
    
    [self.tableView reloadData];
}

-(void) loadCampaigns
{
    _campaignsLoaded = NO;
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    [user pullCampaigns];
}


-(IBAction)generateReferralURL:(id)sender
{
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    [user.campaigns[_campaignIndex] generateReferralURL];
    
}

-(void)campaignURLGenerated
{
    [self.tableView reloadData];
}


-(CGFloat)heightForPromotionText
{
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];

    if ([user.campaigns count] == 0) return 0.0;

    UILabel *label = [[UILabel alloc] init];
    
    label.text = [[user.campaigns objectAtIndex:_campaignIndex] promotion];
    label.font = [UIFont fontWithName:@"Lato-Regular" size:16.0];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;

    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 16.0, 9999); // margins of 8 on both sides
    CGSize expectSize = [label sizeThatFits:maximumLabelSize];
    
    return expectSize.height;
}


@end
