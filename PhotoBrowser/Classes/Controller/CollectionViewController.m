//
//  CollectionViewController.m
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/1.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "CustomCollectionViewLayout.h"
#import "BOCImageBrowserViewController.h"

@interface CollectionViewController ()<BOCImageBrowserViewControllerDelegate>

@property (strong, nonatomic) NSArray<NSString *> *datas;

@end

@implementation CollectionViewController

- (NSArray<NSString *> *)datas
{
    if (_datas == nil) {
        
          // 加载本地图片
//        NSMutableArray *tempAry = [NSMutableArray array];
//        for (int i = 1598; i <= 1626; i++) {
//            
//            NSString *str = [NSString stringWithFormat:@"IMG_%d.jpg",i];
//            [tempAry addObject:str];
//        }
//        _datas = [tempAry copy];
        
        // 网络路径
        NSString *path = [[NSBundle mainBundle]pathForResource:@"images.plist" ofType:nil];
        _datas = [NSArray arrayWithContentsOfFile:path];
    }
    return _datas;
}

- (instancetype)init
{
    self = [super initWithCollectionViewLayout:[[CustomCollectionViewLayout alloc]init]];
    if (self) {
        
    }
    return self;
}

static NSString * const reuseIdentifier = @"CollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
        
    // Register cell classes
    [self.collectionView registerNib:[UINib  nibWithNibName:NSStringFromClass([CollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];

    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
//    [cell setImageWithFileName:self.datas[indexPath.item]];

    [cell setImageWithURL:[NSURL URLWithString:self.datas[indexPath.item]]];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 点击cell的时候 弹出图片浏览器
    BOCImageBrowserViewController *vc = [[BOCImageBrowserViewController alloc]initWithDataSource:self.datas startIndex:indexPath.item isNetwork:YES delegate:self];
 
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - <BOCImageBrowserViewControllerDelegate>
- (UIImageView *)imageBrowser:(BOCImageBrowserViewController *)imageBrowser imageViewForStartAnimationAtIndex:(NSInteger)index
{
    CollectionViewCell *cell = (CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    return cell.imgView;
}


@end
