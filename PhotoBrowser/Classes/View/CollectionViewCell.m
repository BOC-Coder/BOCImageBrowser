//
//  CollectionViewCell.m
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/2.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "CollectionViewCell.h"
#import <UIImageView+WebCache.h>

@interface CollectionViewCell ()

@end

@implementation CollectionViewCell

- (void)awakeFromNib
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
    self.imgView.backgroundColor = [UIColor whiteColor];
}

- (void)setImageWithURL:(NSURL *)url
{
    [self.imgView sd_setImageWithURL:url];
}

- (void)setImageWithFileName:(NSString *)fileName
{
    NSString *path = [[NSBundle mainBundle]pathForResource:fileName ofType:nil];

    self.imgView.image = [UIImage imageWithContentsOfFile:path];
}

@end
