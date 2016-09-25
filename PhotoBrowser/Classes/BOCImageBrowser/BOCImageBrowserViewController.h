//
//  BOCImageBrowserViewController.h
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/2.
//  Copyright © 2016年 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

// 滚动时左右两张图片的间距
static CGFloat const kBOCImageBrowserImageMargin = 10;

static double kBOCImageBrowserAnimationTime = 0.3;

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

@end

@interface BOCImageBrowserViewController : UIViewController

/**
 *  是否处理 超长图片, default is YES;
 */
@property (assign, nonatomic) BOOL processTheLongPicture;

/**
 *  是否显示页码, default is YES;
 */
@property (assign, nonatomic) BOOL showPageLabel;

/**
 *  执行动画需要设置代理
 */
@property (weak, nonatomic) id<BOCImageBrowserViewControllerDelegate> delegate;

/**
 *  便利构造函数，创建图片浏览器
 *
 *  @param datas      需要加载的图片
 *  @param startIndex 从哪一张开始显示
 *  @param delegate   成为代理的对象
 *
 *  自动判断图片的名称是否网络路径
 *
 *  @return BOCImageBrowserViewController对象
 */
- (instancetype)initWithSourceArray:(NSArray<NSString *> *)sourceArr
                        startIndex:(NSInteger)startIndex
                          delegate:(id<BOCImageBrowserViewControllerDelegate>)delegate;


+ (instancetype)imageBrowserWithSourceArray:(NSArray<NSString *> *)sourceArr
                                 startIndex:(NSInteger)startIndex
                                   delegate:(id<BOCImageBrowserViewControllerDelegate>)delegate;

@end

/* 
 已过期的方法
 */
@interface BOCImageBrowserViewController (ImageBrowserDeprecated)

- (instancetype)initWithDataSource:(NSArray<NSString *> *)datas startIndex:(NSInteger)startIndex isNetwork:(BOOL)isNetwork delegate:(id<BOCImageBrowserViewControllerDelegate>) delegate __deprecated_msg("Method deprecated. Use `initWithSourceArray:startIndex:delegate:`");

@end



