//
//  QHScrollTabView.m
//  QHScrollTabDemo
//
//  Created by chen on 15/7/27.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import "QHScrollTabView.h"

#define TAB_MAX_COUNT 5

@interface QHScrollTabView ()

@property (nonatomic) CGFloat tabWidth;//只当 bUseCustomWidth 为 NO 时候可使用
@property (nonatomic) CGFloat tabHeight;

@property (nonatomic, strong) UIView *highlightView;

@property (nonatomic, weak) UIScrollView *mainSV;

@property (nonatomic, strong) UIScrollView *contentSV;

@property (nonatomic) NSInteger sumCount;

@property (nonatomic, strong) id<QHScrollTabViewProtocol> scrollTabView;

@property (nonatomic) BOOL bTapTab;

@property (nonatomic) NSUInteger goSectionIndex;

@property BOOL bShowBubble;

@property BOOL bUseCustomWidth;
@property (nonatomic, strong) NSMutableArray *tabWidthArray;
@property (nonatomic, strong) NSMutableArray *scrollZoneArray;

@property (nonatomic) CGFloat tabCountMax;
@property (nonatomic) CGFloat lastContentOffsetX;
@property (nonatomic) NSUInteger lastIndex;

@property BOOL bUsePages;

@end

@implementation QHScrollTabView

