//
//  NEOReferralLinkController.h
//  NeoReach
//
//  Created by Mathieu Rolfo on 8/14/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NEOReferralLinkController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *referralLinkField;
@property (weak, nonatomic) IBOutlet UILabel *shareTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareTextLabel;

@end
