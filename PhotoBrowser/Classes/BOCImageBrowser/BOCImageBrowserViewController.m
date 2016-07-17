//
//  BOCImageBrowserViewController.m
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/2.
//  Copyright © 2016年 liang. All rights reserved.
//



#import "BOCImageBrowserViewController.h"
#import "BOCZoomView.h"
#import "BOCActivityView.h"
#import <UIImageView+WebCache.h>

// 滚动时左右两张图片的间距
static CGFloat ImageMargin = 10;

// 判断横竖屏
#define IsPortrait [UIDevice currentDevice].orientation == UIDeviceOrientationPortrait

#define BOCImageBrowserIs_iPad [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad

@interface BOCImageBrowserViewController ()<UIScrollViewDelegate, BOCZoomViewDelegate>

/// 是否可以执行start动画 default is YES
@property (assign, nonatomic) BOOL canStartAnimation;

/// 保存当前下标
@property (assign, nonatomic) NSInteger currentIndex;

/// 是否第一次启动
@property (assign, nonatomic) BOOL isBegun;

/// 从哪个索引开始
@property (assign, nonatomic) NSInteger startIndex;

/// 保存正在使用的view
@property (strong, nonatomic) NSMutableSet<BOCZoomView *> *visibleViews;

/// 保存可以重用的view
@property (strong, nonatomic) NSMutableSet<BOCZoomView *> *reusebleViews;

/// 保存图片展示所需要的数据
@property (strong, nonatomic) NSArray<NSString *> *datas;

/// 是否加载网络图片
@property (assign, nonatomic) BOOL isNetwork;

/// 负责左右滑动的ScrollView
@property (weak, nonatomic) UIScrollView *scrollView;

/// 显示页码的Label
@property (weak, nonatomic) UILabel *lab;

/// 保存当前的屏幕方向
@property (assign, nonatomic) UIDeviceOrientation currentOri;

@end

@implementation BOCImageBrowserViewController

/*-------------------------------- 初始化设置与构造方法  ----------------------------------------*/

#pragma mark - 初始化构造方法
- (instancetype)initWithDataSource:(NSArray<NSString *> *)datas startIndex:(NSInteger)startIndex isNetwork:(BOOL)isNetwork delegate:( id<BOCImageBrowserViewControllerDelegate>) delegate
{
    self = [super init];
    if (self) {
        [self setup];
        
        self.isNetwork = isNetwork;
        
        self.datas = datas;
        
        self.startIndex = startIndex;
        
        self.delegate = delegate;
        
        // 配置scrollView 显示图片
        [self setupScrollView];
    }
    return self;
}

- (void) setup {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.currentOri = UIDeviceOrientationPortrait;
    self.showPageLabel = YES;
    self.canStartAnimation = YES;
    self.currentIndex = 0;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}

- (void)setupScrollView {
    // 设置scrollView的contentSize 位置和尺寸
    if (self.datas == nil) return;
    
    NSInteger count = self.datas.count;
    
    CGFloat width = self.view.frame.size.width * count;
    
    // 竖屏才加间距
    if (IsPortrait) {
        width += count * ImageMargin;
    }
    self.scrollView.contentSize = CGSizeMake(width, 0);
    
    self.scrollView.frame = (CGRect){CGPointZero, CGSizeMake(width / count, self.view.frame.size.height)};
    
    // 展示图片
    [self showImageViewAtIndex:self.startIndex];
}

/*-------------------------------- page label 的方法  ----------------------------------------*/
#pragma mark - page label 的方法
- (void)pageLabUpdateFrame {
    
    if (self.showPageLabel == NO) return;
    
    CGFloat labW = 100;
    
    CGFloat labX = (self.view.bounds.size.width - labW) * 0.5;
    
    CGFloat labH = 35;
    
    CGFloat labY = 20;
    
    self.lab.frame = CGRectMake(labX, labY, labW, labH);
}

