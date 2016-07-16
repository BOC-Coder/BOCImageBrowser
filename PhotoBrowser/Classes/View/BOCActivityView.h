//
//  BOCActivityView.h
//  转菊花
//
//  Created by LeungChaos on 16/4/23.
//  Copyright © 2016年 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BOCActivitySize) {
    BOCActivitySizeLarge = 0,
    BOCActivitySizeSmall,
};

@interface BOCActivityView : UIActivityIndicatorView

/**
 *  直接显示到view上 同时开启动画 默认是白色
 *
 *  @return BOCActivityView的对象
 */
+ (instancetype)showInView:(UIView *)superView;

/**
 *  直接显示到view上 并设置颜色 同时开启动画 默认是BOCActivitySizeLarge
 *
 *  @return BOCActivityView的对象
 */
+ (instancetype)showInView:(UIView *)superView color:(UIColor *)color;

/**
 *  直接显示到view上 并设置颜色和大小 同时开启动画
 *
 *  @return BOCActivityView的对象
 */
+ (instancetype)activityViewShowInView:(UIView *)superView color:(UIColor *)color sizeTo:(BOCActivitySize)sizeOption;

/**
 *  单独停止一个对象的动画并从父控件中移除
 */
- (void)stopAnimatingAndRemoveFromSuperView;

/**
 *  移除某个控件中的所有BOCActivityView并停止动画
 */
+ (void)stopAllAnimatingAndRemoveFromView:(UIView *)superView;


@end
