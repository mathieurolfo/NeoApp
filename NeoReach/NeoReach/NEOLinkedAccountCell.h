//
//  NEOLinkedAccountCell.h
//  NeoReach
//
//  Created by Sam Crognale on 8/7/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEOCircleView.h"

@interface NEOLinkedAccountCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NEOCircleView *publisherImage;
@property (weak, nonatomic) IBOutlet UILabel *reachLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
