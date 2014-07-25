//
//  NEOCircleView.m
//  NeoReach
//
//  Created by Sam Crognale on 7/25/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOCircleView.h"

@implementation NEOCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}




- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    // Make image circular
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (_image) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:self.image];
        imgView.center = self.center;
        [self addSubview:imgView];
    }
    [self setNeedsDisplay];
}

@end
