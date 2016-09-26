//
//  BOCToolbarImageBroswerController.m
//  PhotoBrowser
//
//  Created by LeungChaos on 16/9/26.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "BOCToolbarImageBroswerController.h"

static CGFloat const kToolbarImageBroswerNavBarHeight = 44.f;
static CGFloat const kToolbarImageBroswerToolBarHeight = 46.f;


@interface BOCToolbarImageBroswerController ()

@property (weak, nonatomic) UINavigationBar *navBar;

@property (weak, nonatomic) UIToolbar *toolBar;

@property (weak, nonatomic) NSTimer *timer;

@end

@implementation BOCToolbarImageBroswerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

#pragma mark - 重写父类方法
- (void)pageDidChange:(NSInteger)pageNumber totalPage:(NSInteger)totalPage
{
    
}

/**
 *  用户长按图片时调用, 如果实现了代理方法"imageBrowser:image:didLongPress:", 这个方法将不会被执行
 */
- (void)imageViewDidLongPress:(UIImageView *)imageView
{
    
}

/**
 *  用户单击图片是调用, 如果实现了代理方法"imageBrowser:image:didTap:", 这个方法将不会被执行
 */
- (void)imageViewDidTap:(UIImageView *)imageView
{
    
}

- (void)orientationChangeWithRect:(CGRect)rect
{
    self.navBar.frame = CGRectMake(0, 0, rect.size.width, kToolbarImageBroswerNavBarHeight);
    self.toolBar.frame = CGRectMake(0, rect.size.height - kToolbarImageBroswerToolBarHeight, rect.size.width, kToolbarImageBroswerToolBarHeight);
}

//- show

#pragma mark - 懒加载
- (UINavigationBar *)navBar
{
    if (_navBar == nil) {
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kToolbarImageBroswerNavBarHeight)];
        [self.view addSubview:navBar];
        _navBar = navBar;
    }
    return _navBar;
}

- (UIToolbar *)toolBar
{
    if (_toolBar == nil) {
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - kToolbarImageBroswerToolBarHeight, [UIScreen mainScreen].bounds.size.width, kToolbarImageBroswerToolBarHeight)];
        _toolBar = toolBar;
        [self.view addSubview:toolBar];
    }
    return _toolBar;
}

@end
