//
//  TitleListController.m
//  LowVision
//
//  Created by Sen Zeng on 14/12/19.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import "TitleListController.h"
#import "MFSideMenuContainerViewController.h"
#import "HomeViewCell.h"
#import "naMainData.h"
#import "naDataProcessing.h"

#define UNSELECTED_ROW_FONT [UIFont systemFontOfSize:22.0f]
#define SELECTED_ROW_FONT [UIFont boldSystemFontOfSize:30.0f]
#define CELL_SELECTED_HEIGHT 180.0
#define CELL_UNSELECTED_HEIGHT 120.0

typedef enum {
    dailyNews  = 0,
    previousDate = 1,
    previousNews = 2,
    selectTopicNews = 3,
    showSubscription = 4,
    editSubscription = 5,
}ListMode;

@interface TitleListController ()
@end

@implementation TitleListController{
    
    ListMode listmode;
    ListMode lastListMode;
    NSInteger selectedRow;
    NSInteger currentRow;
    NSInteger lastSpeakRow;
    NSInteger loadingRow;
    NSString *topicToShow;
    NSMutableArray *newsToPlay;
    NSMutableArray *userSubscriptionTopic;
    NSMutableArray *unSubscriptionTopic;
    NSMutableArray *ttsLinks;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_refreshHeaderView == nil) {
        
        EGORefreshTableHeaderView *headerView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.newsListView.bounds.size.height, self.view.frame.size.width, self.newsListView.bounds.size.height)];
        headerView.delegate = self;
        [self.newsListView addSubview:headerView];
        _refreshHeaderView = headerView;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    if (_loadMoreFooterView == nil) {
        LoadMoreTableFooterView *footerView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0.0f, self.newsListView.contentSize.height, self.newsListView.frame.size.width, self.newsListView.bounds.size.height)];
        footerView.delegate = self;
        [self.newsListView addSubview:footerView];
        _loadMoreFooterView = footerView;
        _hasMore=YES;
    }
    
    listmode=dailyNews;
    lastListMode=listmode;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideLoadingView) name:@"finishLoadingNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(nextNews) name:@"ttsfinishNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(musicFinish) name:@"musicfinishNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doneLoadingTableViewData) name:@"refreshfinishNotification" object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

-(void)viewDidLayoutSubviews{
    [self.newsListView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter]removeObserver:self  name:@"finishLoadingNotification" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self  name:@"ttsfinishNotification" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self  name:@"musicfinishNotification" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self  name:@"refreshfinishNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.parentViewController;
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

#pragma mark-prepare to show
-(void)openLoadingView{
    [self.activityIndicatorView startAnimating];
    self.loadingView.hidden=NO;
}

-(void)hideLoadingView{
    selectedRow=-1;
    currentRow=-1;
    loadingRow=-1;
    lastSpeakRow=-1;
    [self prepareToShow:nil];
    [self.activityIndicatorView stopAnimating];
    self.loadingView.hidden=YES;
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayMethod) userInfo:nil repeats:NO];
}

