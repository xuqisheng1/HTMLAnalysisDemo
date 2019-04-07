//
//  HTMLAnalysisHelper.m
//  HTMLAnalysisDemo
//
//  Created by ztcj_develop_mini on 2019/3/25.
//  Copyright © 2019 ztcj_develop_mini. All rights reserved.
//

#import "HTMLAnalysisHelper.h"

#import "AttributedStrModel.h"

#import <YYText.h>
#import <TFHpple/TFHpple.h>
#import <UIImageView+WebCache.h>

@interface HTMLAnalysisHelper ()

@property (nonatomic, strong)NSMutableArray *attributeStrArr;
@property (nonatomic, strong)NSMutableArray *imgUrlStrArr;          //html中所嵌的图片url 数组

@end

@implementation HTMLAnalysisHelper

- (instancetype)init
{
    if (self = [super init]) {
        self.fontSize = kDefaultFontSize;
        self.imageWidth = kDefaultImgWidth;
        self.textLineSpacing = kDefaultTextLineSpacing;
        self.paragraphSpacing = kDefaultParagraphSpacing;
    }
    return self;
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    [self getAttributeStrWithOpenState:YES];
    [self getAttributeStrWithOpenState:NO];
}

- (void)setImageWidth:(CGFloat)imageWidth
{
    _imageWidth = imageWidth;
    [self getAttributeStrWithOpenState:YES];
    [self getAttributeStrWithOpenState:NO];
}

- (void)setTextLineSpacing:(CGFloat)textLineSpacing
{
    _textLineSpacing = textLineSpacing;
    [self getAttributeStrWithOpenState:YES];
    [self getAttributeStrWithOpenState:NO];
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing
{
    _paragraphSpacing = paragraphSpacing;
    [self getAttributeStrWithOpenState:YES];
    [self getAttributeStrWithOpenState:NO];
}

#pragma mark -- 解析字符串，放到一个数组里
- (void)analysisWithHTMLStr:(NSString *)htmlStr
{
    //先转成富文本
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithData:[htmlStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    
    //枚举取出所有富文本，放到一个AttributedStrModel数组里
    [self.attributeStrArr removeAllObjects];
    __weak typeof(self) wself = self;
    [attributeString enumerateAttributesInRange:NSMakeRange(0, attributeString.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        
        //        NSLog(@"%@",attrs);
        
        //创建模型装载数据对象
        AttributedStrModel *attributeStrModel = [[AttributedStrModel alloc]init];
        
        NSTextAttachment *attachment = [attrs objectForKey:NSAttachmentAttributeName];
        if (attachment) {   //图片
            attributeStrModel.type = ImageAttributedStrType;
            // attachment.fileWrapper.preferredFilename  拿到的是URL路径最后面的图片名称
            attributeStrModel.imgName = [attachment.fileWrapper.preferredFilename componentsSeparatedByString:@"."].firstObject;
        }
        else{               // 文本
            
            attributeStrModel.type = TextAttributedStrType;
            
            //调整字体大小为我们想要的大小
            attributeStrModel.attributeStr = [[NSMutableAttributedString alloc]initWithAttributedString:[attributeString attributedSubstringFromRange:range]];
            UIFont *font = [attrs objectForKey:NSFontAttributeName];
            if (!font) {
                font = [UIFont systemFontOfSize:self.fontSize];
            }
            else{
                font = [UIFont fontWithName:font.fontName size:self.fontSize];
            }
            attributeStrModel.attributeStr.yy_font = font;
            attributeStrModel.attributeStr.yy_color = [UIColor blackColor];
            
            //去掉超链接的下划线
            NSURL *link = [attrs objectForKey:NSLinkAttributeName];
            if (link) {
                attributeStrModel.attributeStr.yy_underlineStyle = NSUnderlineStyleNone;
            }
        }
        
        [wself.attributeStrArr addObject:attributeStrModel];
    }];
    
    [self getAttributeStrWithOpenState:YES];
    [self getAttributeStrWithOpenState:NO];
    
    [self getImgUrlArrWithHTMLStr:htmlStr];
}

#pragma mark -- 获取所有的图片URL并加载
- (void)getImgUrlArrWithHTMLStr:(NSString *)htmlStr
{
    [self.imgUrlStrArr removeAllObjects];
    
    NSData *data = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc]initWithHTMLData:data];
    // 获取所有的图片链接
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//img"];
    
    for (TFHppleElement *element in elements) {
        if (element.attributes[@"src"]) {
            [self.imgUrlStrArr addObject:element.attributes[@"src"]];
        }
    }
    
    //加载图片
    __weak typeof(self) wself = self;
    for (NSString *imgUrlStr in self.imgUrlStrArr) {
        
        //取出URL路径最后面的图片名称
        NSString *imgName = [[[imgUrlStr componentsSeparatedByString:@"?"] firstObject] lastPathComponent];
        imgName = [imgName componentsSeparatedByString:@"."].firstObject;
        
        NSURL *imgUrl = [NSURL URLWithString:imgUrlStr];
        SDWebImageManager *manager = [SDWebImageManager sharedManager] ;
        [manager downloadImageWithURL:imgUrl options:0 progress:^(NSInteger   receivedSize, NSInteger expectedSize) {
            // progression tracking code
        }  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,   BOOL finished, NSURL *imageURL) {
            if (image) {
                for (AttributedStrModel *strModel in wself.attributeStrArr) {
                    if (strModel.type == ImageAttributedStrType) {
                        
                        //比对图片名称是否一致
                        if ([strModel.imgName isEqualToString:imgName]) {
                            strModel.image = image;
                            [wself getAttributeStrWithOpenState:YES];
                            break;
                        }
                    }
                }
            }
        }];
    }
}

