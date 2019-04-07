//
//  ViewController.m
//  HTMLAnalysisDemo
//
//  Created by ztcj_develop_mini on 2019/3/21.
//  Copyright © 2019 ztcj_develop_mini. All rights reserved.
//

#import "ViewController.h"

#import <YYText.h>
#import "HTMLAnalysisHelper/HTMLAnalysisHelper.h"

#define kCloseLineNum       3

#define kContentFontSize    16.0
#define kContentFont        [UIFont systemFontOfSize:kContentFontSize]

@interface ViewController ()

@property (nonatomic, strong)YYLabel            *contentLbl;

@property (nonatomic, copy)NSString             *HTMLStr;
@property (nonatomic, strong)HTMLAnalysisHelper *helper;

@property (nonatomic, assign)BOOL               openState;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildView];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)buildView
{
    [self.view addSubview:self.contentLbl];
    self.contentLbl.frame = CGRectMake(0, 20, kScreen_WIDTH, 0);
    
    //解析HTML字符串
    [self.helper analysisWithHTMLStr:self.HTMLStr];
    
    self.contentLbl.attributedText = self.helper.closeStr;
    
    //调整高度
    CGRect frame = self.contentLbl.frame;
    frame.size.height = [self getYYLabelHeight:self.contentLbl];
    self.contentLbl.frame = frame;
}


/**
 * 根据内容高度获取YYLabel标签的高度
 */
- (CGFloat)getYYLabelHeight:(YYLabel *)label
{
    NSMutableAttributedString *innerText = [label valueForKey:@"_innerText"];
    YYTextContainer *innerContainer = [label valueForKey:@"_innerContainer"];
    
    YYTextContainer *container = [innerContainer copy];
    container.size = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:innerText];
    return layout.textBoundingSize.height;
}

- (void)changeOpenState
{
    self.openState = !self.openState;
    
    self.contentLbl.attributedText = self.openState?self.helper.openStr:self.helper.closeStr;
    self.contentLbl.numberOfLines = self.openState?0:kCloseLineNum;
    
    //调整高度
    CGRect frame = self.contentLbl.frame;
    frame.size.height = [self getYYLabelHeight:self.contentLbl];
    self.contentLbl.frame = frame;
}

#pragma mark -- LazyLoad
- (YYLabel *)contentLbl
{
    if (!_contentLbl) {
        _contentLbl = [[YYLabel alloc] init];
        _contentLbl.backgroundColor = [UIColor yellowColor];
        _contentLbl.textVerticalAlignment = YYTextVerticalAlignmentTop;
        _contentLbl.numberOfLines = kCloseLineNum;
        _contentLbl.font = kContentFont;
       
        [self addSeeMoreButton];
    }
    return _contentLbl;
}

#pragma mark -- 添加全文展开按钮
- (void)addSeeMoreButton
{
    NSString *allStr = @"...全文";
    
    NSMutableAttributedString *truncationStr = [[NSMutableAttributedString alloc] initWithString:allStr];
    
    __weak typeof(self) wself = self;
    [truncationStr yy_setTextHighlightRange:[truncationStr.string rangeOfString:@"全文"] color:[UIColor blueColor] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        [wself changeOpenState];
    }];
    
    truncationStr.yy_font = kContentFont;
    
    YYLabel *seeMore = [[YYLabel alloc]init];
    seeMore.attributedText = truncationStr;
    [seeMore sizeToFit];
    
    NSAttributedString *truncationToken = [NSAttributedString yy_attachmentStringWithContent:seeMore contentMode:UIViewContentModeCenter attachmentSize:seeMore.frame.size alignToFont:truncationStr.yy_font alignment:YYTextVerticalAlignmentCenter];
    _contentLbl.truncationToken = truncationToken;
}


- (NSString *)HTMLStr
{
    if (!_HTMLStr) {
        _HTMLStr = @"<p>这是一个测试跳转链接<a href=\"https://www.baidu.com\" target=\"_blank\" rel=\"noopener\">超链接</a>,可以点击跳转。其他标签也可以，主要是带有交互事件的标签需要我们自己解析，采用原生的交互方法</p> <p><img class=\" wscnph\" src=\"http://www.qqma.com/imgpic2/cpimagenew/2018/4/5/c89de4fadcf34dd58bbe789d00a58824.jpg\" data-wscntype=\"image\" data-wscnh=\"636\" data-wscnw=\"823\" /></p> <p>这是另外一段文字，<strong>粗体字</strong>测试,中文不支持<i>斜体字</i>，英文可以 <i>abcde</i></p>";
    }
    return _HTMLStr;
}

- (HTMLAnalysisHelper *)helper
{
    if (!_helper) {
        _helper = [[HTMLAnalysisHelper alloc]init];
        
        __weak typeof(self) wself = self;
        _helper.openCloseBlock = ^{
            [wself changeOpenState];
        };
        
        _helper.linkClickedBlock = ^(NSString * _Nonnull linkStr) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkStr]];
        };
        
        _helper.imageClickedBlock = ^(UIImage * _Nonnull image) {
            NSLog(@"点击了图片：%@",image);
        };
    }
    return _helper;
}

@end
