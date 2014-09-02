//
//  NEOBrowseLogosCell.h
//  NeoReach
//
//  Created by Sam Crognale on 7/25/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEOCircleView.h"

@interface NEOBrowseLogosCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NEOCircleView *campaignCircleView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
