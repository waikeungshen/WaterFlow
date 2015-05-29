//
//  WaterflowView.h
//  WaterFlow
//
//  Created by waikeungshen on 15/4/8.
//  Copyright (c) 2015年 waikeungshen. All rights reserved.
//

#import <UIKit/UIKit.h>

// 使用瀑布流形式展示内容的控件
typedef enum {
    WaterflowViewMarginTypeTop,
    WaterflowViewMarginTypeBottom,
    WaterflowViewMarginTypeLeft,
    WaterflowViewMarginTypeRight,
    WaterflowViewMarginTypeColumn,//每一列
    WaterflowViewMarginTypeRow,//每一行
}WaterflowViewMarginType;

@class WaterflowViewCell, WaterflowView;

// 数据源协议
@protocol WaterflowViewDataSource <NSObject>

@required
// 一共有多少数据
- (NSInteger)numberOfCellsInWaterflowView:(WaterflowView *)waterflowView;
// 返回index位置的cell
- (WaterflowViewCell *)waterflowView:(WaterflowView *)waterflowView cellAtIndex:(NSInteger)index;

@optional
// 一共有多少列
- (NSInteger)numberOfColumnsInWaterflowView:(WaterflowView *)waterflowView;

@end

// 代理方法
@protocol WaterflowViewDelegate <NSObject>

@optional
- (CGFloat)waterflowView:(WaterflowView *)waterflowView heightAtIndex:(NSInteger)index;

- (void)waterflowView:(WaterflowView *)waterflowView didSelectAtIndex:(NSUInteger)index;

-(CGFloat)waterflowView:(WaterflowView *)waterflowView marginForType:(WaterflowViewMarginType)type;
@end

@interface WaterflowView : UIScrollView

@property (weak, nonatomic) id<WaterflowViewDataSource> dataSource;
@property (weak, nonatomic) id<WaterflowViewDelegate> delegate;

- (void)reloadData;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
