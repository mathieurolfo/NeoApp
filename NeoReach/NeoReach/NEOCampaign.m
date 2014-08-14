//
//  NEOCampaign.m
//  NeoReach
//
//  Created by Sam Crognale on 8/1/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOCampaign.h"
#import "NEOAppDelegate.h"

@implementation NEOCampaign

-(void)generateReferralURL
{
    NSURL *URL = [NSURL URLWithString:
                  [NSString stringWithFormat:@"https://api.neoreach.com/tracker/%@",_ID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.sessionConfig;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        NSDictionary *dict =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        NSString *referralURL = [[dict objectForKey:@"data"] valueForKey:@"link"];
        _referralURL = referralURL;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"campaignURLGenerated" object:nil];
        });
    }];
    [postDataTask resume];
    
}

@end
