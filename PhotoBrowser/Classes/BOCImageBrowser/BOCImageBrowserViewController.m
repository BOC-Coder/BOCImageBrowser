//
//  BOCImageBrowserViewController.m
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/2.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "BOCImageBrowserViewController.h"
#import "BOCActivityView.h"
#import <UIImageView+WebCache.h>
#import "BOCLanguageManager.h"

// 判断横竖屏
#define IsPortrait [UIDevice currentDevice].orientation == UIDeviceOrientationPortrait

#define NotLandscape [UIDevice currentDevice].orientation != UIDeviceOrientationLandscapeLeft && [UIDevice currentDevice].orientation != UIDeviceOrientationLandscapeRight

#define BOCImageBrowserIs_iPad [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad

@interface BOCImageBrowserViewController ()

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

/// 负责左右滑动的ScrollView
@property (weak, nonatomic) UIScrollView *scrollView;

/// 显示页码的Label
@property (weak, nonatomic) UILabel *lab;

/// 保存当前的屏幕方向
@property (assign, nonatomic) UIDeviceOrientation currentOri;

/**
 *  语言管理
 */
@property (strong, nonatomic) BOCLanguageManager *languageMan;

@end

@implementation BOCImageBrowserViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
/*-------------------------------- 初始化设置与构造方法  ----------------------------------------*/

#pragma mark - 初始化构造方法
+ (instancetype)imageBrowserWithSourceArray:(NSArray<NSString *> *)sourceArr startIndex:(NSInteger)startIndex delegate:(id<BOCImageBrowserViewControllerDelegate>)delegate
{
    return [[self alloc] initWithSourceArray:sourceArr startIndex:startIndex delegate:delegate];
}

- (instancetype)initWithSourceArray:(NSArray<NSString *> *)sourceArr
                         startIndex:(NSInteger)startIndex
                           delegate:(id<BOCImageBrowserViewControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        [self setup];
        
        self.datas = sourceArr;
        
        self.startIndex = startIndex;
        
        self.delegate = delegate;
        
        // 配置scrollView 显示图片
        [self setupScrollView];
    }
    return self;
}

- (void)setup {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.animationDuration = 0.3f;
    self.imageHorizontalSpacing = 10.f;
    self.currentOri = UIDeviceOrientationPortrait;
    self.currentIndex = 0;
    self.processTheLongPicture = self.showPageLabel = self.canStartAnimation = true;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}

- (void)setupScrollView {
    // 设置scrollView的contentSize 位置和尺寸
    NSInteger count = self.datas.count;

    if (!count) return;
    
    CGFloat width = self.view.frame.size.width * count;
    
    // 竖屏才加间距
//    if (NotLandscape) {
    width += count * self.imageHorizontalSpacing;
//    }
    self.scrollView.contentSize = CGSizeMake(width, 0);
    
    self.scrollView.frame = (CGRect){CGPointZero, CGSizeMake(width / count, self.view.frame.size.height)};
    
    // 展示图片
    [self showImageViewAtIndex:self.startIndex];
}

/*-------------------------------- page label 的方法  ----------------------------------------*/
#pragma mark - page label 的方法
- (CGSize)labBoundingSize
{
    return [self.lab.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.lab.font} context:nil].size;
}

- (void)pageLabUpdateFrame {
    
    if (self.showPageLabel == NO) return;
    
    CGSize size = [self labBoundingSize];
    CGFloat inset = 10;
    
    CGFloat labW = size.width < (100 - inset) ? 100 : size.width + inset;
    CGFloat labH = size.height < 35 - inset * 0.5 ? 35 : size.height + inset * 0.5;
    
    CGFloat labX = (self.view.bounds.size.width - labW) * 0.5;
    CGFloat labY = 20;
    
    self.lab.frame = CGRectMake(labX, labY, labW, labH);
}

- (void)updatePageLabel {
    
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width + 0.5;
    [self pageDidChange:index + 1 totalPage:self.datas.count];
    
    if (!self.showPageLabel) return;
    
    self.lab.text = [NSString stringWithFormat:@"%ld／%ld",index + 1,self.datas.count];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        [self pageLabUpdateFrame];
        self.lab.alpha = 1.0;
    }];
}

