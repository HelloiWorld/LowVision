//
//  TitleListController.h
//  LowVision
//
//  Created by Sen Zeng on 14/12/19.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "LoadMoreTableFooterView.h"


@interface TitleListController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,LoadMoreTableFooterDelegate>{
    EGORefreshTableHeaderView *_refreshHeaderView;
    LoadMoreTableFooterView *_loadMoreFooterView;
    BOOL _reloading;
    BOOL _hasMore;
    BOOL _loadingMore;
}

@property (weak, nonatomic) IBOutlet UITableView *newsListView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBtn;

-(void)openLoadingView;
-(void)hideLoadingView;
-(void)prepareToShow:(NSString *)string;
- (IBAction)playBtnClick:(UIBarButtonItem *)sender;

@end
