//
//  NEODashboardProfileCell.m
//  NeoReach
//
//  Created by Sam Crognale on 7/24/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEODashboardHeaderCell.h"

@implementation NEODashboardHeaderCell


- (void)awakeFromNib
{
    self.nameLabel.font = [UIFont fontWithName:@"Lato-Regular" size:20.0];
    NSLog(@"%@", self.browseButton.backgroundColor);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