- (void)dealloc {
    [self mDealloc];
    [self.tabWidthArray removeAllObjects];
    self.tabWidthArray = nil;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame scrollTab:(id<QHScrollTabViewProtocol>)scrollTab mainScrollV:(UIScrollView *)sv {
    NSAssert(scrollTab != nil, @"id<QHScrollTabViewProtocol> isn't nil");
    self = [self initWithFrame:frame];
    if (self) {
        self.scrollTabView = scrollTab;
        if (sv != nil) {
            self.mainSV = sv;
            [self.mainSV addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSArray *)arTitles mainScrollV:(UIScrollView *)sv {
    QHScrollTabDefaultView *scrollTab = [[QHScrollTabDefaultView alloc] initWithTitles:arTitles];
    self.goSectionIndex = 1;
    return [self initWithFrame:frame scrollTab:scrollTab mainScrollV:sv];
}

- (void)layoutSubviews {
    if (self.bShowBubble) {
        self.bShowBubble = NO;
    }
    else {
        [self p_layoutSubviews];
//        NSLog(@"%lu", (unsigned long)self.goSectionIndex);
        [self p_setCurrentTab:self.goSectionIndex];
    }
}

#pragma mark - Private

- (void)setup {
//    [self.contentSV removeFromSuperview];
    if ([self.scrollTabView respondsToSelector:@selector(useCustomWidth)]) {
        self.bUseCustomWidth = [self.scrollTabView useCustomWidth];
    }
    else {
        self.bUseCustomWidth = NO;
    }
    self.goSectionIndex = 0;
    self.currentIndex = -1;
    self.bOpenScrollDelegate = NO;
    self.lastIndex = self.currentIndex;
    self.bUsePages = [self p_bUsePages];
    
    if ([self.scrollTabView respondsToSelector:@selector(scrollTabCountMax:)]) {
        self.tabCountMax = [self.scrollTabView scrollTabCountMax:self.bounds.size.width];
    }
    else {
        self.tabCountMax = TAB_MAX_COUNT;
    }
    
    self.contentSV = [[UIScrollView alloc] init];
    self.contentSV.showsHorizontalScrollIndicator = NO;
    self.contentSV.scrollsToTop = NO;
    [self addSubview:self.contentSV];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScrollTabView:)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)p_layoutSubviews {
    self.contentSV.frame = self.bounds;
    
    [self.contentSV.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.scrollTabView != nil) {
        NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];
        
        self.tabWidthArray = nil;
        self.tabWidthArray = [NSMutableArray new];
        self.scrollZoneArray = nil;
        self.scrollZoneArray = [NSMutableArray new];
        
        self.tabHeight = self.contentSV.frame.size.height;
        
        if ([self.scrollTabView respondsToSelector:@selector(addSubViewInScrollTab:)]) {
            [self.scrollTabView addSubViewInScrollTab:self];
        }
        
        CGFloat tabWidth = 0;
        
        if (self.bUseCustomWidth == NO) {
            tabWidth = self.contentSV.frame.size.width / MIN(count, self.tabCountMax);
        }
        self.tabWidth = tabWidth;
        
        CGFloat xTemp = 0;
        CGFloat minW = CGFLOAT_MAX;
        for (int i = 0; i < count; i++) {
            CGFloat w = 0;
            if (self.bUseCustomWidth == NO) {
                w = tabWidth;
                minW = w;
            }
            else {
                w = [self.scrollTabView scrollTabViewWidthBySection:i];
                minW = MIN(w, minW);
            }
            UIView *subV = [[UIView alloc] initWithFrame:CGRectMake(xTemp, 0, w, self.tabHeight)];
            UIView *contentSubV = [self.scrollTabView scrollTabViewSection:i size:subV.frame.size];
            contentSubV.tag = i + 1;
            [subV addSubview:contentSubV];
            [self.contentSV addSubview:subV];
            [self.tabWidthArray addObject:[NSNumber numberWithFloat:w]];
            
            xTemp += subV.frame.size.width;
            
            
            NSInteger pageEnd = [self p_getCountRowsInSection:i] - 1;
            NSInteger pageStart = pageEnd - [self.scrollTabView scrollTabViewNumberOfRowsInSection:i] + 1;
            [self.scrollZoneArray addObject:@(pageStart)];
            [self.scrollZoneArray addObject:@(pageEnd)];
        }
        
//        if (self.bUseCustomWidth == NO) {
            self.highlightView = [self.scrollTabView scrollTabViewHighlightViewWithSize:CGSizeMake(minW, self.tabHeight)];
            [self.contentSV addSubview:self.highlightView];
//        }
        
        self.contentSV.contentSize = CGSizeMake(xTemp, self.contentSV.frame.size.height);
    }
}

- (void)p_setClickLabel:(NSUInteger)idx {
    UIView *oldView = nil;
    if (idx != self.currentIndex && self.currentIndex != 0) {
        oldView = [self.contentSV viewWithTag:self.currentIndex];
    }
    UIView *newView = [self.contentSV viewWithTag:idx];
    [self.scrollTabView highlightClickView:newView oldView:oldView];
    
    self.lastIndex = self.currentIndex;
    self.currentIndex = idx;
//    NSLog(@"scroll---->%lu", (unsigned long)self.currentIndex);
}

- (NSInteger)p_getCurrentSection:(NSInteger)idx {
    NSInteger section = 0;
    NSInteger index = idx;
    NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];
    for (int i = 0; i < count; i++) {
        section = i;
        index -= [self.scrollTabView scrollTabViewNumberOfRowsInSection:i];
        if (index <= 0) {
            break;
        }
    }
    return section;
}

//废弃，使用p_countRowsInSection替换
- (NSInteger)p_getCountRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    for (int i = 0; i <= section; i++) {
        rows += [self.scrollTabView scrollTabViewNumberOfRowsInSection:i];
    }
    return rows;
}

- (NSInteger)p_countRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    NSInteger count = MIN([self.scrollTabView numberOfSectionsInScrollTabView], section);
    for (int i = 1; i <= count; i++) {
        rows += [self.scrollTabView scrollTabViewNumberOfRowsInSection:(i - 1)];
    }
    return rows;
}

- (void)p_setCurrentTab:(NSUInteger)section {
    NSInteger pages = [self p_getCountRowsInSection:section-1];
    self.bTapTab = YES;
    if (self.mainSV != nil)
        [self.mainSV setContentOffset:(CGPoint){self.mainSV.frame.size.width*pages, 0} animated:NO];
    [self p_setClickLabel:(section + 1)];
    if (self.bUseCustomWidth == NO) {
        CGRect frame = self.highlightView.frame;
        frame.origin.x = [self p_getPageXBySection:section];
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.highlightView.frame = frame;
        }];
    }
    self.bTapTab = NO;
}

