//
//  AttributedStrModel.h
//  HTMLAnalysisDemo
//
//  Created by ztcj_develop_mini on 2019/3/25.
//  Copyright © 2019 ztcj_develop_mini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    ImageAttributedStrType = 0,
    TextAttributedStrType,
}AttributedStrType;

@interface AttributedStrModel : NSObject

@property (nonatomic, assign)AttributedStrType              type;
@property (nonatomic, strong)NSMutableAttributedString      *attributeStr;  //文本内容
@property (nonatomic, copy)NSString                         *link;          //超链接
@property (nonatomic, copy)NSString                         *imgName;       //图片名称,即图片URL路径后面带的图片名称
@property (nonatomic, strong)UIImage                        *image;         //加载完成的图片对象

@end

