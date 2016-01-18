//
//  SettingViewController.h
//  LowVision
//
//  Created by PZK on 14-12-3.
//  Copyright (c) 2014年 Naturalsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "naMainData.h"
#import "naDataProcessing.h"
#import "DropDownCell.h"

@interface SettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

- (IBAction)cancelSettingsClick:(id)sender;
- (IBAction)doneSettingsClick:(id)sender;

@end