- (NSInteger)p_getPageSectionByX:(CGFloat)x {
    __block CGFloat w = 0;
    __block NSInteger index = 0;
    [self.tabWidthArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        w += [obj floatValue];
        if (w > x) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

- (CGFloat)p_getPageXBySection:(NSInteger)section {
    __block CGFloat x = 0;
    [self.tabWidthArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (section == idx) {
            *stop = YES;
        }
        else {
            x += [obj floatValue];
        }
    }];
    
    return x;
}

- (BOOL)p_bUsePages {
    NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];
    if (count <= self.sumCount) {
        return YES;
    }
    return NO;
}

#pragma mark - Action

- (void)mDealloc {
    if (self.scrollTabView == nil) {
        return;
    }
    self.scrollTabView = nil;
    if (self.mainSV != nil) {
        [self.mainSV removeObserver:self forKeyPath:@"contentOffset"];
    }
    self.mainSV = nil;
    if (self.contentSV != nil) {
        [self.contentSV removeFromSuperview];
    }
    self.contentSV = nil;
    
    self.bShowBubble = NO;
    self.highlightView = nil;
}

- (void)setScrollTab:(id<QHScrollTabViewProtocol>)scrollTab mainScrollV:(UIScrollView *)sv {
    NSAssert(scrollTab != nil, @"id<QHScrollTabViewProtocol> isn't nil");
    self.scrollTabView = scrollTab;
    self.bUsePages = [self p_bUsePages];
    if (sv != nil) {
        self.mainSV = sv;
        [self.mainSV addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    [self layoutIfNeeded];
}
    
- (void)resetScrollTab:(id<QHScrollTabViewProtocol>)scrollTab mainScrollV:(UIScrollView *)sv {
    NSAssert(scrollTab != nil, @"id<QHScrollTabViewProtocol> isn't nil");
    [self mDealloc];
    self.scrollTabView = scrollTab;
    self.bUsePages = [self p_bUsePages];
    if (sv != nil) {
        self.mainSV = sv;
        [self.mainSV addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    [self setup];
    [self layoutIfNeeded];
}

- (void)setTitle:(NSArray *)arTitles mainScrollV:(UIScrollView *)sv {
    QHScrollTabDefaultView *scrollTab = [[QHScrollTabDefaultView alloc] initWithTitles:arTitles];
    [self setScrollTab:scrollTab mainScrollV:sv];
}

- (void)tapScrollTabView:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self.contentSV];
    NSInteger section = [self p_getPageSectionByX:point.x];
    if ((section + 1) != self.currentIndex) {
        [self p_setCurrentTab:section];
    }
    
//    if (self.bUseCustomWidth) {
    NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];
    if (count > self.tabCountMax) {
//        CGPoint touchPoint = [tap locationInView:self];
        NSInteger index = self.currentIndex;
//        if (touchPoint.x < self.frame.size.width/2) {
//            index -= 2;
//        }
//        else {
//            index += 2;
//        }
        if (index > 0 && index <= count) {
            UIView *view = [self.contentSV viewWithTag:index];
            [self.contentSV scrollRectToVisible:view.superview.frame animated:YES];
        }
    }

    if ([self.delegate respondsToSelector:@selector(selectTab:index:)]) {
        [self.delegate selectTab:self index:(int)section];
    }
}

- (void)showBubbleInScrollTab:(NSUInteger)sectionIndex show:(BOOL)bShow animated:(BOOL)animated {
    if ([self.scrollTabView respondsToSelector:@selector(bubbleInScrollTab:show:animated:)]) {
        self.bShowBubble = YES;
        NSAssert(sectionIndex >= 0, @"index 不能为负数");
        UIView *showView = [self.contentSV viewWithTag:(sectionIndex + 1)];
        [self.scrollTabView bubbleInScrollTab:showView show:bShow animated:animated];
    }
}

- (void)initTabSectionIndex:(NSUInteger)sectionIndex {
    self.goSectionIndex = sectionIndex;
    [self setNeedsDisplay];
}

- (void)goTabSectionIndex:(NSUInteger)sectionIndex {
//    NSLog(@"to tap---->%lu", (unsigned long)sectionIndex);
//    NSLog(@"tap---->%lu", (unsigned long)self.currentIndex);
//    if (sectionIndex != self.currentIndex) {
        [self p_setCurrentTab:sectionIndex];
//    }
    
    UIView *view = [self.contentSV viewWithTag:sectionIndex];
    [self.contentSV scrollRectToVisible:view.superview.frame animated:YES];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.bTapTab) {
        return;
    }
    if (self.currentIndex <= 0) {
        return;
    }
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        if (self.bUsePages == NO) {
            CGFloat currentPageX = self.mainSV.frame.size.width * (self.currentIndex - 1);
            if (contentOffset.x < currentPageX && contentOffset.x >= currentPageX - self.mainSV.frame.size.width) {
                if (self.currentIndex <= 1) {
                    return;
                }
                CGFloat length = self.tabWidth;
                if (self.bUseCustomWidth == YES) {
                    CGFloat currentLength = [self.scrollTabView scrollTabViewWidthBySection:(self.currentIndex - 1)];
                    CGFloat preLength = [self.scrollTabView scrollTabViewWidthBySection:(self.currentIndex - 2)];
                    length = currentLength/2 + preLength/2;
                }
                CGFloat xx = currentPageX - contentOffset.x;
                CGFloat lx = length * (xx / self.mainSV.frame.size.width);
                
                UIView *tabView = [self.contentSV viewWithTag:self.currentIndex];
                CGRect frame = tabView.superview.frame;
                frame.size.height = self.highlightView.frame.size.height;
                frame.size.width = self.highlightView.frame.size.width;
                frame.origin.y = self.highlightView.frame.origin.y;
                frame.origin.x = tabView.superview.frame.origin.x + tabView.frame.size.width/2 - self.highlightView.frame.size.width/2 - lx;
                self.highlightView.frame = frame;
                
                if (lx > length / 2) {
                    [self p_setClickLabel:self.currentIndex - 1];
                    NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];
                    if (count > 5) {
                        UIView *currentView = [self.contentSV viewWithTag:self.currentIndex];
                        [self.contentSV scrollRectToVisible:currentView.superview.frame animated:YES];
                    }
                    if (self.bOpenScrollDelegate == YES && [self.delegate respondsToSelector:@selector(selectTab:index:)]) {
                        [self.delegate selectTab:self index:(int)(self.currentIndex - 1)];
                    }
                }
            }
            else if (contentOffset.x >= currentPageX && contentOffset.x < currentPageX + self.mainSV.frame.size.width) {
                if (self.currentIndex >= [self.scrollTabView numberOfSectionsInScrollTabView]) {
                    return;
                }
                CGFloat length = self.tabWidth;
                if (self.bUseCustomWidth == YES) {
                    CGFloat currentLength = [self.scrollTabView scrollTabViewWidthBySection:(self.currentIndex - 1)];
                    CGFloat nextLength = [self.scrollTabView scrollTabViewWidthBySection:(self.currentIndex)];
                    length = currentLength/2 + nextLength/2;
                }
                CGFloat xx = currentPageX - contentOffset.x;
                CGFloat lx = length * (xx / self.mainSV.frame.size.width);
                
                UIView *tabView = [self.contentSV viewWithTag:self.currentIndex];
                CGRect frame = tabView.superview.frame;
                frame.size.height = self.highlightView.frame.size.height;
                frame.size.width = self.highlightView.frame.size.width;
                frame.origin.y = self.highlightView.frame.origin.y;
                frame.origin.x = tabView.superview.frame.origin.x + tabView.frame.size.width/2 - self.highlightView.frame.size.width/2 - lx;
                self.highlightView.frame = frame;
                
                if ((-lx) > length / 2) {
                    [self p_setClickLabel:self.currentIndex + 1];
                    NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];
                    if (count > 5) {
                        UIView *currentView = [self.contentSV viewWithTag:self.currentIndex];
                        [self.contentSV scrollRectToVisible:currentView.superview.frame animated:YES];
                    }
                    if (self.bOpenScrollDelegate == YES && [self.delegate respondsToSelector:@selector(selectTab:index:)]) {
                        [self.delegate selectTab:self index:(int)(self.currentIndex - 1)];
                    }
                }
            }
        }
        else {
            NSUInteger pageCount = [self.scrollTabView scrollTabViewNumberOfRowsInSection:(self.currentIndex - 1)];
            
            NSUInteger preSumPages = [self p_countRowsInSection:self.currentIndex - 1];
            NSUInteger currentPageInSum = contentOffset.x / self.mainSV.frame.size.width + 1;
            NSUInteger currentPage = currentPageInSum - preSumPages;
            CGFloat currentPageX = self.mainSV.frame.size.width * currentPageInSum;
//            NSInteger currentPagesStart = [self p_countRowsInSection:(self.currentIndex - 1)];
//            NSInteger currentPagesEnd = [self p_countRowsInSection:self.currentIndex]; 1)];
            if (pageCount == 1) {
                if (contentOffset.x < currentPageX && contentOffset.x >= currentPageX - self.mainSV.frame.size.width) {
                    if (self.currentIndex <= 1) {
                        return;
                    }
                    CGFloat length = self.tabWidth;
                    if (self.bUseCustomWidth == YES) {
                        CGFloat currentLength = [self.scrollTabView scrollTabViewWidthBySection:(self.currentIndex - 1)];
                        CGFloat preLength = [self.scrollTabView scrollTabViewWidthBySection:(self.currentIndex - 2)];
                        length = currentLength/2 + preLength/2;
                    }
                    CGFloat xx = currentPageX - contentOffset.x;
                    CGFloat lx = length * (xx / self.mainSV.frame.size.width);
                    
                    UIView *tabView = [self.contentSV viewWithTag:self.currentIndex];
                    CGRect frame = tabView.superview.frame;
                    frame.size.height = self.highlightView.frame.size.height;
                    frame.size.width = self.highlightView.frame.size.width;
                    frame.origin.y = self.highlightView.frame.origin.y;
                    frame.origin.x = tabView.superview.frame.origin.x + tabView.frame.size.width/2 - self.highlightView.frame.size.width/2 - lx;
                    self.highlightView.frame = frame;
                    NSLog(@"1");
                    
                    if (lx > length / 2) {
                        [self p_setClickLabel:self.currentIndex - 1];
                        NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];
                        if (count > 5) {
                            UIView *currentView = [self.contentSV viewWithTag:self.currentIndex];
                            [self.contentSV scrollRectToVisible:currentView.superview.frame animated:YES];
                        }
                        if (self.bOpenScrollDelegate == YES && [self.delegate respondsToSelector:@selector(selectTab:index:)]) {
                            [self.delegate selectTab:self index:(int)(self.currentIndex - 1)];
                        }
                    }
                }
                else if (contentOffset.x >= currentPageX && contentOffset.x < currentPageX + self.mainSV.frame.size.width) {
                    if (self.currentIndex >= [self.scrollTabView numberOfSectionsInScrollTabView]) {
                        return;
                    }
                    CGFloat length = self.tabWidth;
                    if (self.bUseCustomWidth == YES) {
                        CGFloat currentLength = [self.scrollTabView scrollTabViewWidthBySection:(self.currentIndex - 1)];
                        CGFloat nextLength = [self.scrollTabView scrollTabViewWidthBySection:(self.currentIndex)];
                        length = currentLength/2 + nextLength/2;
                    }
                    CGFloat xx = currentPageX - contentOffset.x;
                    CGFloat lx = length * (xx / self.mainSV.frame.size.width);
                    
                    UIView *tabView = [self.contentSV viewWithTag:self.currentIndex];
                    CGRect frame = tabView.superview.frame;
                    frame.size.height = self.highlightView.frame.size.height;
                    frame.size.width = self.highlightView.frame.size.width;
                    frame.origin.y = self.highlightView.frame.origin.y;
                    frame.origin.x = tabView.superview.frame.origin.x + tabView.frame.size.width/2 - self.highlightView.frame.size.width/2 - lx;
                    self.highlightView.frame = frame;
                    NSLog(@"2");
                    
                    if ((-lx) > length / 2) {
                        [self p_setClickLabel:self.currentIndex + 1];
                        NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];
                        if (count > 5) {
                            UIView *currentView = [self.contentSV viewWithTag:self.currentIndex];
                            [self.contentSV scrollRectToVisible:currentView.superview.frame animated:YES];
                        }
                        if (self.bOpenScrollDelegate == YES && [self.delegate respondsToSelector:@selector(selectTab:index:)]) {
                            [self.delegate selectTab:self index:(int)(self.currentIndex - 1)];
                        }
                    }
                }
            }
            else if (currentPage == 1 && contentOffset.x < self.mainSV.frame.size.width * preSumPages) {
                if (contentOffset.x < currentPageX && contentOffset.x >= currentPageX - self.mainSV.frame.size.width) {
                    if (self.currentIndex <= 1) {
                        return;
                    }
                    CGFloat length = self.tabWidth;
                    if (self.bUseCustomWidth == YES) {
                        CGFloat currentLength = [self.scrollTabView scrollTabViewWidthBySection:(self.currentIndex - 1)];
                        CGFloat preLength = [self.scrollTabView scrollTabViewWidthBySection:(self.currentIndex - 2)];
                        length = currentLength/2 + preLength/2;
                    }
                    CGFloat xx = currentPageX - contentOffset.x;
                    CGFloat lx = length * (xx / self.mainSV.frame.size.width);
                    
                    UIView *tabView = [self.contentSV viewWithTag:self.currentIndex];
                    CGRect frame = tabView.superview.frame;
                    frame.size.height = self.highlightView.frame.size.height;
                    frame.size.width = self.highlightView.frame.size.width;
                    frame.origin.y = self.highlightView.frame.origin.y;
                    frame.origin.x = tabView.superview.frame.origin.x + tabView.frame.size.width/2 - self.highlightView.frame.size.width/2 - lx;
                    self.highlightView.frame = frame;
                    NSLog(@"3");
                    
                    if (lx > length / 2) {
                        [self p_setClickLabel:self.currentIndex - 1];
                        NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];
                        if (count > 5) {
                            UIView *currentView = [self.contentSV viewWithTag:self.currentIndex];
                            [self.contentSV scrollRectToVisible:currentView.superview.frame animated:YES];
                        }
                        if (self.bOpenScrollDelegate == YES && [self.delegate respondsToSelector:@selector(selectTab:index:)]) {
                            [self.delegate selectTab:self index:(int)(self.currentIndex - 1)];
                        }
                    }
                }
            }
            else if (currentPage == pageCount && contentOffset.x > self.mainSV.frame.size.width * (preSumPages + (pageCount - 1))) {
                if (contentOffset.x >= currentPageX && contentOffset.x < currentPageX + self.mainSV.frame.size.width) {
                    if (self.currentIndex >= [self.scrollTabView numberOfSectionsInScrollTabView]) {
                        return;
                    }
                    CGFloat length = self.tabWidth;
                    if (self.bUseCustomWidth == YES) {
                        CGFloat currentLength = [self.scrollTabView scrollTabViewWidthBySection:(self.currentIndex - 1)];
                        CGFloat nextLength = [self.scrollTabView scrollTabViewWidthBySection:(self.currentIndex)];
                        length = currentLength/2 + nextLength/2;
                    }
                    CGFloat xx = currentPageX - contentOffset.x;
                    CGFloat lx = length * (xx / self.mainSV.frame.size.width);
                    
                    UIView *tabView = [self.contentSV viewWithTag:self.currentIndex];
                    CGRect frame = tabView.superview.frame;
                    //                NSLog(@"%@", NSStringFromCGRect(frame));
                    frame.size.height = self.highlightView.frame.size.height;
                    frame.size.width = self.highlightView.frame.size.width;
                    frame.origin.y = self.highlightView.frame.origin.y;
                    frame.origin.x = tabView.superview.frame.origin.x + tabView.frame.size.width/2 - self.highlightView.frame.size.width/2 - lx;
                    self.highlightView.frame = frame;
                    NSLog(@"4");
                    
                    if ((-lx) > length / 2) {
                        [self p_setClickLabel:self.currentIndex + 1];
                        NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];
                        if (count > 5) {
                            UIView *currentView = [self.contentSV viewWithTag:self.currentIndex];
                            [self.contentSV scrollRectToVisible:currentView.superview.frame animated:YES];
                        }
                        if (self.bOpenScrollDelegate == YES && [self.delegate respondsToSelector:@selector(selectTab:index:)]) {
                            [self.delegate selectTab:self index:(int)(self.currentIndex - 1)];
                        }
                    }
                }
            }
            else {
                return;
            }
        }
        
    }
}

