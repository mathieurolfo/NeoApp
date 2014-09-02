//
//  NEOBrowseCampaignsController.m
//  NeoReach
//
//  Created by Sam Crognale on 7/21/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOBrowseCampaignsController.h"

#import "NEOBrowseCampaignsCell.h"
#import "NEOAppDelegate.h"
#import "NEOCampaign.h"
#import "NEOUser.h"

@interface NEOBrowseCampaignsController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
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
    
    // Register the NIB files for the browse campaign cells
    UINib *bccNib = [UINib nibWithNibName:@"NEOBrowseCampaignsCell" bundle:nil];
    [self.tableView registerNib:bccNib forCellReuseIdentifier:@"NEOBrowseCampaignsCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(campaignsPulled) name:@"campaignsPulled" object:nil];

    
    [self loadCampaigns];
}

- (void) campaignsPulled
{
    [self.tableView reloadData];
}


-(void)controlInitRefreshCampaigns
{
    [self.refreshControl endRefreshing];
    [self loadCampaigns];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    return [[user campaigns] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    NEOCampaign *campaign = (NEOCampaign *)(user.campaigns[indexPath.row]);
    CGFloat promotionHeight = [self heightForPromotionText:campaign.promotion];
    
    CGFloat height = BROWSE_LOGO_HEIGHT + BROWSE_DETAILS_HEIGHT_WITHOUT_TEXT + promotionHeight + BROWSE_GEN_LINK_HEIGHT;
    return height;
}

-(CGFloat)heightForPromotionText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] init];
    
    label.text = text;
    label.font = [UIFont fontWithName:@"Lato-Regular" size:16.0];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGSize maximumLabelSize = CGSizeMake(screenWidth - 16.0, 9999); // margins of 8 on both sides
    CGSize expectSize = [label sizeThatFits:maximumLabelSize];
    
    return expectSize.height;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    
    NEOBrowseCampaignsCell *bcc = [tableView dequeueReusableCellWithIdentifier:@"NEOBrowseCampaignsCell" forIndexPath:indexPath];
    
    bcc.campaign = user.campaigns[indexPath.row];
    return bcc;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void) loadCampaigns
{
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    [user pullCampaigns];
}


@end
