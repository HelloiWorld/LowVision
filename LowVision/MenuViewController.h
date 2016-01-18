//
//  MenuViewController.h
//  LowVision
//
//  Created by Sen Zeng on 14/12/19.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *menuTableView;


@end
