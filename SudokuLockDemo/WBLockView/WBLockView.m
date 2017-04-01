//
//  WBLockView.m
//  SudokuLockDemo
//
//  Created by xyzcwb on 17/3/27.
//  Copyright © 2017年 xyzcwb. All rights reserved.
//

#import "WBLockView.h"
#import <objc/runtime.h>

@interface WBLockView()

/** 选中按钮数组 */
@property (nonatomic, strong) NSMutableArray *selectBtnArray;

/** 当前手指的位置 */
@property (nonatomic, assign) CGPoint currentPoint;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation WBLockView

- (instancetype)init {
    return [self initWithFrame:[self superview].bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addButtonView];
        self.clearDidEndDraw = YES;
        self.showDrawPath = YES;
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionPanPress:)];
        [self addGestureRecognizer:self.panGesture];
    }
    return self;
}
#pragma mark - Action
- (void)actionPanPress:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self];
    switch (pan.state) {
        case UIGestureRecognizerStateChanged:
            [self gestureMoveAtPoint:point];
            break;
        case UIGestureRecognizerStateEnded:
            [self gestureEndAtPoint:point];
            break;
            
        default:
            break;
    }
    [self drawWithPath];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self gestureBeganAtPoint:point];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.panGesture.state != UIGestureRecognizerStateEnded) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        [self gestureEndAtPoint:point];
    }
}
/**
 * 开始
 */
- (void)gestureBeganAtPoint:(CGPoint)point {
    if ([self.delegate respondsToSelector:@selector(lockViewWithDrawPathIsValid:withPath:)]) {
        [self.selectBtnArray removeAllObjects];
        [self setButtonImage];
    }
    for (UIButton *btn in self.subviews) {
        if (CGRectContainsPoint(btn.frame, point) && !btn.selected) {
            btn.selected = YES;
            [self.selectBtnArray addObject:btn];
        }
    }
    self.currentPoint = point;
}
/**
 * 移动中
 */
