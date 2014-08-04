//
//  NEOBrowseGenLinkCell.h
//  NeoReach
//
//  Created by Sam Crognale on 7/25/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NEOBrowseGenLinkCell : UITableViewCell <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *referralURLField;
@property (weak, nonatomic) IBOutlet UIButton *generateLinkButton;
@property (weak, nonatomic) NSString *linkURL;

@end
