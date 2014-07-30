//
//  NEODashboardProfileCell.h
//  NeoReach
//
//  Created by Sam Crognale on 7/24/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEOCircleView.h"

@interface NEODashboardProfileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NEOCircleView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
