//
//  NEOBrowseDetailsCell.m
//  NeoReach
//
//  Created by Sam Crognale on 7/25/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOBrowseDetailsCell.h"

@implementation NEOBrowseDetailsCell

- (void)awakeFromNib
{
    self.promotionLabel.font = [UIFont fontWithName:@"Lato-Regular" size:14.0];
    self.CPCLabel.font = [UIFont fontWithName:@"Lato-Regular" size:16.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