#pragma mark -- 获取展开和关闭的富文本内容
- (void)getAttributeStrWithOpenState:(BOOL)isOpen
{
    if (!self.attributeStrArr.count) {
        return;
    }
    
    //拼接要显示的字符串
    NSMutableAttributedString *attributeStrM = [[NSMutableAttributedString alloc]init];
    for (AttributedStrModel *strModel in self.attributeStrArr) {
        
        //收起状态下只拼接文本
        if (strModel.type == TextAttributedStrType) {
            [attributeStrM appendAttributedString:strModel.attributeStr];
        }
        //展开状态下且图片已加载完成则拼接上图片
        else if (strModel.type == ImageAttributedStrType && strModel.image && isOpen){
            
            //等比缩放
            CGFloat imageW = self.imageWidth;
            CGFloat imageH = self.imageWidth / strModel.image.size.width * strModel.image.size.height;
            
            NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:strModel.image contentMode:UIViewContentModeScaleAspectFill attachmentSize:CGSizeMake(imageW, imageH) alignToFont:[UIFont systemFontOfSize:self.fontSize] alignment:YYTextVerticalAlignmentCenter];
            [attributeStrM appendAttributedString:attachText];
            
            
        }
    }
    attributeStrM.yy_lineSpacing = self.textLineSpacing;
    attributeStrM.yy_paragraphSpacing = self.paragraphSpacing;
    
    //添加点击  所有内容  实现展开关闭事件
    __weak typeof(self) wself = self;
    [attributeStrM yy_setTextHighlightRange:NSMakeRange(0, attributeStrM.length) color:[UIColor blackColor] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        if (wself.openCloseBlock) {
            wself.openCloseBlock();
        }
    }];
    
    //添加点击  超链接 & 点击图片  的回调
    [attributeStrM enumerateAttributesInRange:NSMakeRange(0, attributeStrM.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        
        NSURL *link = [attrs objectForKey:NSLinkAttributeName];
        
        //有超链接
        if (link) {
            [attributeStrM yy_setTextHighlightRange:range color:[UIColor blueColor] backgroundColor:[UIColor lightGrayColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                if (wself.linkClickedBlock) {
                    wself.linkClickedBlock(link.absoluteString);
                }
            }];
        }
        
        YYTextAttachment *attachment = [attrs objectForKey:YYTextAttachmentAttributeName];
        //图片不为空
        if (attachment) {
            
            [attributeStrM yy_setTextHighlightRange:range color:nil backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                
                if (wself.imageClickedBlock) {
                    wself.imageClickedBlock(attachment.content);
                }
            }];
        }
    }];
    
    if (isOpen) {
        self.openStr = attributeStrM;
    }
    else{
        self.closeStr = attributeStrM;
    }
}


#pragma mark -- LazyLoad
- (NSMutableArray *)attributeStrArr
{
    if (!_attributeStrArr) {
        _attributeStrArr = [[NSMutableArray alloc]init];
    }
    return _attributeStrArr;
}

- (NSMutableArray *)imgUrlStrArr
{
    if (!_imgUrlStrArr) {
        _imgUrlStrArr = [[NSMutableArray alloc]init];
    }
    return _imgUrlStrArr;
}



@end
