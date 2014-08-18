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
#import "NEOCampaign.h"

@interface NEOUser ()
@end

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
        
        if ([profileJSON[@"success"] intValue] == 0) //X-Auth and/or X-Digest invalid
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"headerInvalid" object:nil];

            });
        } else { // success
        
            [self populateUserProfileWithDictionary:profileJSON];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"profilePulled" object:nil];

        });
        }
    }];
    [dataTask resume];

}


-(void) postProfileInfoWithDictionary: (NSDictionary *)dict
{
    NSDictionary *completeFormattedDict = [self completeFormattedDictFrom:dict];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:completeFormattedDict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *URL = [NSURL URLWithString: @"https://api.neoreach.com/account/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.sessionConfig;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];

    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        NSDictionary *dict =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"profilePosted" object:nil];
        });
        [dict class];
        //Later replace with just updating from response
        [self pullProfileInfo];
        
    }];
    
    [postDataTask resume];
}

-(NSDictionary *)completeFormattedDictFrom:(NSDictionary *)dict
{
    

    
    NSArray *tags = [self valueOrUserValueIfNone:dict[@"tags"] userValue:self.tags];
    NSString *email = [self valueOrUserValueIfNone:dict[@"email"] userValue:self.email];
    
    NSDictionary *name = @{
                           @"first": [self valueOrUserValueIfNone:dict[@"firstName"] userValue:self.firstName],
                           @"last": [self valueOrUserValueIfNone:dict[@"lastName"] userValue:self.lastName]
                           };
    
    
    
    NSString *gender = [self valueOrUserValueIfNone:dict[@"gender"] userValue:self.gender];
    NSString *website = [self valueOrUserValueIfNone:dict[@"website"] userValue:self.website];
    
    NSDate *dateOfBirth = [self valueOrUserValueIfNone:dict[@"dateOfBirth"] userValue:self.dateOfBirth];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dobString = [dateFormatter stringFromDate:dateOfBirth];
    
    
    NSString *paypalEmail = [self valueOrUserValueIfNone:dict[@"paypalEmail"] userValue:self.paypalEmail];
    NSInteger timezoneOffset = self.timezoneOffset; // We won't ever be editing this
    
    
    NSDictionary *completeFormattedDict = @{
                                   @"tags": tags,
                                   @"email" : email,
                                   @"name" : name,
                                   @"gender": gender,
                                   @"website": website,
                                   @"dob": dobString,
                                   @"paypalEmail": paypalEmail,
                                   @"timezoneOffset": [NSNumber numberWithLong:timezoneOffset]
                                   };
    
    
    return completeFormattedDict;
}

-(id)valueOrUserValueIfNone:(id)value userValue:(id)userValue
{
    if (value == nil || value == [NSNull null]) {
        return userValue;
    }
    return value;
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
    
    if ([self.gender isEqualToString:@""]) self.gender = @"male"; // TODO remove this when API bug is fixed
    
    
    self.website = [self stringOrBlankIfNil:[profileDict valueForKeyPath:@"website"]];
    self.paypalEmail = [self stringOrBlankIfNil:[profileDict valueForKeyPath:@"paypalEmail"]];
    self.timezoneOffset = [[profileDict valueForKey:@"timezoneOffset"] intValue];
    
    self.tags = [profileDict objectForKey:@"tags"];
    if (self.tags == nil) self.tags = [[NSMutableArray alloc] init];
    
    self.totalClicks = [[profileDict valueForKey:@"totalClicks"] unsignedIntegerValue];
    self.totalEarnings = [[profileDict valueForKey:@"totalEarnings"] floatValue];
    
    
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
    NSMutableArray *linkedAccounts = [[NSMutableArray alloc] init];
    NSArray *publishers = [[dict objectForKey:@"data"] objectForKey:@"Publishers"];
    for (int i=0; i < [publishers count]; i++) {
        NSDictionary *publisher = [publishers objectAtIndex:i];
        
        NEOLinkedAccount *account = [[NEOLinkedAccount alloc] init];
        account.name = publisher[@"name"];
        account.fullName = publisher[@"full_name"];
        account.picURL = publisher[@"pic"];
        account.pid = publisher[@"pid"];
        account.reach = [publisher[@"reach"] intValue];
        [linkedAccounts addObject:account];
        
        if ([account.name isEqualToString:@"facebook.com"]) { // Use facebook profile picture for dashboard
            self.profilePictureURL = [publisher valueForKeyPath:@"pic"];
            self.profilePicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.profilePictureURL]]];
        }
    }
    self.linkedAccounts = [NSArray arrayWithArray:linkedAccounts];
}

