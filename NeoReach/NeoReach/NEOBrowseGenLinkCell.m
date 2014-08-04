//
//  NEOBrowseGenLinkCell.m
//  NeoReach
//
//  Created by Sam Crognale on 7/25/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOBrowseGenLinkCell.h"
#import <CRToast/CRToast.h>

@implementation NEOBrowseGenLinkCell

- (void)awakeFromNib
{
    // Initialization code
    _referralURLField.delegate = self;
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
    
    // If empty string or nil, then link is not yet generated. Otherwise, assume linkURL is a valid URL.
    if ((linkURL == nil) || [linkURL isEqualToString:@""]) {
        [_generateLinkButton setEnabled:YES];
        _referralURLField.text = @"Link not generated";
    } else {
        [_generateLinkButton setEnabled:NO];
        _referralURLField.text = linkURL;
    }
    
}



@end
