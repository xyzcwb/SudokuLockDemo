//
//  WBLockView.h
//  SudokuLockDemo
//
//  Created by xyzcwb on 17/3/27.
//  Copyright © 2017年 xyzcwb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WBLockView;
@protocol WBLockViewDelegate <NSObject>

@required
/** 设置正常状态下的图片 */
- (NSString *)lockViewWithButtonImageAtNormal:(WBLockView *)lockView;
/** 设置高亮状态下的图片 */
- (NSString *)lockViewWithButtonImageAtSelected:(WBLockView *)lockView;

@optional
/** 设置验证错误下的图片 */
- (NSString *)lockViewWithButtonImageAtDefeated:(WBLockView *)lockView;
/** 绘制 */
- (void)lockViewDidDraw:(WBLockView *)lockView withPath:(NSString *)path;
/** 绘制结束 */
- (void)lockViewDidEndDraw:(WBLockView *)lockView withPath:(NSString *)path;
/** 解锁的时候，判断绘制的路径是否有误 */
- (BOOL)lockViewWithDrawPathIsValid:(WBLockView *)lockView withPath:(NSString *)path;

@end

@interface WBLockView : UIView

@property (nonatomic, weak) id<WBLockViewDelegate> delegate;
/** 直接设置路径 */
@property (nonatomic, copy) NSString *path;
/** 线宽，默认为2*/
@property (nonatomic, assign) NSInteger lineWidth;
/** 线颜色，默认白色*/
@property (nonatomic, strong) UIColor *lineColor;
/** 绘制完是否清空绘制的结果，默认YES */
@property (nonatomic, assign, getter=isClearDidEndDraw) BOOL clearDidEndDraw;
/** 是否显示路径,默认YES */
@property (nonatomic, assign, getter=isShowDrawPath) BOOL showDrawPath;

@end
