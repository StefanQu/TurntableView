//
//  TurnTableView.h
//  TurntableDemo
//
//  Created by Changqing Qu on 2018/2/28.
//  Copyright © 2018年 SteFan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TurnViewDelegate <NSObject>
@optional
- (void)turnViewFinalresult:(id)result;
@end

@interface TurnTableView : UIView
@property (nonatomic,weak) id<TurnViewDelegate> delegate;
/**
 初始化转盘（旋转模式）
 @param frame 布局
 @param imageArray 传入图片数组（传入的数量要可以被360整除）
 */
- (instancetype)initWithFrame:(CGRect)frame turntableImages:(NSArray *)imageArray;

/**
 初始化抽奖模式
 @param frame 布局
 @param imageArray 传入图片数组（传入的数量要可以被360整除）
 @param roundTimes 控制随机圈数
 */
- (instancetype)initWithFrame:(CGRect)frame luckyImages:(NSArray *)imageArray roundTimes:(NSArray *)roundTimes;
@end
