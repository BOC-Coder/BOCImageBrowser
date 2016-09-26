//
//  BOCZoomView.h
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/2.
//  Copyright © 2016年 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BOCImageBrowserGetScreenHeight [UIScreen mainScreen].bounds.size.height
#define BOCImageBrowserGetScreenWidth [UIScreen mainScreen].bounds.size.width

static CGFloat DefaultMaxScale = 1.5;

@class BOCZoomView;

@protocol BOCZoomViewDelegate <NSObject>

- (void)zoomView:(BOCZoomView *)zoomView didOneTap:(UITapGestureRecognizer *)tap;

- (void)zoomView:(BOCZoomView *)zoomView didLongPress:(UILongPressGestureRecognizer *)longPress;

@end

@interface BOCZoomView : UIView <UIScrollViewDelegate>

@property (weak, nonatomic) UIImageView *imageView;

@property (weak, nonatomic) UIScrollView *zoomScrollView;

@property (weak, nonatomic) id<BOCZoomViewDelegate> delegate;

@property (assign, nonatomic) NSInteger indexTag;

@property (assign, nonatomic) CGRect imageScreenRect;

@property (assign, nonatomic) CGFloat duration;

- (void)didSetImage;
- (void)imageStartAnimationWithInitFrame:(CGRect)initFrame;
- (void)imageEndAnimationWithFrame:(CGRect)frame;
- (void)setIsProcessLongPic:(BOOL)process;

@end