- (void)old_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.bTapTab) {
        return;
    }
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
//        NSLog(@"contentOffset--->%f", contentOffset.x);
        NSUInteger i = contentOffset.x/self.mainSV.frame.size.width;
        
//        CGFloat offX = contentOffset.x - i*self.mainSV.frame.size.width;
//        if ((contentOffset.x > 0 && offX == 0) || offX > 0) {
//            i += 1;
//        }
//        NSInteger section = [self p_getCurrentSection:i];
//        NSInteger pages = [self p_getCountRowsInSection:section];
        
        NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];

        
        
        NSInteger pagesCount = [self p_getCountRowsInSection:(count - 1)];
        
        if (contentOffset.x < 0 || contentOffset.x > ((pagesCount - 1) * self.mainSV.frame.size.width)) {
            return;
        }
        
        NSInteger section = -1;
        for (int index = 0; index < count; index++) {
            NSInteger pageEnd = [self p_getCountRowsInSection:index] - 1;
            NSInteger pageStart = pageEnd - [self.scrollTabView scrollTabViewNumberOfRowsInSection:index] + 1;
            if ((i == pageEnd && contentOffset.x >= self.lastContentOffsetX)) {
                section = index;
                break;
            }
            else if (((i + 1) == pageStart && contentOffset.x < self.lastContentOffsetX)) {
                section = index - 1;
                break;
            }
        }
        if (section == -1) {
            return;
        }
        
