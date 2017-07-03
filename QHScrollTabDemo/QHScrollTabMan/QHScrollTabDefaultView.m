//
//  QHScrollTabDefaultView.m
//  QHScrollTabDemo
//
//  Created by chen on 15/8/8.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import "QHScrollTabDefaultView.h"

#define HEIGHT_LINE 2
#define COLOR_LINE [UIColor colorWithRed:0xcb/255.f green:0x9c/255.f blue:0x64/255.f alpha:1]
#define COLOR_CLICK_LABEL COLOR_LINE
#define COLOR_NORMAL_LABEL [UIColor blackColor]

#define BUBBLE_WIDTH 7
#define BUBBLE_TAG  8766

@implementation QHScrollTabDefaultView

- (void)dealloc {
    self.arData = nil;
    self.arPage = nil;
}

- (instancetype)initWithTitles:(NSArray *)arTitle {
    return [self initWithTitles:arTitle page:nil];
}

- (instancetype)initWithTitles:(NSArray *)arTitle page:(NSArray *)arPage {
    NSAssert(arTitle != nil, @"arTitle is not nil!");
    if (arPage != nil) {
        NSAssert(arTitle.count == arPage.count, @"arTitle与arPage不一一对应");
    }
    self = [super init];
    if (self) {
        self.arData = arTitle;
        self.arPage = arPage;
    }
    return self;
}

- (NSInteger)numberOfSectionsInScrollTabView {
    return self.arData.count;
}

- (NSInteger)scrollTabViewNumberOfRowsInSection:(NSInteger)section {
    if (self.arPage == nil) {
        return 1;
    }
    return [self.arPage[section] integerValue];
   
}

- (UIView *)scrollTabViewSection:(NSUInteger)idx size:(CGSize)size {
    UILabel *l = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, size}];
    l.text = self.arData[idx];
    l.textAlignment = NSTextAlignmentCenter;
//    l.textColor = COLOR_NORMAL_LABEL;
    l.textColor = [UIColor blackColor];
    return l;
}

- (UIView *)scrollTabViewHighlightViewWithSize:(CGSize)size {
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, size.height - HEIGHT_LINE, size.width, HEIGHT_LINE)];
    lineV.backgroundColor = [UIColor clearColor];
    {
        UIView *bgLineV = [[UIView alloc] initWithFrame:lineV.bounds];
        bgLineV.backgroundColor = COLOR_LINE;
        bgLineV.alpha = .2;
        [lineV addSubview:bgLineV];
        
        CGFloat w = lineV.frame.size.width*0.8;
        UIView *fLineV = [[UIView alloc] initWithFrame:CGRectMake((lineV.frame.size.width - w)/2, 0, w, lineV.frame.size.height)];
        fLineV.backgroundColor = COLOR_LINE;
        [lineV addSubview:fLineV];
    }
    return lineV;
}

- (void)highlightClickView:(UIView *)newView oldView:(UIView *)oldView {
    UILabel *label = nil;
    if (oldView != nil) {
        label = (UILabel *)oldView;
//        label.textColor = COLOR_NORMAL_LABEL;
        label.textColor = [UIColor blackColor];
    }
    label = (UILabel *)newView;
    label.textColor = COLOR_CLICK_LABEL;
}

- (void)bubbleInScrollTab:(UIView *)view show:(BOOL)bShow animated:(BOOL)animated {
    UILabel *viewLabel = (UILabel *)view;
    UIView *bubbleV = (UILabel *)[view viewWithTag:view.tag + BUBBLE_TAG];
    if (bubbleV) {
        if (!bShow) {
            if (animated) {
                [UIView animateWithDuration:0.4 animations:^{
                    bubbleV.alpha = 0;
                } completion:^(BOOL finished) {
                    [bubbleV removeFromSuperview];
                }];
            }
            else {
                [bubbleV removeFromSuperview];
            }
        }
    }else {
        if (bShow) {
            NSString *str = viewLabel.text;
            CGSize size = [str sizeWithAttributes:@{NSFontAttributeName:viewLabel.font}];
            
            bubbleV = [[UIView alloc] initWithFrame:CGRectMake((viewLabel.frame.size.width + size.width)/2, (viewLabel.frame.size.height - size.height)/2, BUBBLE_WIDTH, BUBBLE_WIDTH)];
            bubbleV.backgroundColor = COLOR_CLICK_LABEL;
            bubbleV.layer.cornerRadius = BUBBLE_WIDTH/2;
            bubbleV.tag = view.tag + BUBBLE_TAG;
            [view addSubview:bubbleV];
            if (animated) {
                bubbleV.alpha = 0;
                [UIView animateWithDuration:0.4 animations:^{
                    bubbleV.alpha = 1;
                }];
            }
        }
    }
}

- (BOOL)useCustomWidth {
    return NO;
}

- (CGFloat)scrollTabViewWidthBySection:(NSUInteger)idx {
    return 0;
}

@end