- (void)gestureMoveAtPoint:(CGPoint)point {
    for (UIButton *btn in self.subviews) {
        if (CGRectContainsPoint(btn.frame, point) && !btn.selected) {
            btn.selected = YES;
            [self.selectBtnArray addObject:btn];
        }
        //撤回已选中的按钮
        else if (CGRectContainsPoint(btn.frame, point) && btn && btn.selected == YES && self.selectBtnArray.count >= 2) {
            if ([self.selectBtnArray indexOfObject:btn] == self.selectBtnArray.count-2) {
                UIButton *btn = [self.selectBtnArray lastObject];
                btn.selected = NO;
                [self.selectBtnArray removeLastObject];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(lockViewDidDraw:withPath:)]) {
        [self.delegate lockViewDidDraw:self withPath:[self getCurrentPath]];
    }
    self.currentPoint = point;
}
/**
 * 结束
 */
- (void)gestureEndAtPoint:(CGPoint)point {
    for (int i = 0; i < self.selectBtnArray.count; i++) {
        UIButton *btn = self.selectBtnArray[i];
        if ([self.delegate respondsToSelector:@selector(lockViewWithDrawPathIsValid:withPath:)]) {
            btn.selected = YES;
        }
        else {
            btn.selected = self.clearDidEndDraw;
        }
        //结束时，currentPoint为最后点击的按钮中心坐标
        if (i == self.selectBtnArray.count-1) {
            self.currentPoint = btn.center;
        }
    }
    //是否是解锁
    if ([self.delegate respondsToSelector:@selector(lockViewWithDrawPathIsValid:withPath:)]) {
        if (![self.delegate lockViewWithDrawPathIsValid:self withPath:[self getCurrentPath]]) {
            for (UIButton *btn in self.subviews) {
                if ([self.delegate respondsToSelector:@selector(lockViewWithButtonImageAtDefeated:)]) {
                    [btn setImage:[UIImage imageNamed:[self.delegate lockViewWithButtonImageAtDefeated:self]] forState:UIControlStateSelected];
                }
            }
            if (self.selectBtnArray.count) {
                self.currentPoint = ((UIButton *)[self.selectBtnArray lastObject]).center;
            }
        }
    }
    else {
        for (int i = 0; i < self.selectBtnArray.count; i++) {
            UIButton *btn = self.selectBtnArray[i];
            btn.selected = !self.isClearDidEndDraw;
            if (i == self.selectBtnArray.count-1) {
                self.currentPoint = btn.center;
            }
        }
        //不是解锁 且 不清除 视图就不能点击了
        self.userInteractionEnabled = self.isClearDidEndDraw;
    }
    if ([self.delegate respondsToSelector:@selector(lockViewDidEndDraw:withPath:)]) {
        [self.delegate lockViewDidEndDraw:self withPath:[self getCurrentPath]];
    }
    if (self.isShowDrawPath) {//结束时清除路径
        for (UIButton *btn in self.selectBtnArray) {
            btn.selected = NO;
        }
        [self.selectBtnArray removeAllObjects];
    }
}

#pragma mark - Private
- (void)addButtonView {
    CGFloat width = self.bounds.size.width < self.bounds.size.height?self.bounds.size.width*0.8:self.bounds.size.height*0.8;
    CGFloat btnWidth = width/4;
    CGFloat space = btnWidth/2;
    for (int i = 0; i < 9; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.userInteractionEnabled = NO;
        btn.tag = i;
        [btn setImage:[UIImage imageNamed:[self.delegate lockViewWithButtonImageAtNormal:self]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[self.delegate lockViewWithButtonImageAtSelected:self]] forState:UIControlStateSelected];
        CGFloat x = (self.bounds.size.width - width)/2 + (space + btnWidth) * (i%3);
        CGFloat y = (self.bounds.size.height - width)/2 + (space + btnWidth) * (i/3);
        
        btn.frame = CGRectMake(x, y, btnWidth, btnWidth);
        [self addSubview:btn];
    }
}
/**
 * 绘制路线
 */
- (void)drawWithPath {
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (self.selectBtnArray.count && self.isShowDrawPath) {
        UIButton *btn = self.selectBtnArray[0];
        [path moveToPoint:btn.center];
        for (int i = 1; i < self.selectBtnArray.count; i++) {
            btn = self.selectBtnArray[i];
            [path addLineToPoint:btn.center];
        }
        [path addLineToPoint:self.currentPoint];
    }
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer.path = [path CGPath];
    self.shapeLayer.lineWidth = self.lineWidth?self.lineWidth:2;
    self.shapeLayer.strokeColor = self.lineColor?self.lineColor.CGColor:[UIColor whiteColor].CGColor;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.shapeLayer];
}
/**
 * 获取路径
 */
- (NSString *)getCurrentPath {
    NSMutableString *path = [NSMutableString string];
    for (int i = 0; i < self.selectBtnArray.count; i++) {
        UIButton *btn = self.selectBtnArray[i];
        [path appendFormat:@"%ld", btn.tag];
    }
    return path;
}

- (void)setButtonImage {
    for (UIButton *btn in self.subviews) {
        [btn setImage:[UIImage imageNamed:[self.delegate lockViewWithButtonImageAtNormal:self]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[self.delegate lockViewWithButtonImageAtSelected:self]] forState:UIControlStateSelected];
        btn.selected = NO;
    }
}
#pragma mark - Seter
- (void)setDelegate:(id<WBLockViewDelegate>)delegate {
    _delegate = delegate;
    [self setButtonImage];
}
- (void)setPath:(NSString *)path {
    _path = path;
    [self.selectBtnArray removeAllObjects];
    for (int i = 0; i < self.subviews.count; i++) {
        UIButton *btn = self.subviews[i];
        if ([path containsString:[NSString stringWithFormat:@"%ld",btn.tag]]) {
            btn.selected = YES;
        }
        else {
            btn.selected = NO;
        }
    }
    self.userInteractionEnabled = NO;
}

#pragma mark - Lazy
- (NSMutableArray *)selectBtnArray {
    if (_selectBtnArray == nil) {
        _selectBtnArray = [NSMutableArray array];
    }
    return _selectBtnArray;
}
- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [[CAShapeLayer alloc] init];
    }
    return _shapeLayer;
}

@end