//        if (contentOffset.x >= (pages-1)*self.mainSV.frame.size.width) {
//            NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];
            CGFloat offX = contentOffset.x - (i - section)*self.mainSV.frame.size.width;
            CGFloat xx = offX == 0 ? 0 : offX/(self.mainSV.frame.size.width*count)*self.contentSV.contentSize.width;
            if (self.bUseCustomWidth == NO) {
                CGRect frame = self.highlightView.frame;
                if (xx == frame.origin.x) {
                    return;
                }
                frame.origin.x = xx;
//            if (count > 5)
//                [self.contentSV scrollRectToVisible:frame animated:YES];
                self.highlightView.frame = frame;
            }
        
        NSUInteger nowIdx = [self p_getPageSectionByX:xx];
            CGFloat nn = 1;
            if (contentOffset.x >= self.lastContentOffsetX) {
                nn = 0.25;
            }
            else {
             nn = 0.75;
                if ([self p_getCountRowsInSection:(nowIdx - 1)] != (i + 1)) {
                    nowIdx += 1;
                }
            }
//            NSLog(@"xx==%f", xx);
//            NSLog(@"nn==%f", nn);
            self.lastContentOffsetX = contentOffset.x;
            CGFloat ww = [(self.tabWidthArray[nowIdx]) floatValue];
        