/*-------------------------------------  生命周期方法 ------------------------------------------*/
#pragma mark - 生命周期方法
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.canStartAnimation)
        [self showWithAnimation];
    else
        [self showWithAnimationForNewWork];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self pageLabUpdateFrame];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
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
    return !([self deviceSupportOrientations] == UIInterfaceOrientationMaskPortrait);
}

- (void)deviceOrientationDidChange:(NSNotification *)note
{
    if (BOCImageBrowserIs_iPad || [self deviceAutorotate]) return;
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        CGAffineTransform rotation;
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationLandscapeLeft:
                rotation = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
                [self animateWithRotation:rotation isPortrait:NotLandscape];
                break;
            case UIDeviceOrientationLandscapeRight:
                rotation = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
                [self animateWithRotation:rotation isPortrait:NotLandscape];
                break;
            case UIDeviceOrientationPortrait:
                rotation = CGAffineTransformIdentity;
                [self animateWithRotation:rotation isPortrait:NotLandscape];
                break;
            case UIDeviceOrientationPortraitUpsideDown:return;
                break;
            default:
                break;
        }
    }];
}

- (void)animateWithRotation:(CGAffineTransform)rotation isPortrait:(BOOL)isPortrait
{
    if (BOCImageBrowserIs_iPad || [self deviceAutorotate]) return;
    
    if (self.datas == nil) return;
    
    BOCZoomView *currentZoomView = self.currentZoomView;
    
    if (currentZoomView == nil) return;
    
    NSInteger index = self.currentIndex;
    
    self.scrollView.delegate = nil;
    
    self.view.transform = rotation;
    
    // 如果是竖屏 加间距
    if (isPortrait)
        self.view.bounds = [UIScreen mainScreen].bounds;
     else
        self.view.bounds = CGRectMake(0.0, 0.0, BOCImageBrowserGetScreenHeight, BOCImageBrowserGetScreenWidth);

    CGRect frame = self.view.bounds;
    frame.size.width += self.imageHorizontalSpacing;
    self.scrollView.frame = frame;
    
    [self orientationChangeWithRect:self.view.bounds];
    
    CGFloat width = self.scrollView.frame.size.width;
    
    // 更新frame
    for (BOCZoomView *zoomView in self.visibleViews) {
        
        zoomView.frame = (CGRect){{width * zoomView.indexTag, 0},self.view.bounds.size};
        
        [zoomView didSetImage];
    }
    self.scrollView.contentOffset = CGPointMake(index * width, 0);
    self.scrollView.contentSize = CGSizeMake(width * self.datas.count, 0);

    [self pageLabUpdateFrame];
    
    self.scrollView.delegate = self;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (![self deviceAutorotate]) return;
    
    if (!self.datas.count) return;
    
    BOCZoomView *currentZoomView = self.currentZoomView;
    
    if (currentZoomView == nil) return;
    
    NSInteger index = self.currentIndex;
    
    self.scrollView.delegate = nil;
    
    // 如果是竖屏 加间距
//    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
    CGRect frame = self.view.bounds;
    frame.size.width += self.imageHorizontalSpacing;
    self.scrollView.frame = frame;
//    } else {
//        self.scrollView.frame = self.view.bounds;
//    }
    [self orientationChangeWithRect:self.view.bounds];
    
    CGFloat width = frame.size.width;
    
    // 更新frame
    for (BOCZoomView *zoomView in self.visibleViews) {
        zoomView.frame = (CGRect){{width * zoomView.indexTag, 0},self.view.bounds.size};
        [UIView animateWithDuration:duration animations: ^{
            [zoomView didSetImage];
        }];
    }
    self.scrollView.contentOffset = CGPointMake(index * width, 0);
    self.scrollView.contentSize = CGSizeMake(width * self.datas.count, 0);
    
    self.scrollView.delegate = self;
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
        zoomView.duration = self.animationDuration;
        [zoomView setIsProcessLongPic:self.processTheLongPicture];
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
    if (!self.isBegun) {
        self.isBegun = true;
        self.currentIndex = index;
        CGPoint offset = zoomView.frame.origin;
        self.scrollView.bounds = (CGRect){offset,self.scrollView.bounds.size};
    }

    if ([self isNetworkAtIndex:index]) {
        // 使用SDWebImage 加载网络图片
        [BOCActivityView stopAllAnimatingAndRemoveFromView:zoomView];
        
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
                    if (self.placeholderImage) zoomView.imageView.image = self.placeholderImage;
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
        
        zoomView.imageView.image = path ? [UIImage imageWithContentsOfFile:path] : [UIImage imageNamed:self.datas[index]];
        
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
    [UIView animateWithDuration:self.animationDuration animations:^{
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
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        
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
    if (longPress.state != UIGestureRecognizerStateBegan) return;
        
    if ([self.delegate respondsToSelector:@selector(imageBrowser:image:didLongPress:)]) {
        [self.delegate imageBrowser:self image:zoomView.imageView.image didLongPress:longPress];
        return;
    }
    [self imageViewDidLongPress:zoomView.imageView];
}

- (void)zoomView:(BOCZoomView *)zoomView didOneTap:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(imageBrowser:image:didTap:)]) {
        [self.delegate imageBrowser:self image:zoomView.imageView.image didTap:tap];
        return;
    }
    [self imageViewDidTap:zoomView.imageView];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"%@",[self.languageMan saveFailed]);
        [self showMessage:[self.languageMan saveFailedPleaseCheck]];
    } else {
        NSLog(@"%@",[self.languageMan saveSeccess]);
        [self showMessage:[self.languageMan savePhotoSeccess]];
    }
}