-(void) pullCampaigns
{
    
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.sessionConfig;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    
    NSString *requestString = @"https://api.neoreach.com/campaigns?skip=0&limit=1000000";
    NSURL *url = [NSURL URLWithString:requestString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        NSDictionary *dict =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        
        
        NSMutableArray *campaignsWithoutReferralURLs = [self campaignsFromDictionary:dict];
        [self fetchReferralURLsForCampaigns:campaignsWithoutReferralURLs];
        

    }];
    [dataTask resume];
}

-(NSMutableArray *)campaignsFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *campaigns = [[NSMutableArray alloc] init];
    
    NSArray *campaignsJSON = [[dict objectForKey:@"data"] objectForKey:@"Campaigns"];
    
    for (int i = 0; i < [campaignsJSON count]; i++) {
        NEOCampaign *campaign = [[NEOCampaign alloc] init];
        
        campaign.costPerClick = [[[campaignsJSON objectAtIndex:i] valueForKey:@"cpc"] floatValue];
        campaign.totalClicks = [[[campaignsJSON objectAtIndex:i] valueForKey:@"totalClicks"] unsignedIntValue];
        
        // Most information is in "campaign" field
        NSDictionary *campaignDict = [[campaignsJSON objectAtIndex:i] objectForKey:@"campaign"];
        campaign.ID = [campaignDict valueForKey:@"_id"];
        campaign.name = [campaignDict valueForKey:@"name"];
        campaign.promotion = [campaignDict valueForKey:@"promotion"];
        
        //Image is stored in Files[0]
        // TODO load image from URL
        // *** not tested, Files are all empty for some reason ***
        NSArray *files = [campaignDict objectForKey:@"Files"];
        if ([files count] > 0) {
            NSString *imageID = [[campaignDict objectForKey:@"Files"] objectAtIndex:0];
            campaign.imageURL = [NSString stringWithFormat:@"https://app.neoreach.com/file/read/%@",imageID];
        }
        [campaigns addObject:campaign];
    }
    
    return campaigns;
}

-(void)fetchReferralURLsForCampaigns:(NSMutableArray *)campaigns
{
    dispatch_semaphore_t referralSema = dispatch_semaphore_create(0);
    for (int i = 0; i < [campaigns count]; i++) {
        [self fetchReferralURLForCampaign:campaigns[i] withSemaphore:referralSema];
    }
    
    // We need to wait for all the URLs to be fetched before returning
    for (int i = 0; i < [campaigns count]; i++) {
        dispatch_semaphore_wait(referralSema, DISPATCH_TIME_FOREVER);
    }
    
    _campaigns = [NSArray arrayWithArray:campaigns];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"campaignsPulled" object:nil];
        NSLog(@"campaigns pulled");
    });
}

-(void)fetchReferralURLForCampaign:(NEOCampaign *)campaign withSemaphore:(dispatch_semaphore_t)sema
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.sessionConfig;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    
    NSString *requestString = [NSString stringWithFormat:@"http://api.neoreach.com/tracker/%@",campaign.ID];
    
    NSURL *url = [NSURL URLWithString:requestString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        NSDictionary *dict =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        NSDictionary *trackerData = [dict objectForKey:@"data"];
        
        if (![trackerData isEqual:[NSNull null]]) {
            campaign.referralURL = [trackerData objectForKey:@"link"];
        } else {
            campaign.referralURL = nil;
        }
        
        dispatch_semaphore_signal(sema);
    }];
    [dataTask resume];
}


- (NSString *)stringOrBlankIfNil:(NSString *)str
{
    return (str) ? str : @"";
}



@end
