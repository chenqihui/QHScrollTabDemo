//
//  QHTableSubViewController.m
//  QHTableViewDemo
//
//  Created by chen on 17/3/21.
//  Copyright © 2017年 chen. All rights reserved.
//

#import "QHTableSubViewController.h"

#import "QHScrollTabView.h"
#import "QHCustomWidthScrollTabView.h"

@interface QHTableSubViewController () <QHScrollTabViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainSV;
@property (weak, nonatomic) IBOutlet QHScrollTabView *scrollTabV;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) NSObject <QHScrollTabViewProtocol> *scrollView;

@property (nonatomic, strong) NSArray *arTitles;
@property (nonatomic, strong) NSArray *arPages;

@property (nonatomic) CGFloat scrollViewWidth;
@property (nonatomic) CGFloat scrollViewHeight;

@property (nonatomic) NSInteger currentPage;

@end

@implementation QHTableSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.scrollViewWidth = [UIScreen mainScreen].bounds.size.width;
    self.scrollViewHeight = [UIScreen mainScreen].bounds.size.height - 64 - 40;
    
    if ([self.navigationItem.title isEqualToString:@"单页的Tab"]) {
        [self p_initNormal];
    }
    else if ([self.navigationItem.title isEqualToString:@"多页的Tab"]) {
        [self p_initNormalHavePages];
    }
    else if ([self.navigationItem.title isEqualToString:@"自定义宽度"]) {
        [self p_initMutilHavePages];
    }
    else {
        [self p_initNormal];
    }
    
    [self p_init];
}

#pragma mark - Private

- (void)p_init {
    
    NSInteger pages = 0;
    for (NSNumber *page in self.arPages) {
        pages += [page integerValue];
    }
    [self.mainSV setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * pages, 0)];
    
    __weak typeof(self) weakSelf = self;
    [self.arTitles enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        __strong typeof(weakSelf) strogSelf = weakSelf;
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake([self getOriginX:idx] * strogSelf.scrollViewWidth, 0, strogSelf.scrollViewWidth*[strogSelf.arPages[idx] integerValue], strogSelf.scrollViewHeight)];
        l.text = obj;
        l.textAlignment = NSTextAlignmentCenter;
        [strogSelf.mainSV addSubview:l];
    }];
    
    [self.scrollTabV resetScrollTab:self.scrollView mainScrollV:self.mainSV];
    self.scrollTabV.delegate = self;
    
    self.pageControl.numberOfPages = [self.arPages[(self.scrollTabV.currentIndex - 1)] integerValue];
    self.pageControl.currentPage = (self.scrollTabV.currentIndex - 1);
}

- (void)p_initNormal {
    self.arTitles = @[@"VIP", @"守护", @"商城", @"守护", @"商城", @"守护", @"商城"];
    self.arPages = @[@1, @1, @1, @1, @1, @1, @1];
    
    self.scrollView = [[QHScrollTabDefaultView alloc] initWithTitles:self.arTitles page:self.arPages];
}

- (void)p_initNormalHavePages {
    self.arTitles = @[@"VIP", @"守护", @"商城", @"守护", @"商城", @"守护", @"商城"];
    self.arPages = @[@3, @1, @2, @3, @2, @3, @3];
    
    self.scrollView = [[QHScrollTabDefaultView alloc] initWithTitles:self.arTitles page:self.arPages];
}

- (void)p_initMutilHavePages {
    self.arTitles = @[@"VIP", @"守护开门", @"商城", @"守护啊", @"商城", @"守护哈哈哈", @"商城"];
    self.arPages = @[@2, @1, @2, @3, @2, @1, @3];
//    self.arPages = @[@1, @1, @1, @1, @1, @1, @1];
    
    self.scrollView = [[QHCustomWidthScrollTabView alloc] initWithTitles:self.arTitles page:self.arPages];
}

#pragma mark - Util

- (NSInteger)getOriginX:(NSInteger)idx {
    NSInteger pages = 0;
    for (int i = 0 ; i < idx; i++) {
        pages += [self.arPages[i] integerValue];
    }
    return pages;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentPage = self.scrollTabV.currentIndex - 1;
    NSInteger index = [self.arPages[self.currentPage] integerValue];
    if (self.pageControl.numberOfPages != index) {
        self.pageControl.numberOfPages = index;
    }
    NSInteger preRows = 0;
    for (int i = 0; i < self.currentPage; i++) {
        preRows += [self.arPages[i] integerValue];
    }
    NSInteger currentCountPage = (scrollView.contentOffset.x + scrollView.frame.size.width) / scrollView.frame.size.width - 1;
    self.pageControl.currentPage = currentCountPage - preRows;
}

#pragma mark - QHScrollTabViewDelegate

- (void)selectTab:(QHScrollTabView *)scrollTab index:(int)idx {
    self.currentPage = idx;
    self.pageControl.numberOfPages = [self.arPages[self.currentPage] integerValue];
    self.pageControl.currentPage = 0;
    NSInteger preRows = 0;
    for (int i = 0; i < self.currentPage; i++) {
        preRows += [self.arPages[i] integerValue];
    }
    [self.mainSV setContentOffset:CGPointMake(preRows*self.scrollViewWidth, 0) animated:YES];
}

@end
