//
//  BOCLanguageManager.h
//  PhotoBrowser
//
//  Created by LeungChaos on 16/9/26.
//  Copyright © 2016年 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOCLanguageManager : NSObject

#pragma mark - 文字对照方法
- (NSString *)saveThePhoto;
- (NSString *)SaveToThePhotoAlbum;
- (NSString *)cancel;
- (NSString *)saveFailed;
- (NSString *)saveFailedPleaseCheck;
- (NSString *)saveSeccess;
- (NSString *)savePhotoSeccess;
- (NSString *)tips;
- (NSString *)OK;

@end