-(void)delayMethod{
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString=[format stringFromDate:[NSDate date]];
    if (![[naMainData shareInstance].previousNewsDic objectForKey:dateString]) {
        [_refreshHeaderView setState:EGOOPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [self.newsListView setContentOffset:CGPointMake(0, -60.0f)  animated:YES];
//        [self.newsListView setContentInset:UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f)];
        [UIView commitAnimations];

        [self egoRefreshTableHeaderDidTriggerRefresh:_refreshHeaderView];
    }
}

-(void)prepareToShow:(NSString *)string{
    if (newsToPlay.count!=0) {
        [newsToPlay removeAllObjects];
    }
    if ([string isEqualToString:@"todayNews"]){
        listmode=dailyNews;
    }else if ([string isEqualToString:@"previousNews"]){
        listmode=previousDate;
    }else if ([string isEqualToString:@"showSubscription"]) {
        listmode=showSubscription;
    }else if ([[[naMainData shareInstance].previousNewsDic allKeys]containsObject:string]) {
        listmode=previousNews;
    }else if ([[[naMainData shareInstance].userSubscriptionTopicDic allKeys] containsObject:string]){
        listmode=selectTopicNews;
    }
    self.editBtn.enabled=NO;
    if (listmode==dailyNews) {
        topicToShow=@"todayNews";
        NSDate *today=[[naDataProcessing shareInstance] getCompareDate:@"today"];
        NSDate *latestDate=[[naDataProcessing shareInstance] getLatestDate];
        newsToPlay=[[NSMutableArray alloc] initWithArray:[[naDataProcessing shareInstance] getDailyNews:today]];
        if (newsToPlay.count==0) {
            newsToPlay=[[NSMutableArray alloc] initWithArray:[[naDataProcessing shareInstance] getDailyNews:latestDate]];
        }
        self.leftBarBtn.image=[UIImage imageNamed:@"menu.png"];
    }else if (listmode==previousDate){
        newsToPlay=[[NSMutableArray alloc] initWithArray:[[naDataProcessing shareInstance] sortedDateKey]];
        self.leftBarBtn.image=[UIImage imageNamed:@"menu.png"];
    }else if (listmode==previousNews){
        topicToShow=string;
        NSDate *selectDate=[[naDataProcessing shareInstance] getCompareDate:string];
        newsToPlay=[[NSMutableArray alloc] initWithArray:[[naDataProcessing shareInstance] getDailyNews:selectDate]];
        self.leftBarBtn.image=[UIImage imageNamed:@"back.png"];
    }else if(listmode==selectTopicNews){
        topicToShow=string;
        newsToPlay=[[NSMutableArray alloc] initWithArray:[[naDataProcessing shareInstance] selectSubscriptionTopic:string]];
        self.leftBarBtn.image=[UIImage imageNamed:@"back.png"];
    }else if (listmode==showSubscription){
      userSubscriptionTopic=[[NSMutableArray alloc]initWithArray:[[naMainData shareInstance].userSubscriptionTopicDic allKeys]];
        newsToPlay=[[NSMutableArray alloc] initWithArray:userSubscriptionTopic];
        self.leftBarBtn.image=[UIImage imageNamed:@"menu.png"];
        self.editBtn.enabled=YES;
    }else if(listmode==editSubscription){
        userSubscriptionTopic=[[NSMutableArray alloc]initWithArray:[[naMainData shareInstance].userSubscriptionTopicDic allKeys]];
        unSubscriptionTopic=[[NSMutableArray alloc]initWithArray:[[naDataProcessing shareInstance] getUnsubscriptionTopic:userSubscriptionTopic]];
        newsToPlay=[[NSMutableArray alloc] initWithObjects:userSubscriptionTopic,unSubscriptionTopic, nil];
        self.leftBarBtn.image=[UIImage imageNamed:@"menu.png"];
        self.editBtn.enabled=YES;
    }
    if (ttsLinks.count>0&&[[newsToPlay objectAtIndex:0] isEqual:[ttsLinks objectAtIndex:0]]) {
        if ([[naDataProcessing shareInstance] ttsDidStop]) {
            selectedRow=currentRow;
        }else{
            selectedRow=-1;
        }
    }else{
        selectedRow=-1;
    }
    loadingRow=-1;
    [self.newsListView reloadData];
}

#pragma mark- UITableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (listmode!=editSubscription) {
        return 1;
    }else{
        return 2;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *titleForHeader;
    if (listmode==editSubscription) {
        if (section==0) {
            titleForHeader=@"已订阅";
        }else{
            titleForHeader=@"未订阅";
        }
    }
    return titleForHeader;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (listmode!=editSubscription) {
        return newsToPlay.count;
    }else{
        if (section==0) {
            return [[newsToPlay objectAtIndex:0] count];
        }else{
            return [[newsToPlay objectAtIndex:1] count];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellheight;
    if (indexPath.row!=selectedRow) {
        cellheight=CELL_UNSELECTED_HEIGHT;
    }else{
        cellheight=CELL_SELECTED_HEIGHT;
    }
    return cellheight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"homeCell" forIndexPath:indexPath];
    if (cell==nil) {
        cell=(HomeViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"homeCell"];
    }
    cell.pubDateLbl.hidden=YES;
    cell.sourceLbl.hidden=YES;
    cell.imgView.hidden=YES;

    if (indexPath.row==loadingRow) {
        [cell.activityIndicatorView startAnimating];
    }else{
        [cell.activityIndicatorView stopAnimating];
    }
    if (indexPath.row==selectedRow&&listmode==lastListMode) {
        cell.backgroundColor=[UIColor colorWithRed:255/255.0 green:228/255.0 blue:225/255.0 alpha:1];
        [cell.titleLbl setFont:SELECTED_ROW_FONT];
    }else{
        cell.backgroundColor=[UIColor whiteColor];
        [cell.titleLbl setFont:UNSELECTED_ROW_FONT];
    }
    if (listmode==previousDate||listmode==showSubscription) {
        cell.titleLbl.text=[newsToPlay objectAtIndex:indexPath.row];
    }else if (listmode==editSubscription){
        cell.imgView.hidden=NO;
        if (indexPath.section==0) {
            cell.titleLbl.text=[[newsToPlay objectAtIndex:0] objectAtIndex:indexPath.row];
            cell.imgView.image=[UIImage imageNamed:@"OK.png"];
        }else{
            cell.titleLbl.text=[[newsToPlay objectAtIndex:1] objectAtIndex:indexPath.row];
            cell.imgView.image=[UIImage imageNamed:@"No.png"];
        }
    }else{
        cell.pubDateLbl.hidden=NO;
        cell.sourceLbl.hidden=NO;
        cell.titleLbl.text=[[newsToPlay objectAtIndex:indexPath.row] objectForKey:@"title"];
        cell.pubDateLbl.text=[[newsToPlay objectAtIndex:indexPath.row] objectForKey:@"pubDate"];
        cell.sourceLbl.text=[[newsToPlay objectAtIndex:indexPath.row]objectForKey:@"source"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeViewCell *cell=(HomeViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    HomeViewCell *lastCell=(HomeViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]];
    if (listmode==dailyNews||listmode==previousNews||listmode==selectTopicNews) {
        if (selectedRow==-1) {
            if (ttsLinks.count!=0) {
                [ttsLinks removeAllObjects];
            }
            ttsLinks=[[NSMutableArray alloc] initWithArray:newsToPlay];

            lastSpeakRow=-1;
            lastListMode=listmode;
        }
        if (indexPath.row!=lastSpeakRow) {
            [[naDataProcessing shareInstance] ttsStop];
            selectedRow=indexPath.row;
            loadingRow=selectedRow;
            currentRow=loadingRow;
            
            cell.backgroundColor=[UIColor colorWithRed:255/255.0 green:228/255.0 blue:225/255.0 alpha:1];
            [cell.titleLbl setFont:SELECTED_ROW_FONT];
            lastCell.backgroundColor=[UIColor whiteColor];
            [lastCell.titleLbl setFont:UNSELECTED_ROW_FONT];
            [tableView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        [self playBtnClick:self.playBtn];
        
    }else if (listmode==previousDate||listmode==showSubscription){
        [self prepareToShow:cell.titleLbl.text];
    }else{
        if (indexPath.section==0) {
            [unSubscriptionTopic addObject:cell.titleLbl.text];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:unSubscriptionTopic.count-1 inSection:1]] withRowAnimation:UITableViewRowAnimationRight];
            [userSubscriptionTopic removeObject:cell.titleLbl.text];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }else{
            [userSubscriptionTopic addObject:cell.titleLbl.text];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:userSubscriptionTopic.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
            [unSubscriptionTopic removeObject:cell.titleLbl.text];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

#pragma mark- RemoteControl
//重写父类方法，接受外部事件的处理
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"playpause!");
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self previousNews];
                NSLog(@"previous!");
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self nextNews];
                NSLog(@"next");
                break;
            case UIEventSubtypeRemoteControlPlay:
//                [self playBtnClick:self.playBtn];
//                NSLog(@"play!");
                break;
            case UIEventSubtypeRemoteControlPause:
                [self playBtnClick:self.playBtn];
                NSLog(@"pause!");
                break;
            default:
                break;
        }
    }
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    //检测到摇动
    NSLog(@"摇一摇!");
}

