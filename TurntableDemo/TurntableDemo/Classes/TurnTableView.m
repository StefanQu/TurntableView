//
//  TurnTableView.m
//  TurntableDemo
//
//  Created by Changqing Qu on 2018/2/28.
//  Copyright © 2018年 SteFan. All rights reserved.
//


#import "TurnTableView.h"
#import <objc/runtime.h>



#define back_width 258 * 1.2
#define back_height 258 * 1.2
@interface UIButton (arc)
@property (nonatomic,strong)NSNumber *itemArc;
@property (nonatomic,strong)NSNumber *itemIndex;
@end


@implementation UIButton (arc)
@dynamic itemArc,itemIndex;
static char arcKey,indexKey;
- (void)setItemArc:(NSNumber *)itemArc
{
    objc_setAssociatedObject(self, &arcKey, itemArc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //acrKey 要关联对象的键值，一般设置成静态，用于获取关联对象的值
    //itemArc 要关联对象的值，一般是id类型 可以接受任何类型
    //OBJC_ASSOCIATION_RETAIN_NONATOMIC 关联时采用的协议，有assgin，copy，retain等，具体参看官方文档
}

- (NSNumber *)itemArc
{
    return objc_getAssociatedObject(self, &arcKey);
}

- (void)setItemIndex:(NSNumber *)itemIndex
{
    objc_setAssociatedObject(self, &indexKey, itemIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)itemIndex
{
    return objc_getAssociatedObject(self, &indexKey);
}

@end

@interface TurnTableView ()<CAAnimationDelegate>
@property (nonatomic,strong)NSArray * imageArray;
@property (nonatomic,strong) NSMutableArray *btnArray;
@property (nonatomic,assign) CGFloat beginArc;
@property (nonatomic,strong) UIImageView *canvasImageView;
@property (nonatomic,strong) UIButton *selectBtn;
@property (nonatomic,assign) BOOL isAnimation;
@property (nonatomic,strong) NSMutableArray *indexSets;
@property (nonatomic,strong) NSArray *roundTimes;
@property (nonatomic,assign) int randomRounds;
@end

@implementation TurnTableView


- (instancetype)initWithFrame:(CGRect)frame turntableImages:(NSArray *)imageArray
{
    if (self = [super initWithFrame:frame]) {
        _imageArray = [imageArray copy];
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame luckyImages:(NSArray *)imageArray roundTimes:(NSArray *)roundTimes
{
    if (self = [super initWithFrame:frame]) {
        _imageArray = imageArray;
        _roundTimes = roundTimes;
        [self setupSubViews];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    _beginArc = 0;
    UIImage * image = [UIImage imageNamed:@"luck_shengxiao_zhuanpan"];
    UIImageView * backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, back_width, back_height)];
    backImageView.userInteractionEnabled = YES;
    backImageView.image = image;
    backImageView.center = self.center;
    [self addSubview:backImageView];
    _canvasImageView = backImageView;
    
    UIImage * startImage = [UIImage imageNamed:@"luck_shengxiao_huoquNum_btn"];
    UIButton * startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [startBtn setImage:startImage forState:UIControlStateNormal];
    startBtn.frame = CGRectMake(0, 0, startImage.size.width, startImage.size.height);
    startBtn.center = CGPointMake(back_width/2 - 3, back_height/2-9);
    [startBtn addTarget:self action:@selector(startBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:startBtn];
    
    CGFloat arc = M_PI * 2 /self.imageArray.count;
    [self.imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton * button = ({
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:obj] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"luck_shengxiao_zhaunpan_btn"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"luck_shengxiao_selectedBg"] forState:UIControlStateSelected];
            btn.frame = CGRectMake(0, 125, 58, 62);
            btn.center = CGPointMake(back_width/2, btn.center.y);
            btn.itemIndex = @(idx);
            btn.itemArc = @(arc * idx);
            btn.layer.anchorPoint = CGPointMake(0.5, 2);
            btn.transform = CGAffineTransformMakeRotation(0);
            if (_roundTimes.count) {
                btn.userInteractionEnabled = NO;
            }
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [UIView animateWithDuration:.5 animations:^{
                btn.transform = CGAffineTransformMakeRotation(arc * idx);
            }];
            [self.btnArray addObject:btn];
            btn;
        });
        [backImageView addSubview:button];
    }];
}

- (void)btnClick:(UIButton *)btn
{
    [self.btnArray enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.selected) {
            obj.selected = NO;
            *stop = YES;
        }
    }];
    btn.selected = !btn.selected;
    _selectBtn = btn;
}

