//
//  NEOBrowseGenLinkCell.m
//  NeoReach
//
//  Created by Sam Crognale on 7/25/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOBrowseGenLinkCell.h"
#import <CRToast/CRToast.h>

@interface NEOBrowseGenLinkCell ()

@property (weak, nonatomic) IBOutlet UITextField *linkText;

@end

@implementation NEOBrowseGenLinkCell

- (void)awakeFromNib
{
    self.linkText.font = [UIFont fontWithName:@"Lato-Regular" size:14.0];
    _referralURLField.delegate = self;
    
    [_generateLinkButton setEnabled:YES];
    _referralURLField.text = @"Link not generated";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{

    // Configure the view for the selected state
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (!((_linkURL == nil) || [_linkURL isEqualToString:@""])) {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.referralURLField.text;
    
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
    }
    
    return NO;
}

-(void)setLinkURL:(NSString *)linkURL
{
    _linkURL = linkURL;
    [self updateFieldProperties];
}

-(void)setCampaignExists:(BOOL)campaignExists
{
    _campaignExists = campaignExists;
    [self updateFieldProperties];
}

-(void)updateFieldProperties
{
    if (!_campaignExists) {
        [_generateLinkButton setEnabled:NO];
        _referralURLField.text = @"";
    } else if ((_linkURL == nil) || [_linkURL isEqualToString:@""]) {
        [_generateLinkButton setEnabled:YES];
        _referralURLField.text = @"Link not generated.";
    } else {
        [_generateLinkButton setEnabled:NO];
        _referralURLField.text = _linkURL;
    }
    
    
}


@end