- (void)updatePageLabel {
    if (self.showPageLabel == true) {
        self.lab.text = [NSString stringWithFormat:@"%ld／%ld",self.currentIndex + 1,self.datas.count];
        [self.lab sizeToFit];
        
        [UIView animateWithDuration:AnimationTime animations:^{
            self.lab.alpha = 1.0;
        }];
    }
}

/*-------------------------------------  生命周期方法 ------------------------------------------*/
#pragma mark - 生命周期方法
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.canStartAnimation) {
        [self showWithAnimation];
    }
    else {
        [self showWithAnimationForNewWork];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self pageLabUpdateFrame];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


/*------------------------------------ 处理横竖屏的情况 ----------------------------------------*/
#pragma mark - 处理横屏
- (BOOL)shouldAutorotate
{
    return (BOCImageBrowserIs_iPad) ? YES : [self deviceAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (BOCImageBrowserIs_iPad) ? UIInterfaceOrientationMaskAll : [self deviceSupportOrientations];
}

- (UIInterfaceOrientationMask)deviceSupportOrientations
{
    NSArray *ary =  [[NSBundle mainBundle] infoDictionary][@"UISupportedInterfaceOrientations"];
    UIInterfaceOrientationMask oriMask = UIInterfaceOrientationMaskPortrait;
    for (NSString *str in ary) {
        if ([str isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
            oriMask |= UIInterfaceOrientationMaskLandscapeLeft;
        } if ([str isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
            oriMask |= UIInterfaceOrientationMaskLandscapeRight;
        }
    }
    return oriMask;
}

- (BOOL)deviceAutorotate {
    return ([self deviceSupportOrientations] == UIInterfaceOrientationMaskPortrait) ?
    NO : YES;
}

- (void)deviceOrientationDidChange:(NSNotification *)note
{
    if (BOCImageBrowserIs_iPad || [self deviceAutorotate]) return;
    
    [UIView animateWithDuration:AnimationTime animations:^{
        CGAffineTransform rotation;
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationLandscapeLeft:
                rotation = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
                [self animateWithRotation:rotation isPortrait:IsPortrait];
                break;
            case UIDeviceOrientationLandscapeRight:
                rotation = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
                [self animateWithRotation:rotation isPortrait:IsPortrait];
                break;
                
            case UIDeviceOrientationPortrait:
                rotation = CGAffineTransformIdentity;
                [self animateWithRotation:rotation isPortrait:IsPortrait];
                break;
            default:
                break;
        }
    }];
}

- (void)animateWithRotation:(CGAffineTransform)rotation isPortrait:(BOOL)isPortrait
{
    
    NSInteger index = self.currentIndex;

    if (BOCImageBrowserIs_iPad || [self deviceAutorotate]) return;
    
    if (self.datas == nil) return;
    
    self.view.transform = rotation;
    
    BOCZoomView *currentZoomView = self.currentZoomView;
    
    if (currentZoomView == nil) return;
    
    // 如果是竖屏 加间距
    if (isPortrait) {
        
        self.view.bounds = [UIScreen mainScreen].bounds;
        CGRect frame = self.view.bounds;
        frame.size.width += ImageMargin;
        self.scrollView.frame = frame;
    } else {
        self.view.bounds = CGRectMake(0.0, 0.0, BOCImageBrowserGetScreenHeight, BOCImageBrowserGetScreenWidth);
        
        self.scrollView.frame = self.view.bounds;
    }

    CGFloat width = self.scrollView.frame.size.width;
    
    // 更新frame
    for (BOCZoomView *zoomView in self.visibleViews) {
        
        zoomView.frame = (CGRect){{width * zoomView.indexTag, 0},self.view.bounds.size};
        
        [zoomView didSetImage];
    }
    self.scrollView.contentOffset = CGPointMake(index * width, 0);
    self.scrollView.contentSize = CGSizeMake(width * self.datas.count, 0);

    [self pageLabUpdateFrame];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (![self deviceAutorotate]) return;
    
    if (self.datas == nil) return;
    
    NSInteger index = self.currentIndex;
    
    BOCZoomView *currentZoomView = self.currentZoomView;
    
    if (currentZoomView == nil) return;
    
    // 如果是竖屏 加间距
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
        CGRect frame = self.view.bounds;
        frame.size.width += ImageMargin;
        self.scrollView.frame = frame;
    } else {
        self.scrollView.frame = self.view.bounds;
    }
    
    CGFloat width = self.scrollView.frame.size.width;
    
    // 更新frame
    for (BOCZoomView *zoomView in self.visibleViews) {
        zoomView.frame = (CGRect){{width * zoomView.indexTag, 0},self.view.bounds.size};
        [UIView animateWithDuration:duration animations: ^{
            [zoomView didSetImage];
        }];
    }
    self.scrollView.contentOffset = CGPointMake(index * width, 0);
    self.scrollView.contentSize = CGSizeMake(width * self.datas.count, 0);
}

/*------------------------------------- 重用机制 ------------------------------------------*/
#pragma mark - 显示图片的方法
- (void)showImage {
    //可见的内容的位置，
    CGRect visiblebounds = self.scrollView.bounds;
    //   NSLog(@"vis:%@",NSStringFromCGRect(visiblebounds));
    //拿到可见的内容的位置x值
    CGFloat minX = CGRectGetMinX(visiblebounds);
    //拿到可见内容的位置的x最大值
    CGFloat maxX = CGRectGetMaxX(visiblebounds);
    //拿到屏幕宽度
    CGFloat width = CGRectGetWidth(visiblebounds);
    //计算在显示的那张图片的下标
    NSInteger firstIndex = (NSInteger)minX / width;
    //    NSLog(@"firstIndex:%ld",firstIndex);
    //计算当前显示图片的下一张图片的下标
    NSInteger lastIndex = (NSInteger)maxX / width;
    
    //处理越界的情况
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    
    if (lastIndex >= self.datas.count) {
        lastIndex = self.datas.count - 1;
    }
    
    NSInteger imageIndex = 0;
    //
    for (BOCZoomView *zoomView in self.visibleViews) {
        //通过imageView的tag值得到图片的下标，在可用的imageView集合中遍历
        imageIndex = zoomView.indexTag;
        //如果imageView超出了第一和第二个可用图片的范围，就将其添加到重用的imageView集合中，并将其移出scrollView
        if (imageIndex < firstIndex || imageIndex > lastIndex) {
            [self.reusebleViews addObject:zoomView];

            [zoomView removeFromSuperview];
        }
    }
    
    //将重用set里面 与 可用set里面重复的imageView 清除掉
    [self.visibleViews minusSet:self.reusebleViews];
    
    //遍历当前可用下标和下一张图片的下标
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        BOOL isShow = NO;
        //遍历可用的set看是否与当前要显示的图片的下标相等
        for (BOCZoomView *zoomView in self.visibleViews) {
            //如果相等不做任何改变
            if (zoomView.indexTag == index) {
                isShow = YES;
            }
        }
        //如果不相等，调用下面的方法进行重用或创建
        if (!isShow) {
            [self showImageViewAtIndex:index];
        }
    }

    self.currentIndex = firstIndex;

    [self updatePageLabel];
}