- (void)showMessage:(NSString *)message
{
    // 如果代理没有实现这个方法，就执行保存图片
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[self.languageMan tips] message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ac= [UIAlertAction actionWithTitle:[self.languageMan OK] style:UIAlertActionStyleDefault handler:nil];
    
    [alertVC addAction:ac];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (BOOL)isNetworkAtIndex:(NSInteger)index
{
    return [self.datas[index] containsString:@"http://"];
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

- (BOCLanguageManager *)languageManager
{
    return self.languageMan;
}

- (CGRect)centerImageFrame {
    CGFloat width = self.view.frame.size.width / 3.0;
    CGFloat height = width;
    CGFloat x = (self.view.frame.size.width - width) * 0.5;
    CGFloat y = (self.view.frame.size.height - height) * 0.5;
    return CGRectMake(x, y, width, height);
}

- (BOCLanguageManager *)languageMan
{
    if (_languageMan == nil) {
        _languageMan = [BOCLanguageManager new];
    }
    return _languageMan;
}

#pragma mark - Over ride 交给子类重写
- (void)pageDidChange:(NSInteger)pageNumber totalPage:(NSInteger)totalPage
{
    
}

- (void)imageViewDidLongPress:(UIImageView *)imageView
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[self.languageMan saveThePhoto] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *ac = [UIAlertAction actionWithTitle:[self.languageMan SaveToThePhotoAlbum] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
    UIAlertAction *cancelAC= [UIAlertAction actionWithTitle:[self.languageMan cancel] style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:ac];
    [alertVC addAction:cancelAC];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)imageViewDidTap:(UIImageView *)imageView
{
    [self hideWithAnimation];
}

- (void)orientationChangeWithRect:(CGRect)rect
{
    
}

- (void)dismissAnimation
{
    [self hideWithAnimation];
}
@end

/**
 过期的方法分类
 */
@implementation BOCImageBrowserViewController (ImageBrowserDeprecated)

#pragma mark - Method Deprecated
- (instancetype)initWithDataSource:(NSArray<NSString *> *)datas startIndex:(NSInteger)startIndex isNetwork:(BOOL)isNetwork delegate:( id<BOCImageBrowserViewControllerDelegate>) delegate
{
    return [self initWithSourceArray:datas startIndex:startIndex delegate:delegate];
}

@end