- (void) motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    //摇动取消
}

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    //摇动结束
    if (event.subtype == UIEventSubtypeMotionShake) {
        [self nextNews];
    }
}

#pragma mark- TTS
-(void)previousNews{
    if (currentRow>0) {
        currentRow=currentRow-1;
    }else{
        currentRow=newsToPlay.count-1;
    }
    [[naDataProcessing shareInstance] audioPlay];
    self.playBtn.image=[UIImage imageNamed:@"play.png"];
}

-(void)nextNews{
    if (currentRow<newsToPlay.count-1) {
        currentRow=currentRow+1;
    }else{
        currentRow=0;
        
    }
    [[naDataProcessing shareInstance] audioPlay];
    self.playBtn.image=[UIImage imageNamed:@"play.png"];
    self.playBtn.enabled=NO;
}

-(void)musicFinish{
    //回调didselect
    if (listmode==lastListMode) {
        if ([self.newsListView .delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.newsListView .delegate tableView:self.newsListView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:0]];
        }
    }else{
        loadingRow=currentRow;
        [self playBtnClick:self.playBtn];
    }
    self.playBtn.image=[UIImage imageNamed:@"pause.png"];
    self.playBtn.enabled=YES;
}

#pragma mark- button Action

- (IBAction)editBtnClick:(UIBarButtonItem *)sender {
    if (listmode==showSubscription) {
        [sender setTitle:@"Done"];
        listmode=editSubscription;
        [self prepareToShow:nil];
    }else if (listmode==editSubscription){
        [sender setTitle:@"Edit"];
        [[naDataProcessing shareInstance] deleteSubscriptionTopic:unSubscriptionTopic];
        [[naDataProcessing shareInstance] addSubscriptionTopic:userSubscriptionTopic];
        listmode=showSubscription;
        [self prepareToShow:nil];
    }
}

