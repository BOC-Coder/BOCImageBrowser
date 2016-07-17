# BOCImageBroswer

###Description:
######简单使用
- 超简单的使用方法，两句代码就可以实现
- 实现代理方法就可以拥有缩放会原位的效果
- 类似微信／微博等的图片浏览器的效果

######支持
- 对iPhone支持的三个方向旋转
- 只支持竖屏的项目也可以旋转
- 对iPad支持全部方向的旋转
- 已实现重用机制，不必担心内存
- 支持iOS8.0以上
- 单击退出，双击放大缩小，长按保存图片

###Demo:
-  无论你的项目是否支持横竖屏，它都可以旋转

![PB2.gif](http://upload-images.jianshu.io/upload_images/2385017-1cba983496362734.gif?imageMogr2/auto-orient/strip)
###How to use:

- 下载zip文件
- 到开工程，把BOCImageBrowser文件夹拖到自己的项目中
- ＊注意＊ BOCImageBrowser的图片下载依赖SDWebImage框架，如果没有SDWebImage将不能正常使用

####Create BOCImageBrowser

```objc

/**
*  @param datas      需要加载的图片路径
*  @param startIndex 从哪一张开始显示
*  @param isNetwork  是否加载网络图片
*  @param delegate   成为代理的对象
*
*  PS: if isNetwork is YES , datas中的元素为 图片的网络url字符串 , else datas中的元素为 image的文件名(非全路径)
*/

// 点击cell的时候 弹出图片浏览器
BOCImageBrowserViewController *vc =
[[BOCImageBrowserViewController alloc]initWithDataSource:self.datas
startIndex:indexPath.item
isNetwork:YES
delegate:self];

[self presentViewController:vc animated:YES completion:nil];


```

####@Implement Delegate method

```objc
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
// 实现了该方法才会有图片缩放的动画效果
- (UIImageView *)imageBrowser:(BOCImageBrowserViewController *)imageBrowser imageViewForStartAnimationAtIndex:(NSInteger)index
{
![PB2.gif](http://upload-images.jianshu.io/upload_images/2385017-eb1f928ba62d766d.gif?imageMogr2/auto-orient/strip)
CollectionViewCell *cell = (CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
ddasdaadaasd
return cell.imgView;
}

/**
*  当图片被长按时回调这个方法
*
*  ******  如果没有实现这个方法，默认就是弹出ActionSheet提示保存图片到相册  *******
*
*  @param iamge        当前显示在浏览器上的图片
*  @param longPress    长按的UILongPressGestureRecognizer对象
*/
- (void)imageBrowser:(BOCImageBrowserViewController *)imageBrowser image:(UIImage *)iamge didLongPress:(UILongPressGestureRecognizer *)longPress {
// 监听某一张图片的长按事件
}

```
