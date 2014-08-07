//
//  NEOUser.m
//  NeoReach
//
//  Created by Sam Crognale on 8/1/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOUser.h"
#import "NEOAppDelegate.h"

@implementation NEOUser


-(void) pullProfileInfo
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.sessionConfig;
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
        
        [self populateUserProfileWithDictionary:profileJSON];
        
      //  dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"profilePulled" object:nil];
    //    });
    }];
    [dataTask resume];

}


-(void) postProfileInfoWithDictionary: (NSDictionary *)dict
{
    
    
}

//Populates user profile with the JSON dictionary returned from the API
-(void)populateUserProfileWithDictionary:(NSDictionary *)dict
{
    
    //Most profile information is in data.Profile[0]
    NSDictionary *profileDict = [[[dict objectForKey:@"data"] objectForKey:@"Profile"] objectAtIndex:0];
    
    self.firstName = [profileDict valueForKeyPath:@"name.first"];
    self.lastName = [profileDict valueForKeyPath:@"name.last"];
    self.email = [profileDict valueForKey:@"email"];
    self.gender = [profileDict valueForKey:@"gender"];
    self.website = [profileDict valueForKey:@"website"];
    self.paypalEmail = [profileDict valueForKey:@"paypalEmail"];
    self.timezoneOffset = [[profileDict valueForKey:@"timezoneOffset"] intValue];
    self.tags = [profileDict objectForKey:@"tags"];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"]; //ignores timezone for now
    
    NSString *dobString = [profileDict valueForKey:@"dob"];
    if (![dobString isEqual:[NSNull null]]) {
        dobString = [dobString substringToIndex:[dobString length] - 5]; //cut off timezone
        self.dateOfBirth = [dateFormatter dateFromString:dobString];
        
    }
    
    
    //Profile picture URL is in the 'facebook.com' entry of data.Publishers
    NSArray *publishers = [[dict objectForKey:@"data"] objectForKey:@"Publishers"];
    
    for (int i=0; i < [publishers count]; i++) {
        NSDictionary *publisher = [publishers objectAtIndex:i];
        NSString *publisherName = [publisher valueForKeyPath:@"name"];
        if ([publisherName isEqualToString:@"facebook.com"]) {
            self.profilePictureURL = [publisher valueForKeyPath:@"pic"];
            self.profilePicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.profilePictureURL]]];
            break;
        }
    }
}


@end
