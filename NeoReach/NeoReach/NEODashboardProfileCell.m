//
//  NEODashboardProfileCell.m
//  NeoReach
//
//  Created by Sam Crognale on 7/24/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEODashboardProfileCell.h"

@implementation NEODashboardProfileCell


- (void)awakeFromNib
{
    // Initialization code
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderWidth = 0;
}

@end
