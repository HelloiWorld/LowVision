//
//  LoadMoreTableFooterView.m
//  LowVision
//
//  Created by PZK on 14/12/30.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import "LoadMoreTableFooterView.h"


#define TEXT_COLOR   [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f
#define REFRESH_REGION_HEIGHT 40


@interface LoadMoreTableFooterView (Private)
- (void)setState:(LoadMoreState)aState;
@end

@implementation LoadMoreTableFooterView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.frame.size.width, 20.0f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont boldSystemFontOfSize:15.0f];
        label.textColor = TEXT_COLOR;
        label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _statusLabel=label;
        [label release];
        
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.frame = CGRectMake(110.0f, 20.0f, 10.0f, 20.0f);
        [self addSubview:view];
        _activityView = view;
        [view release];
        self.hidden = YES;
        
        [self setState:LoadMoreNormal];
    }
    
    return self;
}


#pragma mark -
#pragma mark Setters

- (void)setState:(LoadMoreState)aState{
    switch (aState) {
        case LoadMorePulling:
            _statusLabel.text = NSLocalizedString(@"releaseToLoadMore", @"Release to load more");
            break;
        case LoadMoreNormal:
            _statusLabel.text = NSLocalizedString(@"pullUpToLoadMore", @"Load More");
            _statusLabel.hidden = NO;
            [_activityView stopAnimating];
            break;
        case LoadMoreLoading:
            _statusLabel.hidden = NO;
            _statusLabel.text = NSLocalizedString(@"loading", @"Loading Status");
            [_activityView startAnimating];
            break;
        default:
            break;
    }
    
    _state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)loadMoreScrollViewDidScroll:(UIScrollView *)scrollView {
    if (_state == LoadMoreLoading) {
        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
    } else if (scrollView.isDragging) {
        
        BOOL _loading = NO;
        if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDataSourceIsLoading:)]) {
            _loading = [_delegate loadMoreTableFooterDataSourceIsLoading:self];
        }
        //由于源里的LoadMoreTableFooterView只是适应320分辨率的iphone版, 所以需要修改
        /*if (_state == LoadMoreNormal && scrollView.contentOffset.y < (scrollView.contentSize.height - 260) && scrollView.contentOffset.y > (scrollView.contentSize.height - 320) && !_loading) {
         self.frame = CGRectMake(0, scrollView.contentSize.height, self.frame.size.width, self.frame.size.height);
         self.hidden = NO;
         } else if (_state == LoadMoreNormal && scrollView.contentOffset.y > (scrollView.contentSize.height - 260) && !_loading) {
         [self setState:LoadMorePulling];
         } else if (_state == LoadMorePulling && scrollView.contentOffset.y < (scrollView.contentSize.height - 260) && scrollView.contentOffset.y > (scrollView.contentSize.height - 320) && !_loading) {
         [self setState:LoadMoreNormal];
         }*/
        
        //滚动条被拖离的距离，此距离是相对的（滚动条滚动的距离 ＋ ScrollView的高度 － ScrollView内容高度），可自适应多个分辨率：
        CGFloat scrollOffsetHeight = scrollView.contentOffset.y + self.frame.size.height - scrollView.contentSize.height;
        
        //滚动条被拖离的距离小于REFRESH_REGION_HEIGHT，且滚动条被拖离的距离 > 0（向上拖动）
        if (_state == LoadMoreNormal && scrollOffsetHeight < REFRESH_REGION_HEIGHT && scrollOffsetHeight > 0 && !_loading) {
            
            self.frame = CGRectMake(0, scrollView.contentSize.height, self.frame.size.width, self.frame.size.height);
            
            self.hidden = NO;
            
        } else if (_state == LoadMoreNormal && scrollOffsetHeight > REFRESH_REGION_HEIGHT && !_loading) {
            //滚动条被拖离的距离大于REFRESH_REGION_HEIGHT
            [self setState:LoadMorePulling];
            
        } else if (_state == LoadMorePulling && scrollOffsetHeight < REFRESH_REGION_HEIGHT && scrollOffsetHeight > 0 && !_loading) {
            //滚动条被拖离的距离小于REFRESH_REGION_HEIGHT，且滚动条被拖离的距离 > 0（向上拖动）
            //在滚动到"松开即可加载更多..."时，如果又向下滚动（复位），又重新回到"上拉可以加载更多..."
            [self setState:LoadMoreNormal];
            
        }
        
        if (scrollView.contentInset.bottom != 0) {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
    }
}

- (void)loadMoreScrollViewDidEndDragging:(UIScrollView *)scrollView {
    
    BOOL _loading = NO;
    if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDataSourceIsLoading:)]) {
        _loading = [_delegate loadMoreTableFooterDataSourceIsLoading:self];
    }
    //滚动条被拖离的距离大于REFRESH_REGION_HEIGHT
    //if (scrollView.contentOffset.y > (scrollView.contentSize.height - 260) && !_loading) {
    if (scrollView.contentOffset.y > (scrollView.contentSize.height - self.frame.size.height + REFRESH_REGION_HEIGHT) && !_loading) {
        if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDidTriggerRefresh:)]) {
            [_delegate loadMoreTableFooterDidTriggerRefresh:self];
        }
        
        [self setState:LoadMoreLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
        [UIView commitAnimations];
    }
}

- (void)loadMoreScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
    [UIView beginAnimations:nil context:NULL];
     [UIView setAnimationDuration:.3];
     [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
     [UIView commitAnimations];
    
    [self setState:LoadMoreNormal];
//    self.hidden = YES;
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    _delegate=nil;
    _activityView = nil;
    _statusLabel = nil;
    [super dealloc];
}


@end

