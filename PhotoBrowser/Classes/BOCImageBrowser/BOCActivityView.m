//
//  BOCActivityView.m
//  转菊花
//
//  Created by LeungChaos on 16/4/23.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "BOCActivityView.h"
#define kRedValue @"r"
#define kGreenValue @"g"
#define kBlueValue @"b"
#define kAlphaValue @"a"


@implementation BOCActivityView

+ (instancetype)showInView:(UIView *)superView
{
    BOCActivityView *av = [self showInView:superView color:nil];
    UIColor *color;
    if (superView.backgroundColor) {
        color = superView.backgroundColor;
    } else {
        color = [UIColor whiteColor];
    }
    [av setColor:[self colorIsDark:color]];
    return av;
}

+ (instancetype)showInView:(UIView *)superView color:(UIColor *)color
{
    return [self activityViewShowInView:superView color:color sizeTo:BOCActivitySizeLarge];
}

+ (instancetype)activityViewShowInView:(UIView *)superView color:(UIColor *)color sizeTo:(BOCActivitySize)sizeOption
{
    [self stopAllAnimatingAndRemoveFromView:superView];
    BOCActivityView *aiv = [[self alloc]initWithActivityIndicatorStyle:0];
    
    if (sizeOption == BOCActivitySizeLarge) {
        [aiv setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    } else {
        [aiv setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    }
    if (color) {
        [aiv setColor:color];
    }
    [superView addSubview:aiv];
    
    aiv.center = CGPointMake(superView.frame.size.width*0.5, superView.frame.size.height*0.5);
    
    aiv.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                            UIViewAutoresizingFlexibleWidth;
    [aiv startAnimating];
    return aiv;
}

- (instancetype)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
    if (self = [super initWithActivityIndicatorStyle:0]) {
    }
    return self;
}

- (void)stopAnimatingAndRemoveFromSuperView
{
    [self stopAnimating];
    [self removeFromSuperview];
}

+ (void)stopAllAnimatingAndRemoveFromView:(UIView *)superView
{
    NSMutableArray *tempAry = [NSMutableArray array];
    for (UIView *view in superView.subviews) {
        if ([view isKindOfClass:self]) {
            [tempAry addObject:view];
        }
    }
    if (tempAry.count) {
        [tempAry makeObjectsPerformSelector:@selector(stopAnimating)];
    }
}

+ (NSDictionary *)getRGBDictionaryWithColor:(UIColor *)originColor
{
    
    if (!originColor) {
        
    }
    CGFloat r = 0,g = 0,b = 0,a = 0;
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [originColor getRed:&r green:&g blue:&b alpha:&a];
    }
    else {
        const CGFloat *components = CGColorGetComponents(originColor.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
        
    }
    return @{kRedValue:@(r),
             kGreenValue:@(g),
             kBlueValue:@(b),
             kAlphaValue:@(a)};
}

+ (UIColor *)colorIsDark:(UIColor *)color
{
    
    NSDictionary *dic = [self getRGBDictionaryWithColor:color];
    
    CGFloat r = 0.01,g = 0.01,b = 0.01;
    if ([dic[kRedValue] doubleValue] < 0.5 && [dic[kRedValue] doubleValue] > 0) {
        r = 1;
    }
    if ([dic[kGreenValue] doubleValue] < 0.5 && [dic[kGreenValue] doubleValue] > 0) {
        g = 1;
    }
    if ([dic[kBlueValue] doubleValue] < 0.5 && [dic[kBlueValue] doubleValue] > 0) {
        b = 1;
    }
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

- (void)dealloc
{
    NSLog(@"BOCActivityView deallc");
}

@end
