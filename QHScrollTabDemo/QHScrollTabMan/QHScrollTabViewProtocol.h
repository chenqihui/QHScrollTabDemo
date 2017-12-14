//
//  QHScrollTabViewProtocol.h
//  QHScrollTabDemo
//
//  Created by chen on 15/8/8.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol QHScrollTabViewProtocol <NSObject>

@required

- (NSInteger)numberOfSectionsInScrollTabView;

- (NSInteger)scrollTabViewNumberOfRowsInSection:(NSInteger)section;

- (UIView *)scrollTabViewSection:(NSUInteger)idx size:(CGSize)size;

- (UIView *)scrollTabViewHighlightViewWithSize:(CGSize)size;

- (void)highlightClickView:(UIView *)newView oldView:(UIView *)oldView;

//- (CGFloat)scrollTabViewHeightForHighlight __attribute__((deprecated));

@optional

- (void)bubbleInScrollTab:(UIView *)view show:(BOOL)bShow animated:(BOOL)animated;

//使用自定义宽度
- (BOOL)useCustomWidth;

//返回自定义的宽度数值
- (CGFloat)scrollTabViewWidthBySection:(NSUInteger)idx;

//scrollTab的一行显示最多个数，默认最多为5
- (CGFloat)scrollTabCountMax:(CGFloat)width;

- (void)addSubViewInScrollTab:(UIView *)view;

@end