- (IBAction)menuBtnClick:(UIBarButtonItem *)sender {
    if (listmode==previousNews) {
        listmode=previousDate;
        [self prepareToShow:nil];
    }else if (listmode==selectTopicNews){
        listmode=showSubscription;
        [self prepareToShow:nil];
    }else{
        [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
    }
}

- (IBAction)playBtnClick:(UIBarButtonItem *)sender {
    
    if(currentRow==lastSpeakRow&&currentRow!=-1){
        if ([sender.image isEqual:[UIImage imageNamed:@"play.png"]]) {
            [sender setImage:[UIImage imageNamed:@"pause.png"]];
            [[naDataProcessing shareInstance] ttsResume];
        }else{
            [sender setImage:[UIImage imageNamed:@"play.png"]];
            [[naDataProcessing shareInstance] ttsPause];
            
        }
    }else{
        [sender setImage:[UIImage imageNamed:@"play.png"]];
        sender.enabled=NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_group_t group = dispatch_group_create();
            __block NSString *tmp=[[NSString alloc]init];
            NSInteger lastLoadRow=loadingRow;
            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (![[ttsLinks objectAtIndex:lastLoadRow] objectForKey:@"content"]) {
                    tmp=[[naDataProcessing shareInstance]parseLinkToGetContent:[[ttsLinks objectAtIndex:lastLoadRow] objectForKey:@"link"]];
                    if (tmp.length==0) {
                        [self nextNews];
                    }
                    NSString *date=[[ttsLinks objectAtIndex:lastLoadRow] objectForKey:@"pubDate"];
                    [[naDataProcessing shareInstance] saveTTSContent:[[ttsLinks objectAtIndex:lastLoadRow] objectForKey:@"link"] withDate:date andContent:tmp];
                }else{
                    tmp=[[ttsLinks objectAtIndex:currentRow] objectForKey:@"content"];
                }
            });
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                HomeViewCell *cell=(HomeViewCell *)[self.newsListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:0]];
                if (lastLoadRow==currentRow) {
                    [[naDataProcessing shareInstance] ttsPlay:tmp];
                    sender.enabled=YES;
                    [sender setImage:[UIImage imageNamed:@"pause.png"]];
                    lastSpeakRow=currentRow;
                }
                loadingRow=-1;
                [cell.activityIndicatorView stopAnimating];
            });
        });
        selectedRow=currentRow;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    
    _reloading = YES;
    [[naDataProcessing shareInstance] refreshTopicNews:[[naMainData shareInstance].userSubscriptionTopicDic allKeys]];
}

- (void)doneLoadingTableViewData{
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.newsListView];
    if (listmode==selectTopicNews||listmode==previousNews) {
        [self prepareToShow:topicToShow];
    }else{
        [self prepareToShow:nil];
    }

}

#pragma mark -
#pragma mark Data Source LoadingMore Methods

- (void)loadMoreTableViewDataSource {
    _loadingMore = YES;
    [NSThread detachNewThreadSelector:@selector(loadMore) toTarget:self withObject:nil];
}

-(void)loadMore{
 
//    [self.newsListView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newsToPlay.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)doneLoadMoreTableViewData {
    _loadingMore = NO;
    [_loadMoreFooterView loadMoreScrollViewDataSourceDidFinishedLoading:self.newsListView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y < 0){
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    else if(_hasMore){
        [_loadMoreFooterView loadMoreScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(scrollView.contentOffset.y < 0){
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }else if(_hasMore){
        [_loadMoreFooterView loadMoreScrollViewDidEndDragging:scrollView];
    }
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:15.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

#pragma mark -
#pragma mark LoadMoreTableFooterDelegate Methods

- (void)loadMoreTableFooterDidTriggerRefresh:(LoadMoreTableFooterView *)view {
    
    [self loadMoreTableViewDataSource];
    [self performSelectorOnMainThread:@selector(doneLoadMoreTableViewData) withObject:nil waitUntilDone:YES];
    
}

- (BOOL)loadMoreTableFooterDataSourceIsLoading:(LoadMoreTableFooterView *)view {
    return _loadingMore;
}

@end
