//
//  NEODashboardStatsCell.m
//  NeoReach
//
//  Created by Sam Crognale on 7/24/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEODashboardStatsCell.h"

@implementation NEODashboardStatsCell

- (void)awakeFromNib
{
    self.statsLabel.font = [UIFont fontWithName:@"Lato-Regular" size:14.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
