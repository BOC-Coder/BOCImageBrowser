//
//  CollectionViewCell.h
//  PhotoBrowser
//
//  Created by LeungChaos on 16/7/2.
//  Copyright © 2016年 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

- (void)setImageWithURL:(NSURL *)url;

- (void)setImageWithFileName:(NSString *)fileName;

@end
