//
//  LockViewController.m
//  SudokuLockDemo
//
//  Created by xyzcwb on 2017/3/31.
//  Copyright © 2017年 xyzcwb. All rights reserved.
//

#import "LockViewController.h"
#import "WBLockView.h"
#import "Masonry.h"

typedef NS_ENUM(NSInteger, WBSetLockType) {
    /** 第一次设置 */
    WBFirstSetLock,
    /** 设置手势的时候再次验证 */
    WBCheckAgainLock,
    /** 校验 */
    WBCheckLoginLock
};
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface LockViewController ()<WBLockViewDelegate>
@property (nonatomic, strong) UILabel *mLabelTitle;
@property (nonatomic, strong) UILabel *mLabelCenter;
@property (nonatomic, strong) UIButton *mBtnLeft;
@property (nonatomic, assign) WBSetLockType setLockType;
@property (nonatomic, strong) WBLockView *mLockView;
@property (nonatomic, copy) NSString *mLockPath;

@end

@implementation LockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViews];
    self.mLabelTitle.text = @"手势密码设置";
    self.mLabelCenter.text = @"请绘制解锁图案，不少于4个点";
    self.mLabelCenter.textColor = [UIColor whiteColor];
    self.mBtnLeft.hidden = YES;
    self.mLockView.clearDidEndDraw = YES;
    
}

#pragma mark - WBLockViewDelegate
- (NSString *)lockViewWithButtonImageAtNormal:(WBLockView *)lockView {
    return @"lock_normal";
}
- (NSString *)lockViewWithButtonImageAtSelected:(WBLockView *)lockView {
    return @"lock_highlighted";
}
- (NSString *)lockViewWithButtonImageAtDefeated:(WBLockView *)lockView {
    return @"lock_defeated";
}
- (void)lockViewDidDraw:(WBLockView *)lockView withPath:(NSString *)path {
    //显示路径
    self.mLockView.showDrawPath = YES;
    self.mLabelCenter.text = @"请绘制解锁图案，不少于4个点";
    self.mLabelCenter.textColor = [UIColor whiteColor];
}
- (void)lockViewDidEndDraw:(WBLockView *)lockView withPath:(NSString *)path {
    if (self.setLockType == WBFirstSetLock) {
        [self setDidFirstDrawWithPath:path];
    }
    else if (self.setLockType == WBCheckAgainLock) {
        [self setDidCheckAgainWithPath:path];
    }
    else if (self.setLockType == WBCheckLoginLock) {
        [self setDidLoginWithPath:path];
    }
}
- (BOOL)lockViewWithDrawPathIsValid:(WBLockView *)lockView withPath:(NSString *)path {
    if (self.setLockType == WBCheckLoginLock) return [self.mLockPath isEqualToString:path];
    return YES;
}

#pragma mark - Action
- (void)actionLeft:(UIButton *)sender {
    if (self.setLockType == WBCheckAgainLock) {
        self.setLockType = WBFirstSetLock;
        self.mLockPath = nil;
        self.mLabelCenter.text = @"请绘制解锁图案，不少于4个点";
        self.mLabelCenter.textColor = [UIColor whiteColor];
        sender.hidden = YES;
    }
}

#pragma mark - Private
- (void)setDidFirstDrawWithPath:(NSString *)path {
    if (path.length < 4) {
        self.mLabelCenter.text = @"不能少于4个，请重新输入";
        self.mLabelCenter.textColor = [UIColor redColor];
    }
    else {
        self.mLockPath = path;
        self.setLockType = WBCheckAgainLock;
        self.mLabelCenter.text = @"请再次绘制解锁图案";
        self.mLabelCenter.textColor = [UIColor whiteColor];
        self.mBtnLeft.hidden = NO;
        [self.mBtnLeft setTitle:@"重新设置" forState:UIControlStateNormal];
    }
}
- (void)setDidCheckAgainWithPath:(NSString *)path {
    if ([self.mLockPath isEqualToString:path]) {
        [self showAlter:@"设置成功了，快去解锁吧"];
        self.setLockType = WBCheckLoginLock;
        self.mLabelTitle.text = @"解锁";
        self.mLabelCenter.text = @"请绘制解锁图案，不少于4个点";
        self.mLabelCenter.textColor = [UIColor whiteColor];
        self.mBtnLeft.hidden = YES;
    }
    else {
        self.mLabelCenter.text = @"两次绘制不符，请重新输入";
        self.mLabelCenter.textColor = [UIColor redColor];
    }
}
- (void)setDidLoginWithPath:(NSString *)path {
    //不显示路径
    self.mLockView.showDrawPath = NO;
    if ([self.mLockPath isEqualToString:path]) {
        [self showAlter:@"解锁成功啦，你还想干嘛呢"];
        //解锁成功时，清除结果
        self.mLockView.clearDidEndDraw = YES;
    }
    else {
        //解锁失败时，不清除结果，显示错误情况
        self.mLockView.clearDidEndDraw = NO;
        self.mLabelCenter.text = @"绘制失败啦，重新再绘制";
        self.mLabelCenter.textColor = [UIColor redColor];
    }
}

#pragma mark - InitView
- (void)initViews {
    self.mLabelTitle = [[UILabel alloc] init];
    self.mLabelTitle.font = [UIFont systemFontOfSize:20];
    self.mLabelTitle.textColor = [UIColor whiteColor];
    [self.view addSubview:self.mLabelTitle];
    
    self.mLabelCenter = [[UILabel alloc] init];
    self.mLabelCenter.font = [UIFont systemFontOfSize:15];
    self.mLabelCenter.textColor = [UIColor whiteColor];
    [self.view addSubview:self.mLabelCenter];
    
    self.mBtnLeft = [[UIButton alloc] init];
    [self.mBtnLeft setTitle:@"重新设置" forState:UIControlStateNormal];
    [self.mBtnLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.mBtnLeft addTarget:self action:@selector(actionLeft:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mBtnLeft];
    
    self.mLockView = [[WBLockView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
    self.mLockView.backgroundColor = [UIColor clearColor];
    self.mLockView.delegate = self;
    [self.view addSubview:self.mLockView];
    
    __weak typeof(self) this = self;
    [self.mLabelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong typeof(self) self = this;
        make.top.equalTo(self.view).offset(50);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@20);
    }];
    [self.mLabelCenter mas_updateConstraints:^(MASConstraintMaker *make) {
        __strong typeof(self) self = this;
        make.top.equalTo(self.mLabelTitle.mas_bottom).offset(40);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@20);
    }];
    [self.mLockView mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong typeof(self) self = this;
        make.top.equalTo(self.mLabelCenter.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(kScreenWidth));
        make.height.equalTo(@(kScreenWidth));
    }];
    [self.mBtnLeft mas_updateConstraints:^(MASConstraintMaker *make) {
        __strong typeof(self) self = this;
        make.top.equalTo(self.mLockView.mas_bottom).offset(20);
        make.left.equalTo(self.mLockView).offset(30);
        make.height.equalTo(@20);
    }];
}

- (void)showAlter:(NSString *)message {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self showViewController:alertVC sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