- (void)showImageViewAtIndex:(NSInteger)index {
    //如果重用的set里面有imageView就直接拿来用
    BOCZoomView *zoomView = [self.reusebleViews anyObject];
    if (zoomView) {
        [self.reusebleViews removeObject:zoomView];
    } else {
        //如果没有重用的imageView，就创建
        zoomView = [[BOCZoomView alloc]init];
        zoomView.delegate = self;
    }
    // 添加到scrollView
    [self.scrollView addSubview:zoomView];
    
    // 添加到正在使用的view的集合中
    [self.visibleViews addObject:zoomView];
    
    // 设置数据 image
    zoomView.indexTag = index;
    
    CGFloat zoomViewW = self.view.bounds.size.width;
    CGFloat zoomViewH = self.view.bounds.size.height;
    
    zoomView.frame = CGRectMake(self.scrollView.bounds.size.width * index, 0, zoomViewW, zoomViewH);
    
    // 如果是第一次显示
    if (self.isBegun == NO) {
        self.isBegun = YES;
        self.currentIndex = index;
        CGPoint offset = zoomView.frame.origin;
        self.scrollView.bounds = (CGRect){offset,self.scrollView.bounds.size};
    }
    
    if (self.isNetwork == true) {
        // 使用SDWebImage 加载网络图片
        
        // 查找本地缓存是否有图片
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.datas[index]];
        
        // 没有就使用imageView的原图 然后下载图片
        if (image) {
            
            zoomView.imageView.image = image;
            
            [zoomView didSetImage];
        } else {
            // 如果需要下载 阻止控制器执行开启动画
            self.canStartAnimation = false;
            
            // 使用原图
            UIImageView *imgView = nil;
            if ([self.delegate respondsToSelector:@selector(imageBrowser:imageViewForStartAnimationAtIndex:)]) {
                
                imgView = [self.delegate imageBrowser:self imageViewForStartAnimationAtIndex:index];
                if (imgView){
                    zoomView.imageView.image = imgView.image;
                    [zoomView didSetImage];
                    // 改变frame，让图片中间往外执行动画
                    zoomView.imageView.frame = self.centerImageFrame;
                }
            }
            
            // 下载图片
            [BOCActivityView showInView:zoomView color:[UIColor whiteColor]];
            
            [zoomView.imageView sd_setImageWithURL:[NSURL URLWithString:self.datas[index]] placeholderImage:imgView.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                // 如果没有图片就停止活动指示器
                [BOCActivityView stopAllAnimatingAndRemoveFromView:zoomView];
                
                if (!image) {
                    // 如果有占位图片就设置占位图片
                    // zoomView?.imageView.image =
                    
                    // 缩放比例为1.0
                    zoomView.zoomScrollView.maximumZoomScale = 1.0;
                    return;
                }
                
                // 如果有图片执行动画
                [zoomView didSetImage];
                
                zoomView.imageView.frame = self.centerImageFrame;
                
                [zoomView imageStartAnimationWithInitFrame:CGRectZero];
                
            }];
        }
        
    } else {
        // 加载本地bundle的图片
        NSString *path = [[NSBundle mainBundle]pathForResource:self.datas[index] ofType:nil];

        zoomView.imageView.image = [UIImage imageWithContentsOfFile:path];
        
        [zoomView didSetImage];
    }
    
    self.currentIndex = index;
}

