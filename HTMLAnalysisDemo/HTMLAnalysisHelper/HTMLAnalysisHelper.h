//
//  HTMLAnalysisHelper.h
//  HTMLAnalysisDemo
//
//  Created by ztcj_develop_mini on 2019/3/25.
//  Copyright © 2019 ztcj_develop_mini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kScreen_WIDTH               [UIScreen mainScreen].bounds.size.width
#define kDefaultFontSize            16.0
#define kDefaultImgWidth            kScreen_WIDTH
#define kDefaultTextLineSpacing     2.0
#define kDefaultParagraphSpacing    (kDefaultTextLineSpacing * 2)

@interface HTMLAnalysisHelper : NSObject

@property (nonatomic, assign)CGFloat                    fontSize;           //统一的字体大小
@property (nonatomic, assign)CGFloat                    imageWidth;         //图片宽度
@property (nonatomic, assign)CGFloat                    textLineSpacing;    //行间距
@property (nonatomic, assign)CGFloat                    paragraphSpacing;   //段间距

@property (nonatomic, strong)NSMutableAttributedString  *closeStr;          //
@property (nonatomic, strong)NSMutableAttributedString  *openStr;           //

- (void)analysisWithHTMLStr:(NSString *)htmlStr;
- (void)getImgUrlArrWithHTMLStr:(NSString *)htmlStr;

@property (nonatomic, copy)void(^linkClickedBlock)(NSString *linkStr);      //点击超链接
@property (nonatomic, copy)void(^openCloseBlock)(void);                     //展开关闭
@property (nonatomic, copy)void(^imageClickedBlock)(UIImage *image);        //点击图片

@end

