//
//  HomeViewCell.h
//  LowVision
//
//  Created by Sen Zeng on 14/12/26.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *pubDateLbl;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *sourceLbl;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end
