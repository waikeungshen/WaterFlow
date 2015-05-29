//
//  WaterflowView.m
//  WaterFlow
//
//  Created by waikeungshen on 15/4/8.
//  Copyright (c) 2015年 waikeungshen. All rights reserved.
//

#import "WaterflowView.h"
#import "WaterflowViewCell.h"

#define WaterflowViewDefaultNumberOfColumns 3
#define WaterflowViewDefaultCellHeight  100
#define WaterflowViewDefaultMargin 10

@interface WaterflowView()
@property (strong, nonatomic) NSMutableArray *cellFrames;
@property (strong, nonatomic) NSMutableDictionary *displayingCells; // 正在显示的cell
@property (strong, nonatomic) NSMutableSet *reusableCells;          // 缓冲池
@end

@implementation WaterflowView

#pragma mark - 懒加载
- (NSMutableArray *)cellFrames {
    if (_cellFrames == nil) {
        _cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells {
    if (_displayingCells == nil) {
        _displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableSet *)reusableCells {
    if (_reusableCells == nil) {
        _reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self reloadData];
}

#pragma mark - reloadData
- (void)reloadData {
    [_cellFrames removeAllObjects];
    
    // cell 的总数
    int numberOfCells = (int)[self.dataSource numberOfCellsInWaterflowView:self];
    
    // cell 的列数
    int numberOfColumns = [self numberOfColumns];
    
    // 间距
    CGFloat leftMargin = [self marginForType:WaterflowViewMarginTypeLeft];
    CGFloat rightMargin = [self marginForType:WaterflowViewMarginTypeRight];
    CGFloat columnMargin = [self marginForType:WaterflowViewMarginTypeColumn];
    CGFloat rowMargin = [self marginForType:WaterflowViewMarginTypeRow];
    CGFloat topMargin = [self marginForType:WaterflowViewMarginTypeTop];
    CGFloat bottomMargin = [self marginForType:WaterflowViewMarginTypeBottom];
    
    // cell宽度 = （整个view的宽度-左边的间距-右边的间距-（列数-1）*每列之间的间距）/总列数
    CGFloat cellWidth = (self.frame.size.width - leftMargin - rightMargin - (numberOfColumns-1) * columnMargin) / numberOfColumns;
    
    // 存储每列的最大的Y值
    CGFloat maxOfColumns[numberOfColumns];
    for (int i = 0; i < numberOfColumns; i++) {
        maxOfColumns[i] = 0.0;
    }
    
    // 计算每个cell的frame
    for (int i = 0; i < numberOfCells; i++) {
        // cell 的高度
        CGFloat cellHeight = [self heightAtIndex:i];
        
        // cell 位于第几列, 位于最短的那一列
        NSInteger cellAtColumns = 0;
        for (int j = 0; j < numberOfColumns; j++) {
            if (maxOfColumns[j] < maxOfColumns[cellAtColumns]) {
                cellAtColumns = j;
            }
        }
        
        // cell 的位置 (x, y)
        // cell 的 x ＝ 左边的间距 + 列号 *（cell的宽度 + 每列之间的间距）
        CGFloat cellX = leftMargin + cellAtColumns * (cellWidth + columnMargin);
        CGFloat cellY = maxOfColumns[cellAtColumns] == 0.0 ? topMargin : (maxOfColumns[cellAtColumns] + rowMargin);
        
        CGRect cellFrame = CGRectMake(cellX, cellY, cellWidth, cellHeight);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        // 更新最短的一列的最大的Y值
        maxOfColumns[cellAtColumns] = CGRectGetMaxY(cellFrame);
        
        // 显示cell
//        WaterflowViewCell *cell = [self.dataSource waterflowView:self cellAtIndex:i];
//        cell.frame = cellFrame;
//        [self addSubview:cell];
    }
    
    // 设置contentSize
    CGFloat contentHeight = maxOfColumns[0];
    for (int i = 0; i < numberOfColumns; i++) {
        if (maxOfColumns[i] > contentHeight ) {
            contentHeight = maxOfColumns[i];
        }
    }
    contentHeight += bottomMargin;
    self.contentSize = CGSizeMake(0, contentHeight);
}

#pragma mark - Cell的复用
- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger numberOfCells = _cellFrames.count;
    
    for (int i = 0; i < numberOfCells; i++) {
        CGRect frame = [_cellFrames[i] CGRectValue];
        WaterflowViewCell *cell = [self.displayingCells objectForKey:@(i)]; // 优先从字典里获取i位置的cell
        // 判断cell是否在屏幕上
        if ([self isInScreen:frame]) { // 在屏幕上
            if (cell == nil) {
                cell = [self.dataSource waterflowView:self cellAtIndex:i];
                cell.frame = frame;
                [self addSubview:cell];
                // 存入正在显示的cell
                [self.displayingCells setObject:cell forKey:@(i)];
            }
        } else { // 不在屏幕上
            if (cell) {
                [cell removeFromSuperview]; // 从父视图中删除
                [self.displayingCells removeObjectForKey:@(i)]; // 从字典中删除
                // 放入缓冲池
                [self.reusableCells addObject:cell];
            }
        }
    }
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    __block WaterflowViewCell *reusableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(WaterflowViewCell *cell, BOOL *stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    if (reusableCell) {
        [self.reusableCells removeObject:reusableCell];
    }
    return reusableCell;
}

#pragma mark - cell 的事件处理
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectAtIndex:)]) {
        return;
    }
    // 获取手指在屏幕上点击的触控点
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    __block NSNumber *selectIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id key, WaterflowViewCell *cell, BOOL *stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    if (selectIndex) {
        [self.delegate waterflowView:self didSelectAtIndex:selectIndex.unsignedIntValue];
    }
}

#pragma mark - 私有方法
- (CGFloat)marginForType:(WaterflowViewMarginType)type {
    if ([self.delegate  respondsToSelector:@selector(waterflowView:marginForType:)]) {
        return [self.delegate waterflowView:self marginForType:type];
    } else {
        return WaterflowViewDefaultMargin;
    }
}

- (CGFloat)numberOfColumns {
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterflowView:)]) {
        return [self.dataSource numberOfColumnsInWaterflowView:self];
    } else {
        return WaterflowViewDefaultNumberOfColumns;
    }
}

- (CGFloat)heightAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(waterflowView:heightAtIndex:)]) {
        return [self.delegate waterflowView:self heightAtIndex:index];
    } else {
        return WaterflowViewDefaultCellHeight;
    }
}

// 判断一个cell是否在屏幕上
- (BOOL)isInScreen:(CGRect)frame {
    //return (CGRectGetMaxY(frame) > self.contentOffset.y) && (CGRectGetMaxY(frame) < self.contentOffset.y + self.frame.size.height);
    return (CGRectGetMaxY(frame) > self.contentOffset.y) && (CGRectGetMaxY(frame) < self.contentOffset.y + self.frame.size.height + 100);
}

@end
