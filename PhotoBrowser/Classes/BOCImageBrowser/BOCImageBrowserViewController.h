//
//  BOCImageBrowserViewController.h
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/2.
//  Copyright © 2016年 liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BOCZoomView.h"

@class BOCLanguageManager;
@class BOCImageBrowserViewController;

@protocol BOCImageBrowserViewControllerDelegate <NSObject>

@optional

/**
 *  返回一个需要执行动画的imageView，在打开图片浏览器的时候
 *
 *  @param imageBrowser 图片浏览器对象
 *  @param index        当前显示图片的下标
 *
 *  @return 返回一个与当前图片相对应的UIImageView对象
 *
 *  ******  如果没有实现这个方法, 或返回值为nil, 就会执行淡入淡出的效果 ******
 */
- (UIImageView *)imageBrowser:(BOCImageBrowserViewController *)imageBrowser imageViewForStartAnimationAtIndex:(NSInteger)index;

/**
 *  当图片被长按时回调这个方法
 *
 *  ******  如果没有实现这个方法，默认就是弹出ActionSheet提示保存图片到相册  *******
 *
 *  @param image        当前显示在浏览器上的图片
 *  @param longPress    长按的UILongPressGestureRecognizer对象
 */
- (void)imageBrowser:(BOCImageBrowserViewController *)imageBrowser image:(UIImage *)image didLongPress:(UILongPressGestureRecognizer *)longPress;

/**
 *  当图片被单击时回调这个方法
 *
 *  @param image        当前显示在浏览器上的图片
 *  @param tap          图片中的UITapGestureRecognizer对象
 */
- (void)imageBrowser:(BOCImageBrowserViewController *)imageBrowser image:(UIImage *)image didTap:(UITapGestureRecognizer *)tap;


@end


@interface BOCImageBrowserViewController : UIViewController<UIScrollViewDelegate, BOCZoomViewDelegate>

/**
 *  是否处理 超长图片, default is YES;
 */
@property (assign, nonatomic) BOOL processTheLongPicture;

/**
 *  是否显示页码, default is YES;
 */
@property (assign, nonatomic) BOOL showPageLabel;

/**
 *  设置滚动时左右两张图片的水平间距 , default is 10.f;
 */
@property (assign, nonatomic) CGFloat imageHorizontalSpacing;

/**
 *  动画时间,default is 0.3f;
 */
@property (assign, nonatomic) CGFloat animationDuration;

/**
 *  加载图片失败时的占位图片
 */
@property (strong, nonatomic) UIImage *placeholderImage;

/**
 *  语言管理者
 */
@property (readonly, nonatomic) BOCLanguageManager *languageManager;


@property (weak, nonatomic) id<BOCImageBrowserViewControllerDelegate> delegate;

/**
 *  便利构造函数，创建图片浏览器
 *
 *  @param datas      需要加载的图片 (URL 或 imageName)
 *  *************** 自动判断图片的名称是否网络路径 *****************
 *
 *  @param startIndex 从哪一张开始显示
 *  @param delegate   成为代理的对象
 *
 *
 *  @return BOCImageBrowserViewController对象
 */
- (instancetype)initWithSourceArray:(NSArray<NSString *> *)sourceArr
                        startIndex:(NSInteger)startIndex
                          delegate:(id<BOCImageBrowserViewControllerDelegate>)delegate;


+ (instancetype)imageBrowserWithSourceArray:(NSArray<NSString *> *)sourceArr
                                 startIndex:(NSInteger)startIndex
                                   delegate:(id<BOCImageBrowserViewControllerDelegate>)delegate;

/**
 *  带动画的退出方法
 */
- (void)dismissAnimation;

#pragma mark - Over ride  交给子类实现
/**
 *  发送改变时调用
 *
 *  @param pageNumber 当前页数 (面向用户的页数，非数组下标)
 *  @param totalPage  总页数
 */
- (void)pageDidChange:(NSInteger)pageNumber totalPage:(NSInteger)totalPage;

/**
 *  用户长按图片时调用, 如果实现了代理方法"imageBrowser:image:didLongPress:", 这个方法将不会被执行
 */
- (void)imageViewDidLongPress:(UIImageView *)imageView;

/**
 *  用户单击图片是调用, 如果实现了代理方法"imageBrowser:image:didTap:", 这个方法将不会被执行
 */
- (void)imageViewDidTap:(UIImageView *)imageView;

/**
 *  屏幕方向发送改变时调用
 *
 *  @param rect 改变方向后控制器view的frame < 在这个方法里面执行会有动画效果 >
 */
- (void)orientationChangeWithRect:(CGRect)rect;

@end

/* 
 已过期方法的分类
 */
@interface BOCImageBrowserViewController (ImageBrowserDeprecated)

- (instancetype)initWithDataSource:(NSArray<NSString *> *)datas startIndex:(NSInteger)startIndex isNetwork:(BOOL)isNetwork delegate:(id<BOCImageBrowserViewControllerDelegate>) delegate __deprecated_msg("Method deprecated. Use `initWithSourceArray:startIndex:delegate:`");

@end



