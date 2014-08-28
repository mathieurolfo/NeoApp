//
//  NEOReferralLinkController.m
//  NeoReach
//
//  Created by Mathieu Rolfo on 8/14/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOReferralLinkController.h"
#import <CRToast/CRToast.h>
#import "NEOAppDelegate.h"

@interface NEOReferralLinkController ()

@end

@implementation NEOReferralLinkController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.referralLinkField.text = delegate.user.referralLinkURL;
    
    self.shareTextLabel.font = [UIFont fontWithName:@"Lato-Light" size:16.0];
    self.referralLinkField.font = [UIFont fontWithName:@"Lato-Regular" size:16.0];
    [self.shareTextLabel sizeToFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
