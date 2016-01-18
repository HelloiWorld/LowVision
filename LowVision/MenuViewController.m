//
//  MenuViewController.m
//  LowVision
//
//  Created by Sen Zeng on 14/12/19.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import "MenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "TitleListController.h"
#import "naDataProcessing.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.parentViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (tableView.frame.size.height/5);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *titles=[[NSArray alloc] initWithObjects:@"每日精选",@"往期回顾",@"My Subscription",@"Settings", nil];
    NSArray *images=[[NSArray alloc] initWithObjects:@"news.png",@"news.png",@"ebook.png",@"settings.png", nil];
    UITableViewCell *menuCell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    menuCell.textLabel.textColor=[UIColor whiteColor];
    menuCell.textLabel.text=[titles objectAtIndex:indexPath.row];
    menuCell.imageView.image=[UIImage imageNamed:[images objectAtIndex:indexPath.row]];
    return menuCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TitleListController *titleListController = [self.storyboard instantiateViewControllerWithIdentifier:@"TitleListController"];
    titleListController=self.menuContainerViewController.centerViewController;
    if (indexPath.row==0) {
        NSDate *today=[[naDataProcessing shareInstance] getCompareDate:@"today"];
        [[naDataProcessing shareInstance] getDailyNews:today];
        [titleListController prepareToShow:@"todayNews"];
        [self.menuContainerViewController setMenuState:        MFSideMenuStateClosed];
    }else if (indexPath.row==1){
        [titleListController prepareToShow:@"previousNews"];
        [self.menuContainerViewController setMenuState:        MFSideMenuStateClosed];
    }else if (indexPath.row==2){
        [titleListController prepareToShow:@"showSubscription"];
        [self.menuContainerViewController setMenuState:        MFSideMenuStateClosed];
    }else{
        [self performSegueWithIdentifier:@"settings" sender:nil];
        [[naDataProcessing shareInstance] ttsStop];
        [titleListController prepareToShow:@"todayNews"];
        [titleListController.playBtn setImage:[UIImage imageNamed:@"play.png"]];
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

@end
