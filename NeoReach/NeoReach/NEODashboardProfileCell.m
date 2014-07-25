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


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NEODashboardProfileCell *cell =
    [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    //make profile image circular
    cell.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    cell.profileImage.layer.masksToBounds = YES;
    cell.profileImage.layer.borderWidth = 0;
    
    return cell;
}
@end
