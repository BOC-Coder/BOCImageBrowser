//
//  BOCZoomView.m
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/2.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "BOCZoomView.h"

@implementation BOCZoomView

#pragma mark - lazy load
- (UIScrollView *)zoomScrollView
{
    if (_zoomScrollView == nil) {
        UIScrollView *sc = [[UIScrollView alloc]init];
        
        sc.frame = self.bounds;
        
        sc.showsHorizontalScrollIndicator = false;
        
        sc.showsVerticalScrollIndicator = false;
        
        sc.minimumZoomScale = 1.0;
        
        sc.delegate = self;
        
        [self addSubview: sc];
        
        _zoomScrollView = sc;
    }
    return _zoomScrollView;
}

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        UIImageView *imgView = [UIImageView new];
        
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        
        imgView.clipsToBounds = true;
        
        [self.zoomScrollView addSubview:imgView];
        
        _imageView = imgView;
    }
    return _imageView;
}

#pragma mark - 生命周期方法
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 单击手势
        UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:NSSelectorFromString(@"oneTap:")];
        
        // 双击
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:NSSelectorFromString(@"doubleTap:")];
        doubleTap.numberOfTapsRequired = 2;
        [oneTap requireGestureRecognizerToFail:doubleTap];
        
        // 长按
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:NSSelectorFromString(@"longPress:")];

        [self addGestureRecognizer:oneTap];
        [self addGestureRecognizer:doubleTap];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

#pragma mark - 处理点击和手势
- (void)oneTap:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(zoomView:didOneTap:)]) {
        [self.delegate zoomView:self didOneTap:tap];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    
    if (self.imageView.image == nil) return;
    
    
    [UIView animateWithDuration:AnimationTime animations:^{
       
        CGFloat minScale = self.zoomScrollView.minimumZoomScale;

        if (self.zoomScrollView.zoomScale == minScale) {
            self.zoomScrollView.zoomScale = self.zoomScrollView.maximumZoomScale;
        } else {
            self.zoomScrollView.zoomScale = minScale;
        }

        
    }];
    
}

-(void)longPress:(UILongPressGestureRecognizer *)longPress {
    if (self.imageView.image == nil) return;

    if ([self.delegate respondsToSelector:@selector(zoomView:didLongPress:)]) {
        [self.delegate zoomView:self didLongPress:longPress];
    }
    
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat ScreenWidth = BOCImageBrowserGetScreenWidth;
    CGFloat ScreenHeight = BOCImageBrowserGetScreenHeight;
    
    CGFloat centerX = ScreenWidth * 0.5;
    if (self.imageView.frame.size.width > ScreenWidth) {
        centerX = self.imageView.frame.size.width * 0.5;
    }
    
    CGFloat centerY = ScreenHeight * 0.5;
    if (self.imageView.frame.size.height > ScreenHeight) {
        centerY = self.imageView.frame.size.height * 0.5;
    }
    
    self.imageView.center = CGPointMake(centerX, centerY);
}

#pragma mark - 执行动画
// 设置完图片后调用
- (void)didSetImage
{
    CGFloat ScreenWidth = BOCImageBrowserGetScreenWidth;
    CGFloat ScreenHeight = BOCImageBrowserGetScreenHeight;
    
    self.zoomScrollView.zoomScale = self.zoomScrollView.minimumZoomScale;
        
    self.zoomScrollView.frame = self.bounds;
        
    self.zoomScrollView.contentSize = CGSizeZero;
        
        // 设置 计算放大比例
    if (self.imageView.image == nil) return;
    
    
    CGSize imageSize = self.imageView.image.size;
        
    CGFloat scale = [UIScreen mainScreen].scale;
        
    CGFloat scaleW = imageSize.width / (ScreenWidth * scale);
        
    CGFloat scaleH = imageSize.height / (ScreenHeight * scale);
        
    CGFloat imageViewH = 0;
    CGFloat imageViewW = 0;
    CGFloat imageViewX = 0;
    CGFloat imageViewY = 0;
    
    if (scaleW >= scaleH) {
        // 计算缩放比例
        if (scaleW > DefaultMaxScale) {
            self.zoomScrollView.maximumZoomScale = scaleW;
        } else {
            self.zoomScrollView.maximumZoomScale = DefaultMaxScale;
        }
        // 计算图片的位置和尺寸 居屏幕的中心点
        imageViewW = ScreenWidth;
        
        imageViewH = imageViewW / imageSize.width * imageSize.height;
        
        imageViewY = (ScreenHeight - imageViewH) * 0.5;
        
    } else {
        
        if (scaleH > DefaultMaxScale) {
            self.zoomScrollView.maximumZoomScale = scaleH;
        } else {
            self.zoomScrollView.maximumZoomScale = DefaultMaxScale;
        }
        // 计算图片的位置和尺寸 居屏幕的中心点
        imageViewH = ScreenHeight;
        
        imageViewW = imageViewH / imageSize.height * imageSize.width;
        
        imageViewX = (ScreenWidth - imageViewW) * 0.5;
    }
        
    self.imageScreenRect = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
    
    self.imageView.frame = self.imageScreenRect;
    
}
    
- (void)imageStartAnimationWithInitFrame:(CGRect)initFrame {
        //
        if (!CGRectEqualToRect(initFrame, self.imageView.frame)) {
            self.imageView.alpha = 0.0;
        }
    
    [UIView animateWithDuration:AnimationTime animations:^{
        
        self.imageView.frame = self.imageScreenRect;
        self.imageView.alpha = 1.0;
     
    }];
}

- (void)imageEndAnimationWithFrame:(CGRect)frame {
    // 还原缩放
    self.zoomScrollView.zoomScale = 1.0;
    
    // 执行动画
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if (CGRectEqualToRect(frame, CGRectZero)) {
        self.imageView.alpha = 0.0;
        return;
    }
    
    self.imageView.frame = frame;
}


@end
