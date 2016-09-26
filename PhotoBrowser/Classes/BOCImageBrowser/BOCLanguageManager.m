//
//  BOCLanguageManager.m
//  PhotoBrowser
//
//  Created by LeungChaos on 16/9/26.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "BOCLanguageManager.h"

#define boc_return_value(dict) return dict[self.currentKey];

@interface BOCLanguageManager()

@property (strong, nonatomic) NSString *currentKey;

@property (strong, nonatomic) NSArray *languageKeys;

@end

static NSString * const BOCLanguageSimplifiedChineseKey = @"zh-Hans-US";
static NSString * const BOCLanguageTraditionalChineseKey = @"zh-Hant-US";
static NSString * const BOCLanguageTraditionalChinese_HK_Key = @"zh-HK";
static NSString * const BOCLanguageEnglishKey = @"en-US";

@implementation BOCLanguageManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *languageKey = [self getPreferredLanguage];
        for (NSString *key in self.languageKeys) {
            if ([key isEqualToString:languageKey]) {
                self.currentKey = key;
            }
        }
        if (!self.currentKey) {
            self.currentKey = BOCLanguageEnglishKey;
        }
    }
    return self;
}

- (NSArray *)languageKeys
{
    if (_languageKeys == nil) {
        _languageKeys = @[
                          BOCLanguageEnglishKey,
                          BOCLanguageSimplifiedChineseKey,
                          BOCLanguageTraditionalChinese_HK_Key,
                          BOCLanguageTraditionalChineseKey
                          ];
    }
    return _languageKeys;
}

- (NSString *)getPreferredLanguage
{
    NSArray * allLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    return allLanguages.firstObject;
}

#pragma mark - 文字对照
- (NSString *)saveThePhoto
{
    NSDictionary *dic = @{
                          BOCLanguageEnglishKey : @"Save the photo",
                          BOCLanguageSimplifiedChineseKey : @"保存图片",
                          BOCLanguageTraditionalChinese_HK_Key : @"儲存圖片",
                          BOCLanguageTraditionalChineseKey : @"保存圖片"
                          };
    boc_return_value(dic)
}

- (NSString *)SaveToThePhotoAlbum
{
    NSDictionary *dic = @{
                          BOCLanguageEnglishKey : @"Save to the photo album",
                          BOCLanguageSimplifiedChineseKey : @"保存图片到相册",
                          BOCLanguageTraditionalChinese_HK_Key : @"儲存圖片至相冊",
                          BOCLanguageTraditionalChineseKey : @"保存圖片到相冊"
                          };
    boc_return_value(dic)
}
- (NSString *)cancel
{
    NSDictionary *dic = @{
                          BOCLanguageEnglishKey : @"cancel",
                          BOCLanguageSimplifiedChineseKey : @"取消",
                          BOCLanguageTraditionalChinese_HK_Key : @"取消",
                          BOCLanguageTraditionalChineseKey : @"取消"
                          };
    boc_return_value(dic)
}
- (NSString *)saveFailed
{
    NSDictionary *dic = @{
                          BOCLanguageEnglishKey : @"Save failed !",
                          BOCLanguageSimplifiedChineseKey : @"保存失败",
                          BOCLanguageTraditionalChinese_HK_Key : @"儲存失敗",
                          BOCLanguageTraditionalChineseKey : @"保存失敗"
                          };
    boc_return_value(dic)
}
- (NSString *)saveFailedPleaseCheck
{
    NSDictionary *dic = @{
                          BOCLanguageEnglishKey : @"Save the photo failed, please check the Storage Space in you device",
                          BOCLanguageSimplifiedChineseKey : @"保存图片失败, 请检查您的储存空间",
                          BOCLanguageTraditionalChinese_HK_Key : @"儲存圖片失敗,請檢查設備的儲存空間",
                          BOCLanguageTraditionalChineseKey : @"保存圖片失敗,請檢查你的儲存空間"
                          };
    boc_return_value(dic)
}
- (NSString *)saveSeccess
{
    NSDictionary *dic = @{
                          BOCLanguageEnglishKey : @"Save seccess",
                          BOCLanguageSimplifiedChineseKey : @"保存成功",
                          BOCLanguageTraditionalChinese_HK_Key : @"儲存成功",
                          BOCLanguageTraditionalChineseKey : @"保存成功"
                          };
    boc_return_value(dic)
}

- (NSString *)savePhotoSeccess
{
    NSDictionary *dic = @{
                          BOCLanguageEnglishKey : @"Save photo seccess",
                          BOCLanguageSimplifiedChineseKey : @"保存图片成功",
                          BOCLanguageTraditionalChinese_HK_Key : @"儲存圖片成功",
                          BOCLanguageTraditionalChineseKey : @"保存圖片成功"
                          };
    boc_return_value(dic)
}
- (NSString *)tips
{
    NSDictionary *dic = @{
                          BOCLanguageEnglishKey : @"tips",
                          BOCLanguageSimplifiedChineseKey : @"提示",
                          BOCLanguageTraditionalChinese_HK_Key : @"提示",
                          BOCLanguageTraditionalChineseKey : @"提示"
                          };
    boc_return_value(dic)
}
- (NSString *)OK
{
    NSDictionary *dic = @{
                          BOCLanguageEnglishKey : @"OK",
                          BOCLanguageSimplifiedChineseKey : @"确认",
                          BOCLanguageTraditionalChinese_HK_Key : @"確定",
                          BOCLanguageTraditionalChineseKey : @"確認"
                          };
    boc_return_value(dic)
}

@end
