//
//  NEOProfileForm.m
//  NeoReach
//
//  Created by Sam Crognale on 8/6/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOProfileForm.h"



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

- (NSArray *)extraFields
{
    return @[
             
             //this field doesn't correspond to any property of the form
             //it's just an action button. the action will be called on first
             //object in the responder chain that implements the submitForm
             //method, which in this case would be the AppDelegate
             
             @{FXFormFieldTitle: @"Save", FXFormFieldHeader: @"", FXFormFieldAction: @"saveProfileChanges"},
             
             ];
}

@end
