//
//  NEOReferralLinkController.m
//  NeoReach
//
//  Created by Mathieu Rolfo on 8/14/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOReferralLinkController.h"
#import <CRToast/CRToast.h>

@interface NEOReferralLinkController ()

@end

@implementation NEOReferralLinkController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.referralLinkField.font = [UIFont fontWithName:@"Lato-Regular" size:14.0];
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Invite Friends";
    }
    return self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.referralLinkField.text;
    
    NSDictionary *options = @{
                              kCRToastTextKey : @"Link copied to clipboard",
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [UIColor orangeColor],
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                }];

    return NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