/*------------------------------------- 启动和结束动画 ---------------------------------------*/
#pragma mark - 启动和结束动画
- (void)showWithAnimation {
    
    BOCZoomView *zoomView = self.currentZoomView;
    CGRect initFrame = CGRectZero;
    /// 如果代理响应这个方法
    if ([self.delegate respondsToSelector:@selector(imageBrowser:imageViewForStartAnimationAtIndex:)]) {
        
        UIImageView *imgView = [self.delegate imageBrowser:self imageViewForStartAnimationAtIndex:self.startIndex];
        if (imgView) {
            initFrame = [imgView convertRect:imgView.bounds toView: nil];
            zoomView.imageView.frame = initFrame;
        }

    }

    [zoomView imageStartAnimationWithInitFrame:initFrame];
    
    [self showWithAnimationForNewWork];
}

- (void)showWithAnimationForNewWork {
    [UIView animateWithDuration:AnimationTime animations:^{
        self.scrollView.hidden = false;
        self.view.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        [self updatePageLabel];
        self.view.superview.backgroundColor = [UIColor blackColor];
        
        [self deviceOrientationDidChange:nil];
        
    }];
    
}

- (void)hideWithAnimation {
        // 判断代理是否相应
    self.view.superview.backgroundColor = [UIColor clearColor];
    
    CGRect deinitFrame = CGRectZero;
    BOCZoomView *currentZoomView = self.currentZoomView;
    
    if ([self.delegate respondsToSelector:@selector(imageBrowser:imageViewForStartAnimationAtIndex:)]) {
        
        UIImageView *imgView = [self.delegate imageBrowser:self imageViewForStartAnimationAtIndex:self.currentIndex];
        if (imgView) {
            deinitFrame = [imgView convertRect:imgView.bounds toView: nil];
        }
    }
    
    [UIView animateWithDuration:AnimationTime animations:^{
        
        [self animateWithRotation:CGAffineTransformIdentity isPortrait:YES];
        
        self.view.backgroundColor = [UIColor clearColor];
        
        self.lab.alpha = 0.0;
        
        [currentZoomView imageEndAnimationWithFrame:deinitFrame];
        
    } completion:^(BOOL finished) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
        
}

/*---------------------------------- 实现代理的方法 ----------------------------------------*/
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.datas.count <= 0) return;
    
    [self showImage];
}


