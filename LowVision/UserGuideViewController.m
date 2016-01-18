//
//  UserGuideViewController.m
//  LowVision
//
//  Created by Sen Zeng on 14/12/17.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import "UserGuideViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "TitleListController.h"
#import "MyCollectionViewCell.h"
#import "naMainData.h"
#import "naDataProcessing.h"

#define SECTION_INSET 20.0
#define IMG_HEIGHT 30.0

@interface UserGuideViewController ()

@end

@implementation UserGuideViewController{
    NSArray *channelArray;
    NSMutableArray *selectedItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startBtn.layer.masksToBounds=YES;
    self.startBtn.layer.cornerRadius=self.startBtn.frame.size.height/2;
    self.startBtn.layer.borderWidth=0;
    //设置CollectionView可多选
    self.chooseChannelCollectionView.allowsMultipleSelection=YES;
    selectedItems=[[NSMutableArray alloc]init];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    self.welcomeView.hidden=YES;
    CATransition *transition=[CATransition animation];
    transition.delegate=self;
    transition.duration=1.5;
    transition.type=kCATransitionFade;
    [self.welcomeView.layer addAnimation:transition forKey:Nil];
}

#pragma mark - CollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    channelArray=[[NSArray alloc] initWithArray:[[naMainData shareInstance].rssAddressDic allKeys]];
    return channelArray.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width=collectionView.frame.size.width-SECTION_INSET;
    CGFloat height=IMG_HEIGHT+30.0;
    return CGSizeMake(width, height);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    MyCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"channelCell" forIndexPath:indexPath];
    cell.layer.masksToBounds=YES;
    cell.layer.cornerRadius=cell.frame.size.height/2;
    cell.layer.borderWidth=0;
    cell.backgroundColor=[UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1];
    cell.topicLbl.text=[channelArray objectAtIndex:indexPath.row];
    if (indexPath.row==0||[[collectionView indexPathsForSelectedItems] containsObject:indexPath]) {
        if (![selectedItems containsObject:cell.topicLbl.text]) {
            [selectedItems addObject:cell.topicLbl.text];
        }
        cell.ischeckImg.image=[UIImage imageNamed:@"OK.png"];
    }else{
        cell.ischeckImg.image=[UIImage imageNamed:@"No.png"];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    MyCollectionViewCell *cell=(MyCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (indexPath.row!=0) {
        [selectedItems removeObject:cell.topicLbl.text];
        cell.ischeckImg.image=[UIImage imageNamed:@"No.png"];
    }
    else{
        [collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MyCollectionViewCell *cell=(MyCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (indexPath.row!=0) {
        [selectedItems addObject:cell.topicLbl.text];
        cell.ischeckImg.image=[UIImage imageNamed:@"OK.png"];
    }
}

- (IBAction)BtnStartClick:(id)sender {
    [[naDataProcessing shareInstance] addSubscriptionTopic:selectedItems];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MFSideMenuContainerViewController *container=[[MFSideMenuContainerViewController alloc]init];
    container=[storyboard instantiateViewControllerWithIdentifier:@"MFSideMenuContainerViewController"];
    TitleListController *titleListController=[storyboard instantiateViewControllerWithIdentifier:@"TitleListController"];
    UIViewController *leftSideMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftSideMenuViewController"];
    [container setLeftMenuViewController:leftSideMenuViewController];
    [container setCenterViewController:titleListController];
    
    [self.navigationController pushViewController:container animated:YES];
    [titleListController openLoadingView];
    
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
