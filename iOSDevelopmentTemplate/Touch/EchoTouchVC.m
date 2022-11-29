//
//  EchoTouchVC.m
//  iOSDevelopmentTemplate
//
//  Created by chengzi on 2022/11/28.
//

#import "EchoTouchVC.h"

/// 一些全屏弹窗视图，希望点击内容以为区域，取消弹窗，点击内容区域，不响应
@interface EchoTouchVC () <UIGestureRecognizerDelegate>
/// 父视图
@property (nonatomic, strong) UIView *parentView;
/// 子视图
@property (nonatomic, strong) UIView *childView;
@end

@implementation EchoTouchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch
{
    BOOL result = YES;
    // 方法一：使用isDescendantOfView:, 很神奇不怎么用到方法 从属关系，例如视图V添加V1，V1添加V2，那么V1，V2都从属于V，所以可以使用touch.view判断是否从属childView
    {
        result = [touch.view isDescendantOfView:self.childView];
        NSLog(@"方法1:%@在子视图上", result ? @"点击" : @"没有点击");
    }
    
    // 方法二：使用layer的containsPoint: 方法
    {
        CGPoint point = [touch locationInView:self.childView];
        result = [self.parentView.layer containsPoint:point];
        NSLog(@"方法1:%@在子视图上", result ? @"点击" : @"没有点击");
    }
    
    // 方法三：使用CGRectContainsPoint: 传入要判断视图的bounds 和触摸点
    {
        CGPoint point = [touch locationInView:self.childView];
        result = CGRectContainsPoint(self.childView.bounds, point);
        NSLog(@"方法3:%@在子视图上", result ? @"点击" : @"没有点击");
    }
    
    // 方法四：坐标转换convertPoint:fromView: 或者layer的convertPoint:fromLayer:方法，再判断是否是在该视图范围内 containsPoint:
    {
        CGPoint point = [touch locationInView:self.parentView];
        point = [self.childView convertPoint:point fromView:self.parentView];
        result = [self.childView.layer containsPoint:point];
        NSLog(@"方法4:%@在子视图上", result ? @"点击" : @"没有点击");
    }
    return result;
}

#pragma mark - action
- (void)parentTap {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)childTap {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
#pragma mark - setUI
- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"手势&点击";
    
    [self.view addSubview:self.parentView];
    [self.parentView addSubview:self.childView];
    
    self.parentView.frame = CGRectMake(100, 400, 300, 300);
    self.childView.frame = CGRectMake(100, 100, 100, 100);
    
    UITapGestureRecognizer *gesP = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(parentTap)];
    gesP.delegate = self;
    [self.parentView addGestureRecognizer:gesP];

//    UITapGestureRecognizer *gesC = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(childTap)];
//    gesC.delegate = self;
//    [self.childView addGestureRecognizer:gesC];
}

#pragma mark -getter
- (UIView *)parentView {
    if (!_parentView) {
        _parentView = [[UIView alloc] init];
        _parentView.backgroundColor = [UIColor redColor];
    }
    return _parentView;
}

- (UIView *)childView {
    if (!_childView) {
        _childView = [[UIView alloc] init];
        _childView.backgroundColor = [UIColor yellowColor];
    }
    return _childView;
}
@end
