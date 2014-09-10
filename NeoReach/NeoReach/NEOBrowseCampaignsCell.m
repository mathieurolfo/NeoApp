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

@interface NEOBrowseCampaignsCell ()
@property (weak, nonatomic) NEOBrowseGenLinkCell *genLinkCell; //need a reference to this to update its contents when generating a link
@end

@implementation NEOBrowseCampaignsCell

- (void)awakeFromNib
{
    // Initialization code
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    
    // Register the NIB files for the browse campaign cells
    UINib *lcNib = [UINib nibWithNibName:@"NEOBrowseLogosCell" bundle:nil];
    UINib *dcNib = [UINib nibWithNibName:@"NEOBrowseDetailsCell" bundle:nil];
    UINib *glcNib = [UINib nibWithNibName:@"NEOBrowseGenLinkCell" bundle:nil];
    
    [self.tableView registerNib:lcNib forCellReuseIdentifier:@"NEOBrowseLogosCell"];
    [self.tableView registerNib:dcNib forCellReuseIdentifier:@"NEOBrowseDetailsCell"];
    [self.tableView registerNib:glcNib forCellReuseIdentifier:@"NEOBrowseGenLinkCell"];
    
    //Add listener for generating neorea.ch url
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(campaignURLGenerated) name:@"campaignURLGenerated" object:nil];
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
            
            if (_campaign)
            {
                lc.nameLabel.text = _campaign.name;
                lc.campaignCircleView.image = _campaign.image;
            } else {
                lc.nameLabel.text = @"";
            }
            
            cell = (UITableViewCell *)lc;
            break;
        }
        case 1:
        {
            NEOBrowseDetailsCell *dc = [tableView
                                        dequeueReusableCellWithIdentifier:@"NEOBrowseDetailsCell"
                                        forIndexPath:indexPath];
            
            if (_campaign)
            {
                dc.promotionLabel.text = _campaign.promotion;
                dc.CPCLabel.text = [NSString stringWithFormat:@"$%.2f/click",_campaign.costPerClick];
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
            
            glc.campaignExists = (_campaign != nil);
            glc.linkURL = _campaign.referralURL;
            [glc.generateLinkButton addTarget:self action:@selector(generateReferralURL:) forControlEvents:UIControlEventTouchUpInside];
            _genLinkCell = glc;
            cell = (UITableViewCell *)glc;
            break;
        }
    }
    
    return cell;

}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0.0;
    switch (indexPath.row) {
        case 0: // Logo
            height = BROWSE_LOGO_HEIGHT;
            break;
        case 1: // Details
            height = BROWSE_DETAILS_HEIGHT_WITHOUT_TEXT + [self heightForPromotionText]; 
            break;
        case 2: // Generate link
            height = BROWSE_GEN_LINK_HEIGHT;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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


-(void)generateReferralURL:(id)sender
{
    [(UIButton *)sender setEnabled:NO];
    [_campaign generateReferralURL];
}

-(void)campaignURLGenerated
{
    [self.tableView reloadData];
}

-(void)setCampaign:(NEOCampaign *)campaign
{
    _campaign = campaign;
    [self.tableView reloadData];
}



@end
