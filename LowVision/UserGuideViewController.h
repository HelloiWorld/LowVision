//
//  UserGuideViewController.h
//  LowVision
//
//  Created by Sen Zeng on 14/12/17.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserGuideViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (weak,nonatomic) IBOutlet UIView *welcomeView;
@property (weak,nonatomic) IBOutlet UICollectionView *chooseChannelCollectionView;
@property (weak,nonatomic) IBOutlet UIButton *startBtn;

@end
