//
//  NEOCircleView.m
//  NeoReach
//
//  Created by Sam Crognale on 7/25/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOCircleView.h"

@interface NEOCircleView ()

@property (strong, nonatomic) UIImageView *imgView;

@end


@implementation NEOCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self privateInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self privateInit];
}

- (void)privateInit
{
    self.contentMode = UIViewContentModeRedraw;
}



- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [_imgView setFrame:rect];


    // Make image circular
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0;
    
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (_image) {
        _imgView = [[UIImageView alloc] initWithImage:_image];
        [self addSubview:_imgView];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    [self setNeedsDisplay];
}


@end
