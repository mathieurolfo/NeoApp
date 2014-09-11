//
//  NEOBrowseLogosCell.m
//  NeoReach
//
//  Created by Sam Crognale on 7/25/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOBrowseLogosCell.h"

@implementation NEOBrowseLogosCell

- (void)awakeFromNib
{
    self.nameLabel.font = [UIFont fontWithName:@"Lato-Regular" size:17.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
