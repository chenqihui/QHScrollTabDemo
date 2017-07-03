//
//  QHScrollTabDefaultView.h
//  QHScrollTabDemo
//
//  Created by chen on 15/8/8.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QHScrollTabViewProtocol.h"


@interface QHScrollTabDefaultView : NSObject <QHScrollTabViewProtocol>

@property (nonatomic, strong) NSArray *arData;
@property (nonatomic, strong) NSArray *arPage;

- (instancetype)initWithTitles:(NSArray *)arTitle;

- (instancetype)initWithTitles:(NSArray *)arTitle page:(NSArray *)arPage;

@end