//            NSLog(@"nowIdx==%ld", (long)nowIdx);
            NSUInteger idx = [self p_getPageSectionByX:(xx + ww*nn)] + 1;//self.highlightView.center.x/self.tabWidth + 1;
//            NSUInteger idx = [self p_getPageSectionByX:(xx + [self.tabWidthArray[self.currentIndex - 1] floatValue]/2.0)] + 1;
            
            //对于自定义宽带是有问题的，但是单页就正常，尝试将多页情况判断为单页。即滑动判断临界页，这就需要判断滑动的位置是否处于临界页了
            
//            NSLog(@"idx==%ld", (long)idx);
            if (idx != self.currentIndex) {
                [self p_setClickLabel:idx];
                if (count > 5) {
                    UIView *currentView = [self.contentSV viewWithTag:self.currentIndex];
                    [self.contentSV scrollRectToVisible:currentView.superview.frame animated:YES];
                }
                if (self.bOpenScrollDelegate == YES && [self.delegate respondsToSelector:@selector(selectTab:index:)]) {
                    [self.delegate selectTab:self index:(int)(idx - 1)];
                }
            }
        }
//    }
}

#pragma mark - Get

- (NSInteger)sumCount {
    _sumCount = 0;
    NSInteger count = [self.scrollTabView numberOfSectionsInScrollTabView];
    for (int i = 0; i < count; i++) {
        _sumCount += [self.scrollTabView scrollTabViewNumberOfRowsInSection:i];
    }
    return _sumCount;
}

@end
