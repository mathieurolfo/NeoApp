//
//  NEOProfileForm.m
//  NeoReach
//
//  Created by Sam Crognale on 8/6/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOProfileForm.h"

typedef NS_ENUM(NSInteger, Gender)
{
    GenderMale,
    GenderFemale
};

@implementation NEOProfileForm

- (NSDictionary *)websiteField
{
    return @{FXFormFieldType: FXFormFieldTypeURL};
}

- (NSDictionary *)genderField
{
    return @{FXFormFieldOptions: @[@(GenderMale), @(GenderFemale)],
             FXFormFieldValueTransformer: ^(id input) {
                 return @{@(GenderMale): @"Male",
                          @(GenderFemale): @"Female"} [input];
             }};
}


@end