#pragma mark - BOCZoomViewDelegate
- (void)zoomView:(BOCZoomView *)zoomView didLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        if ([self.delegate respondsToSelector:@selector(imageBrowser:image:didLongPress:)]) {
            [self.delegate imageBrowser:self image:zoomView.imageView.image didLongPress:longPress];
            return;
        }

        // 如果代理没有实现这个方法，就执行保存图片
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"保存图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *ac = [UIAlertAction actionWithTitle:@"保存图片到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIImageWriteToSavedPhotosAlbum(zoomView.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
        }];
        
        UIAlertAction *cancelAC= [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

        [alertVC addAction:ac];
        [alertVC addAction:cancelAC];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)zoomView:(BOCZoomView *)zoomView didOneTap:(UITapGestureRecognizer *)tap
{
    [self hideWithAnimation];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"保存失败");
        [self showMessage:@"保存图片失败,请检查设备的储存空间"];
    } else {
        NSLog(@"保存成功");
        [self showMessage:@"保存图片成功"];
    }
}

- (void)showMessage:(NSString *)message
{
    // 如果代理没有实现这个方法，就执行保存图片
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ac= [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
    
    [alertVC addAction:ac];
}



/*------------------------------------ 懒加载 --------------------------------------*/
#pragma mark - lazy load
- (UILabel *)lab
{
    if (_lab == nil) {
        UILabel *label = [UILabel new];
        
        label.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5];
        
        label.textColor = UIColor.whiteColor;
        
        label.font = [UIFont boldSystemFontOfSize:17];
        
        label.layer.cornerRadius = 5.0;
        
        label.alpha = 0.0;
        
        label.clipsToBounds = true;
        
        label.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:label];
        
        _lab = label;
    }
    return _lab;
}

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        
        UIScrollView *scrollView = [UIScrollView new];
        
        scrollView.delegate = self;
        
        scrollView.backgroundColor = UIColor.clearColor;
        
        scrollView.pagingEnabled = true;
        
        scrollView.showsHorizontalScrollIndicator = false;
        
        scrollView.showsVerticalScrollIndicator = false;
        
        scrollView.hidden = true;
        
        [self.view addSubview:scrollView];
        
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (NSMutableSet<BOCZoomView *> *)visibleViews
{
    if (_visibleViews == nil) {
        _visibleViews = [NSMutableSet set];
    }
    return _visibleViews;
}

- (NSMutableSet<BOCZoomView *> *)reusebleViews
{
    if (_reusebleViews == nil) {
        _reusebleViews = [NSMutableSet set];
    }
    return _reusebleViews;
}

- (BOCZoomView *)currentZoomView {
    // 找到当前正在显示的那个图片
    for (BOCZoomView *zoomView in self.visibleViews) {
        if (zoomView.indexTag == self.currentIndex) {
            return zoomView;
        }
    }
    return nil;
}

- (CGRect)centerImageFrame {
    
    CGFloat width = self.view.frame.size.width / 3.0;
    CGFloat height = width;
    CGFloat x = (self.view.frame.size.width - width) * 0.5;
    CGFloat y = (self.view.frame.size.height - height) * 0.5;
    return CGRectMake(x, y, width, height);
}


@end
