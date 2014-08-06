//
//  NEOProfileForm.h
//  NeoReach
//
//  Created by Sam Crognale on 8/6/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>

typedef NS_ENUM(NSInteger, Gender)
{
    GenderMale,
    GenderFemale
};

@interface NEOProfileForm : NSObject <FXForm>

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *website;
@property (nonatomic) Gender gender;
@property (nonatomic, copy) NSDate *dateOfBirth;

@end
