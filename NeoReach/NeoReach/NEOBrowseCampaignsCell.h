//
//  NEOBrowseCampaignsCell.h
//  NeoReach
//
//  Created by Sam Crognale on 9/2/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEOCampaign.h"

@interface NEOBrowseCampaignsCell : UITableViewCell <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NEOCampaign *campaign;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
