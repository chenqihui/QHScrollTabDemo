//
//  QHCustomWidthScrollTabView.m
//  QHScrollTabDemo
//
//  Created by Anakin chen on 2017/7/1.
//  Copyright © 2017年 Qianjun Network Technology. All rights reserved.
//

#import "QHCustomWidthScrollTabView.h"

@implementation QHCustomWidthScrollTabView

- (UIView *)scrollTabViewHighlightViewWithSize:(CGSize)size {
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, size.height - 1, size.width, 1)];
    lineV.backgroundColor = [UIColor clearColor];
    {
        UIView *bgLineV = [[UIView alloc] initWithFrame:lineV.bounds];
        bgLineV.backgroundColor = [UIColor clearColor];;
        bgLineV.alpha = .2;
        [lineV addSubview:bgLineV];
        
        CGFloat w = lineV.frame.size.width*0.8;
        UIView *fLineV = [[UIView alloc] initWithFrame:CGRectMake((lineV.frame.size.width - w)/2, 0, w, lineV.frame.size.height)];
        fLineV.backgroundColor = [UIColor orangeColor];
        [lineV addSubview:fLineV];
    }
    return lineV;
}

- (BOOL)useCustomWidth {
    return YES;
}

- (CGFloat)scrollTabViewWidthBySection:(NSUInteger)idx {
    NSString *title = self.arData[idx];
    UIFont *font = [UIFont systemFontOfSize:15];

    CGSize s = [title sizeWithAttributes:@{NSFontAttributeName:font}];
    CGFloat w = s.width + 21;
//    if (idx == 0) {
//        w += 15;
//    }
    return w;
}

@end
