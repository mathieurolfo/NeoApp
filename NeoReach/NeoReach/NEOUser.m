//
//  NEOUser.m
//  NeoReach
//
//  Created by Sam Crognale on 8/1/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOUser.h"
#import "NEOAppDelegate.h"
#import "NEOLinkedAccount.h"

@implementation NEOUser


-(void) pullProfileInfo
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.login.sessionConfig;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    
    NSString *requestString = @"https://api.neoreach.com/account";
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        //load response into a dictionary
        NSDictionary *profileJSON =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        if ([profileJSON[@"success"] intValue] == 0) //X-Auth and/or X-Digest invalid
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"headerInvalid" object:nil];
                NSLog(@"Header invalid");
            });
        } else { // success
        
            [self populateUserProfileWithDictionary:profileJSON];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"profilePulled" object:nil];
                NSLog(@"profile pulled");
        });
        }
    }];
    [dataTask resume];

}


-(void) postProfileInfoWithDictionary: (NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *URL = [NSURL URLWithString: @"https://api.neoreach.com/account/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.login.sessionConfig;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];

    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        NSDictionary *dict =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        NSLog(@"post response: %@",dict);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"profilePosted" object:nil];
        });
        
        //Later replace with just updating from response
        [self pullProfileInfo];
        
    }];
    
    [postDataTask resume];
}


//Populates user profile with the JSON dictionary returned from the API
-(void)populateUserProfileWithDictionary:(NSDictionary *)dict
{
    //Most profile information is in data.Profile[0]
    NSDictionary *profileDict = dict[@"data"][@"Profile"][0];

    
    self.firstName = [self stringOrBlankIfNil:[profileDict valueForKeyPath:@"name.first"]];
    self.lastName = [self stringOrBlankIfNil:[profileDict valueForKeyPath:@"name.last"]];
    self.email = [self stringOrBlankIfNil:[profileDict valueForKeyPath:@"email"]];
    self.gender = [self stringOrBlankIfNil:[profileDict valueForKeyPath:@"gender"]];
    self.website = [self stringOrBlankIfNil:[profileDict valueForKeyPath:@"website"]];
    self.paypalEmail = [self stringOrBlankIfNil:[profileDict valueForKeyPath:@"paypalEmail"]];
    self.timezoneOffset = [[profileDict valueForKey:@"timezoneOffset"] intValue];
    
    self.tags = [profileDict objectForKey:@"tags"];
    if (self.tags == nil) self.tags = [[NSMutableArray alloc] init];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"]; //ignores timezone for now
    
    NSString *dobString = [profileDict valueForKey:@"dob"];
    if (![dobString isEqual:[NSNull null]]) {
        dobString = [dobString substringToIndex:[dobString length] - 5]; //cut off timezone
        self.dateOfBirth = [dateFormatter dateFromString:dobString];
        
    }
    

    //Publishers are linked accounts
    self.linkedAccounts = [[NSMutableArray alloc] init]; //clear out any previous data
    NSArray *publishers = [[dict objectForKey:@"data"] objectForKey:@"Publishers"];
    for (int i=0; i < [publishers count]; i++) {
        NSDictionary *publisher = [publishers objectAtIndex:i];
        
        NEOLinkedAccount *account = [[NEOLinkedAccount alloc] init];
        account.name = publisher[@"name"];
        account.fullName = publisher[@"full_name"];
        account.picURL = publisher[@"pic"];
        account.pid = publisher[@"pid"];
        account.reach = [publisher[@"reach"] intValue];
        [self.linkedAccounts addObject:account];
        
        if ([account.name isEqualToString:@"facebook.com"]) { // Use facebook profile picture for dashboard
            self.profilePictureURL = [publisher valueForKeyPath:@"pic"];
            self.profilePicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.profilePictureURL]]];
        }
    }
}

- (NSString *)stringOrBlankIfNil:(NSString *)str
{
    return (str) ? str : @"";
}


@end
