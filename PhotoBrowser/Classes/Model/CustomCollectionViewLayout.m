//
//  CustomCollectionViewLayout.m
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/2.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "CustomCollectionViewLayout.h"

@interface CustomCollectionViewLayout ()

@property (assign, nonatomic) int cols;

@end

@implementation CustomCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cols = 3;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    CGFloat margin = 15.0;
    
    CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat itemWH = (ScreenWidth - margin * (self.cols + 1)) / self.cols;
    
    self.itemSize = CGSizeMake(itemWH, itemWH);
    
    self.minimumInteritemSpacing = margin;
    self.minimumLineSpacing = margin;
    
    self.collectionView.contentInset = UIEdgeInsetsMake(64, margin, 0, margin);
}


@end
