//
//  NEODashboardPostCell.m
//  NeoReach
//
//  Created by Sam Crognale on 7/24/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEODashboardPostCell.h"

@interface NEODashboardPostCell ()

@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UILabel *deltaLabel;

@end

@implementation NEODashboardPostCell

- (void)awakeFromNib
{
    self.postLabel.font = [UIFont fontWithName:@"Lato-Regular" size:16.0];
    self.deltaLabel.font = [UIFont fontWithName:@"Lato-Regular" size:16.0];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
