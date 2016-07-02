//
//  TableViewCell.h
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/2.
//  Copyright © 2016年 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TableViewCell;
typedef void(^TableViewCellImageDidClickBlock)(TableViewCell *cell,UIImageView *imageView);

@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) UILabel *lab;

- (void)setBlock:(TableViewCellImageDidClickBlock)block;

- (UIImageView *)imageViewAtIndex:(NSInteger)index;

- (void)setFilePaths:(NSArray<NSString *> *)datas;

- (void)setDatas:(NSArray<NSString *> *)datas;

@end
