//
//  NEOBrowseCampaignsCell.m
//  NeoReach
//
//  Created by Sam Crognale on 9/2/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOBrowseCampaignsCell.h"

#import "NEOBrowseLogosCell.h"
#import "NEOBrowseDetailsCell.h"
#import "NEOBrowseGenLinkCell.h"

@implementation NEOBrowseCampaignsCell

- (void)awakeFromNib
{
    // Initialization code
    
    // Register the NIB files for the browse campaign cells
    UINib *lcNib = [UINib nibWithNibName:@"NEOBrowseLogosCell" bundle:nil];
    UINib *dcNib = [UINib nibWithNibName:@"NEOBrowseDetailsCell" bundle:nil];
    UINib *glcNib = [UINib nibWithNibName:@"NEOBrowseGenLinkCell" bundle:nil];
    
    [self.tableView registerNib:lcNib forCellReuseIdentifier:@"NEOBrowseLogosCell"];
    [self.tableView registerNib:dcNib forCellReuseIdentifier:@"NEOBrowseDetailsCell"];
    [self.tableView registerNib:glcNib forCellReuseIdentifier:@"NEOBrowseGenLinkCell"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3; //Logo, details, generate link
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
        {
            NEOBrowseLogosCell *lc = [tableView
                                      dequeueReusableCellWithIdentifier:@"NEOBrowseLogosCell"
                                      forIndexPath:indexPath];
            
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)heightForPromotionText
{
    
    if (_campaign == nil) return 0.0;
    
    UILabel *label = [[UILabel alloc] init];
    
    label.text = _campaign.promotion;
    label.font = [UIFont fontWithName:@"Lato-Regular" size:16.0];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGSize maximumLabelSize = CGSizeMake(self.contentView.frame.size.width - 16.0, 9999); // margins of 8 on both sides
    CGSize expectSize = [label sizeThatFits:maximumLabelSize];
    
    return expectSize.height;
}




@end
