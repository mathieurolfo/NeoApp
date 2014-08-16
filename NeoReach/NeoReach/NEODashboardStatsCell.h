//
//  NEODashboardStatsCell.h
//  NeoReach
//
//  Created by Sam Crognale on 7/24/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NEODashboardStatsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *totalEarningsLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalClicksLabel;

@end
