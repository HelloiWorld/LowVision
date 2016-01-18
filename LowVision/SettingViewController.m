//
//  SettingViewController.m
//  LowVision
//
//  Created by PZK on 14-12-3.
//  Copyright (c) 2014年 Naturalsoft. All rights reserved.
//

#import "SettingViewController.h"
#import "TitleListController.h"

@interface SettingViewController (){
    
    BOOL dropDownisOpen;
    NSString *dropDown;
    
    NSMutableArray *languageArray;

}

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    languageArray =[NSMutableArray arrayWithArray:[[naMainData shareInstance].rssAddressDic allKeys]];
    languageArray = [NSMutableArray arrayWithObjects:@"Chinese(China)",@"Chinese(Hong Kong)",@"Chinese(Taiwan)",@"English(United States)",@"English(United Kingdom)",nil];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleDefault;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleLightContent;
}


#pragma mark- tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"Voice";
    }else{
        return @"Speed";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (dropDownisOpen) {
                return 6;
            }else{
                return 1;
            }
            break;
        default:
            return 1;
            break;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"cell";
    static NSString *SpeedCellIdentifier = @"speedCell";
    static NSString *DropDownCellIdentifier = @"dropDownCell";
    switch ([indexPath section]) {
        case 0: {
            switch ([indexPath row]) {
                case 0: {
                    DropDownCell *cell = (DropDownCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    if (cell == nil){
                        NSLog(@"New Cell Made");
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:nil options:nil];
                        for(id currentObject in topLevelObjects){
                            if([currentObject isKindOfClass:[DropDownCell class]]){
                                cell = (DropDownCell *)currentObject;
                                break;
                            }
                        }
                    }
                    cell.textLabel.text=[naMainData shareInstance].ttsSpeaker;
                    dropDown = [naMainData shareInstance].ttsSpeaker;
                    return cell;
                    break;
                }
                default: {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    }
                    cell.textLabel.text = [languageArray objectAtIndex:indexPath.row-1];
                    return cell;
                    break;
                }
            }
            break;
        }
        case 1: {
            DropDownCell *cell = (DropDownCell*)[tableView dequeueReusableCellWithIdentifier:SpeedCellIdentifier];
            if (cell == nil) {
                cell = [[DropDownCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SpeedCellIdentifier];
            }
            cell.ttsSpeedSlider.value=[naMainData shareInstance].ttsSpeed;
            cell.ttsSpeedValueLbl.text=[NSString stringWithFormat:@"%.1f",[naMainData shareInstance].ttsSpeed];
            return cell;
            break;
        }
        default:
            return nil;
            break;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:{
                    DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:indexPath];
                    
                    NSMutableArray *indexPathArray=[[NSMutableArray alloc]init];
                    for (int i=1; i<=languageArray.count; i++) {
                         NSIndexPath *tmpPath = [NSIndexPath indexPathForRow:indexPath.row+i inSection:indexPath.section];
                        [indexPathArray addObject:tmpPath];
                    }
                    
                    if ([cell isOpen]){
                        [cell setClosed];
                        dropDownisOpen = [cell isOpen];
                        [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }else{
                        [cell setOpen];
                        dropDownisOpen = [cell isOpen];
                        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    break;
                }
                default:{
                    dropDown = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                    
                    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                    DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:path];
                    
                    cell.textLabel.text=dropDown;
                    
                    NSMutableArray *indexPathArray=[[NSMutableArray alloc]init];
                    for (int i=1; i<=languageArray.count; i++) {
                        NSIndexPath *tmpPath = [NSIndexPath indexPathForRow:[path row]+i inSection:indexPath.section];
                        [indexPathArray addObject:tmpPath];
                    }
        
                    
                    [cell setClosed];
                    dropDownisOpen = [cell isOpen];
                    
                    [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    break;
                }
            }
            break;
        }
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (IBAction)cancelSettingsClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)doneSettingsClick:(id)sender{
     DropDownCell *voiceCell=(DropDownCell *)[self.settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [[naDataProcessing shareInstance] changeSpeaker:voiceCell.textLabel.text];


    DropDownCell *speedCell=(DropDownCell *)[self.settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [[naDataProcessing shareInstance]changeSpeed:[speedCell.ttsSpeedValueLbl.text floatValue]];

    [self dismissViewControllerAnimated:YES completion:nil];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
