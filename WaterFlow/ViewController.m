//
//  ViewController.m
//  WaterFlow
//
//  Created by waikeungshen on 15/4/8.
//  Copyright (c) 2015年 waikeungshen. All rights reserved.
//

#import "ViewController.h"
#import "WaterflowView.h"
#import "WaterflowViewCell.h"
#import "MBProgressHUD.h"

@interface ViewController () <WaterflowViewDataSource, WaterflowViewDelegate> {
    MBProgressHUD *HUD;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WaterflowView *waterflowView = [[WaterflowView alloc] init];
    waterflowView.frame = self.view.bounds;
    waterflowView.dataSource = self;
    waterflowView.delegate = self;
    [self.view addSubview:waterflowView];

    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeText;
}

#pragma mark - 数据源

- (NSInteger)numberOfCellsInWaterflowView:(WaterflowView *)waterflowView {
    return 30;
}

- (WaterflowViewCell *)waterflowView:(WaterflowView *)waterflowView cellAtIndex:(NSInteger)index {
    //WaterflowViewCell *cell = [[WaterflowViewCell alloc] init];
    static NSString *cellIdentifier = @"cell";
    WaterflowViewCell *cell = [waterflowView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[WaterflowViewCell alloc] init];
        cell.identifier = cellIdentifier;
        cell.backgroundColor = [self randomColor];
        [cell.layer setBorderColor:[UIColor blackColor].CGColor];
        [cell.layer setBorderWidth:1.0f];
    }
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%ld", (long)index];
    label.center = cell.center;
    [cell addSubview:label];
    NSLog(@"%ld --- %p", (long)index, cell);
    return cell;
}

#pragma mark - 代理方法

- (CGFloat)waterflowView:(WaterflowView *)waterflowView heightAtIndex:(NSInteger)index {
    CGFloat height = arc4random() % 10 * 10 + 100;
    return height;
}

- (CGFloat)waterflowView:(WaterflowView *)waterflowView marginForType:(WaterflowViewMarginType)type {
    switch (type) {
        case WaterflowViewMarginTypeTop:
        case WaterflowViewMarginTypeBottom:
        case WaterflowViewMarginTypeLeft:
        case WaterflowViewMarginTypeRight:
            return 10;
        case WaterflowViewMarginTypeColumn:
        case WaterflowViewMarginTypeRow:
            return 5;
        default:
            break;
    }
    return 0;
}

- (void)waterflowView:(WaterflowView *)waterflowView didSelectAtIndex:(NSUInteger)index {
    NSLog(@"点击了第%lu个cell", (unsigned long)index);
    HUD.labelText = [NSString stringWithFormat:@"点击了第%lu个cell", (unsigned long)index];
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    }];
}

#pragma mark - 随机颜色
- (UIColor *) randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end