//
//  QHScrollTabView.h
//  QHScrollTabDemo
//
//  Created by chen on 15/7/27.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QHScrollTabDefaultView.h"

@class QHScrollTabView;

@protocol QHScrollTabViewDelegate <NSObject>

- (void)selectTab:(QHScrollTabView *)scrollTab index:(int)idx;

@end

@interface QHScrollTabView : UIView

@property (nonatomic, weak) id<QHScrollTabViewDelegate> delegate;

@property (nonatomic) NSUInteger currentIndex;//begin 1

@property (nonatomic) BOOL bOpenScrollDelegate;/**开启滑动触发回调*/

- (instancetype)initWithFrame:(CGRect)frame scrollTab:(id<QHScrollTabViewProtocol>)scrollTab mainScrollV:(UIScrollView *)sv;

//用于storyboard创建时，后续添加数据
- (void)setScrollTab:(id<QHScrollTabViewProtocol>)scrollTab mainScrollV:(UIScrollView *)sv;

- (void)resetScrollTab:(id<QHScrollTabViewProtocol>)scrollTab mainScrollV:(UIScrollView *)sv;

//兼容旧版本API

- (instancetype)initWithFrame:(CGRect)frame title:(NSArray *)arTitles mainScrollV:(UIScrollView *)sv;

//在iOS9的时候，如果是storyboard拉出的控件，需要在dealloc手动调用，也兼容iOS9以下
- (void)mDealloc;

- (void)setTitle:(NSArray *)arTitles mainScrollV:(UIScrollView *)sv;

//指定sectionIndex (begin 0)
- (void)showBubbleInScrollTab:(NSUInteger)sectionIndex show:(BOOL)bShow animated:(BOOL)animated;

- (void)initTabSectionIndex:(NSUInteger)sectionIndex;

- (void)goTabSectionIndex:(NSUInteger)sectionIndex;

@end
