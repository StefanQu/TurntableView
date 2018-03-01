//
//  ViewController.m
//  TurntableDemo
//
//  Created by Changqing Qu on 2018/2/28.
//  Copyright © 2018年 SteFan. All rights reserved.
//

#import "ViewController.h"
#import "TurnTableView.h"
@interface ViewController ()<UITabBarDelegate,TurnViewDelegate>
@property (weak, nonatomic) IBOutlet UITabBar *toolBar;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,strong) TurnTableView *turnView;
@property (nonatomic,strong) NSArray *imageArray;
@property (nonatomic,strong) NSArray *times;
@property (nonatomic,strong) NSArray *constellations;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _toolBar.delegate = self;
    _imageView.hidden = YES;
    [self tabBar:_toolBar didSelectItem:_toolBar.items[0]];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (_turnView) {
        [_turnView removeFromSuperview];
        _turnView = nil;
    }
    if ([tabBar.items[0] isEqual:item]) {
        //选中第一个
        _imageView.hidden = YES;
        _turnView = [[TurnTableView alloc]initWithFrame:CGRectMake(0, 0, 300, 300) turntableImages:self.imageArray];
        _turnView.center = self.view.center;
        [self.view addSubview:_turnView];
    }else{
        _turnView = [[TurnTableView alloc]initWithFrame:CGRectMake(0, 0, 300, 300) luckyImages:self.constellations roundTimes:self.times];
        _turnView.delegate = self;
        _imageView.hidden = NO;
        _turnView.center = self.view.center;
        [self.view addSubview:_turnView];
    }
}

- (void)turnViewFinalresult:(id)result
{
    _imageView.hidden = NO;
    _imageView.image = [UIImage imageNamed:(NSString *)result];
}

- (NSArray *)imageArray
{
    if (_imageArray == nil) {
        _imageArray = @[@"luck_shengxiao_ani_shu",
                        @"luck_shengxiao_ani_niu",
                        @"luck_shengxiao_ani_hu",
                        @"luck_shengxiao_ani_tu",
                        @"luck_shengxiao_ani_long",
                        @"luck_shengxiao_ani_she",
                        @"luck_shengxiao_ani_ma",
                        @"luck_shengxiao_ani_yang",
                        @"luck_shengxiao_ani_hou",
                        @"luck_shengxiao_ani_ji",
                        @"luck_shengxiao_ani_gou",
                        @"luck_shengxiao_ani_zhu"];
    }
    return _imageArray;
}

- (NSArray *)constellations
{
    if (_constellations == nil) {
        _constellations = @[@"luck_shengxiao_xing_baiyang",
                            @"luck_shengxiao_xing_chunv",
                            @"luck_shengxiao_xing_jinniu",
                            @"luck_shengxiao_xing_juxie",
                            @"luck_shengxiao_xing_moxie",
                            @"luck_shengxiao_xing_sheshou",
                            @"luck_shengxiao_xing_shizi",
                            @"luck_shengxiao_xing_shuangyu",
                            @"luck_shengxiao_xing_shuangzi",
                            @"luck_shengxiao_xing_shuiping",
                            @"luck_shengxiao_xing_tianping",
                            @"luck_shengxiao_xing_tianxie"];
    }
    return _constellations;
}


- (NSArray *)times
{
    if (_times == nil) {
        _times = @[@(5),@(6),@(7),@(4),@(5),@(8)];
    }
    return _times;
}

@end
