//
//  TableViewCell.m
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/2.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "TableViewCell.h"
#import <UIImageView+WebCache.h>

@interface TableViewCell ()

@property (weak, nonatomic) UIView *imageViewContainerView;

@property (copy, nonatomic) TableViewCellImageDidClickBlock block;

@property (strong, nonatomic) NSArray<NSString *> *datas;

@end

static NSInteger cols = 3;

@implementation TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        [self setup];
    }
    return self;
}

- (void)setup
{
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_lab) {
        _lab.frame = CGRectMake(10, 10, 100, 30);
    }
    
    if (_imageViewContainerView) {
        
        CGFloat containerWH = self.frame.size.width;
        
        _imageViewContainerView.frame = CGRectMake(0, 50, containerWH, containerWH);
        
        CGFloat margin = 10;
        
        CGFloat imgWH = (containerWH - margin * (cols + 1)) / cols;
        
        [_imageViewContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            obj.frame = CGRectMake( idx % cols * (imgWH + margin) + margin, idx / cols * (imgWH + margin), imgWH, imgWH);
                        
        }];
    }
}

- (void)setDatas:(NSArray<NSString *> *)datas
{
    _datas = datas;

    NSInteger count = datas.count;
    
    [self.imageViewContainerView.subviews makeObjectsPerformSelector:@selector(setHidden:)
                                                          withObject:@(YES)];
    
    [self.imageViewContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == count - 1) {
            *stop = YES;
        }
        
        obj.hidden = NO;
        
        [obj sd_setImageWithURL:[NSURL URLWithString:datas[idx]]];
    }];
}

- (void)setFilePaths:(NSArray<NSString *> *)datas
{
    _datas = datas;
    
    NSInteger count = datas.count;
    
    
    [self.imageViewContainerView.subviews makeObjectsPerformSelector:@selector(setHidden:)
                                                          withObject:@(YES)];
    
    [self.imageViewContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.hidden = NO;
        
        if (idx == count - 1) {
            *stop = YES;
        }
        
        NSString *path = [[NSBundle mainBundle]pathForResource:datas[idx] ofType:nil];

        obj.image = [UIImage imageWithContentsOfFile:path];
    }];

}

- (void)setBlock:(TableViewCellImageDidClickBlock)block
{
    _block = block;
}

- (UIImageView *)imageViewAtIndex:(NSInteger)index
{
    if (index >= self.imageViewContainerView.subviews.count) return nil;
        
    return self.imageViewContainerView.subviews[index];
}

#pragma mark - lazy load
- (UILabel *)lab {
    if (_lab == nil) {
        UILabel *lab = [UILabel new];
        lab.textColor = [UIColor darkGrayColor];
        
        [self.contentView addSubview:lab];
        _lab = lab;
    }
    return _lab;
}


- (UIView *)imageViewContainerView
{
    if (_imageViewContainerView == nil) {
        
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:view];
        
        for (int i = 0; i < 9; i++) {
            
            UIImageView *imgView = [self tapGesImageView];
            
            imgView.tag = i;
            
            [view addSubview:imgView];
        }
        
        _imageViewContainerView = view;
    }
    return _imageViewContainerView;
}

- (UIImageView *)tapGesImageView
{
    UIImageView *imageView = [UIImageView new];
    imageView.backgroundColor = [UIColor lightGrayColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    
    imageView.userInteractionEnabled = YES;
    
    [imageView addGestureRecognizer:tap];
    
    return imageView;
}

- (void)tap:(UITapGestureRecognizer *)tap
{
    if (self.block) {
        self.block(self, (UIImageView *)tap.view);
    }
}

@end
