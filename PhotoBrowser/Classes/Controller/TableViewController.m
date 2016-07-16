//
//  TableViewController.m
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/1.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"
#import "BOCImageBrowserViewController.h"

@interface TableViewController ()<BOCImageBrowserViewControllerDelegate>

@property (strong, nonatomic) NSArray<NSString *> *datas;

@property (weak, nonatomic) TableViewCell *currentCell;


@end

static NSString *TableViewCellIdentifier = @"TableViewCellIdentifier";

@implementation TableViewController

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
        
        // 网络路径 (缩略图)
        NSString *path = [[NSBundle mainBundle]pathForResource:@"smallimage.plist" ofType:nil];
        _datas = [NSArray arrayWithContentsOfFile:path];
    }
    return _datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    self.tableView.rowHeight = 480;
    
    [self.tableView registerClass:[TableViewCell class] forCellReuseIdentifier:TableViewCellIdentifier];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier forIndexPath:indexPath];
    
    [cell setDatas:self.datas];
    
    cell.lab.text = [NSString stringWithFormat:@"---%ld---",indexPath.row];
    
    // 点击了图片是回调
    [cell setBlock:^(TableViewCell *cell, UIImageView *imageView) {
        
        [self showImageBroswerWithCell:cell atIndex:imageView.tag];
        
    }];
    
    return cell;
}


- (void)showImageBroswerWithCell:(TableViewCell *)cell atIndex:(NSInteger)index
{
    // 拼接大图的路径
    NSMutableArray<NSString *> *tempAry = [NSMutableArray array];
    [self.datas enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableString *bigImageUrl = [NSMutableString stringWithString:obj];
        
        NSRange range = [bigImageUrl rangeOfString:@"thumbnail"];
        
        [bigImageUrl replaceCharactersInRange:range withString:@"large"];
        
        [tempAry addObject:bigImageUrl];
        
    }];
    
    self.currentCell = cell;
    
    // 创建图片浏览器
    BOCImageBrowserViewController *vc =
    [[BOCImageBrowserViewController alloc]initWithDataSource:tempAry
     
                                                  startIndex:index
     
                                                   isNetwork:YES
     
                                                    delegate:self];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}

#pragma mark - <BOCImageBrowserViewControllerDelegate>
/**
 *  实现代理方法 返回与下标相对应的 UIImageView
 */
- (UIImageView *)imageBrowser:(BOCImageBrowserViewController *)imageBrowser imageViewForStartAnimationAtIndex:(NSInteger)index
{
    UIImageView *imgView = [self.currentCell imageViewAtIndex:index];
    
    return imgView;
}


@end