- (void)startBtnClick
{
    if (_roundTimes.count) {
        [self beginAutoSwitchCard];
    }else{
        [self beginRotation];
    }
}

- (void)beginRotation
{
    if (_isAnimation) {
        return;
    }
    if (_selectBtn == nil) {
        return;
    }
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue = @(_beginArc);
    animation.toValue = @(M_PI * 8 - _selectBtn.itemArc.floatValue);
    _beginArc = M_PI * 2 - _selectBtn.itemArc.floatValue;
    animation.removedOnCompletion = YES;
    animation.duration = 3;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.delegate = self;
    [_canvasImageView.layer addAnimation:animation forKey:@"animation"];
}

- (void)beginAutoSwitchCard
{
    [self indexSets];
    //设置在最后一圈中的随机位置停止转动
    NSInteger idx = (_randomRounds - 1) * self.imageArray.count;
    NSMutableArray * randomIndxs = [NSMutableArray array];
    for (NSInteger i = idx; i<_randomRounds * self.imageArray.count; i ++) {
        [randomIndxs addObject:@(i)];
    }
    int first = (int)randomIndxs.count - 1;
    int second = [randomIndxs[arc4random_uniform(first)] intValue];
    NSLog(@"%d----%d",_randomRounds,second);
    
    //此处参考论坛http://www.cocoachina.com/bbs/read.php?tid-1713052-page-3.html
    //关于GCD信号量的使用参考论坛http://www.cnblogs.com/yajunLi/p/6274282.html
    __weak __typeof(self)wealf = self;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [_indexSets enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * btn = [self.btnArray objectAtIndex:obj.intValue];
            selectEveryCard(^{
                [self btnClick:btn];
                //提高信号量
                dispatch_semaphore_signal(sem);
                if (second == idx) {
                    *stop = YES;
                    if (wealf.delegate && [wealf.delegate respondsToSelector:@selector(turnViewFinalresult:)]) {
                        [wealf.delegate turnViewFinalresult:_imageArray[obj.intValue]];
                    }
                }
            });
            //等待降低信号量
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        }];
    });
    
}

void selectEveryCard(void(^callBack)(void))
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSThread sleepForTimeInterval:0.1];
        callBack();
    });
}

- (void)animationDidStart:(CAAnimation *)anim
{
    _isAnimation = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _canvasImageView.transform = CGAffineTransformIdentity;
    NSLog(@"%d",[self transFromArc:2*M_PI/self.imageArray.count]);
    int eachArc = [self transFromArc:2*M_PI/self.imageArray.count];
    if (eachArc%3 > 1) {
        eachArc += 1;
    }else if (eachArc%3 == 1)
    {
        eachArc -= 1;
    }
    [self.btnArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton * btn = obj;
        //计算每个按钮动画结束后相对一圈所经过的的角度
        int index = btn.itemIndex.intValue;
        int finalArc = [self transFromArc:_beginArc + (index * (2 * M_PI/self.imageArray.count))];
        //M_PI 得出的角度总是少1或多1，这里手动处理
        if (finalArc%3 > 1) {
            finalArc += 1;
        }else if (finalArc%3 == 1)
        {
            finalArc -= 1;
        }
        //一圈360度
        int degree = [self transFromArc:2 * M_PI];
        //超过2*M_PI就减去
        int angleArc = finalArc >= degree ? finalArc - degree : finalArc;
        //重置按钮的下标和角度
        btn.itemIndex = @(angleArc/eachArc);
        btn.itemArc = @([self transFromdegree:angleArc]);
        btn.transform = CGAffineTransformMakeRotation([self transFromdegree:angleArc]);
    }];
    
    _beginArc = 0;
    _isAnimation = NO;
}

- (int)transFromArc:(CGFloat)arc
{
    return arc*180/M_PI;
}
- (CGFloat)transFromdegree:(int)degree
{
    return degree*M_PI/180;
}


- (NSMutableArray *)indexSets
{
    _indexSets = [NSMutableArray array];
    [_indexSets removeAllObjects];
    //随机圈数
    int count = (int)self.roundTimes.count - 1;
    int index = [self.roundTimes[arc4random_uniform(count)] intValue];
    _randomRounds = index;
    for (int i = 0; i < index; i ++) {
        [self addElements];
    }
    return _indexSets;
}

- (void)addElements
{
    for (int i = 0; i < self.imageArray.count; i++) {
        [_indexSets addObject:@(i)];
    }
}



- (NSMutableArray *)btnArray
{
    if (_btnArray == nil) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

@end
