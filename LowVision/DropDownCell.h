//
//  DropDownCell.h
//  DropDownTest
//
//  Created by Florian Krüger on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DropDownCell : UITableViewCell {
    
    
    __weak IBOutlet UILabel *textLabel;
    __weak IBOutlet UIImageView *arrow_upImg;
    __weak IBOutlet UIImageView *arrow_downImg;
    
    BOOL isOpen;

}

- (void) setOpen;
- (void) setClosed;

@property (nonatomic) BOOL isOpen;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrow_downImg;
@property (weak, nonatomic) IBOutlet UIImageView *arrow_upImg;


@property (weak, nonatomic) IBOutlet UISlider *ttsSpeedSlider;
@property (weak, nonatomic) IBOutlet UILabel *ttsSpeedValueLbl;

- (IBAction)changeSpeedValueSlider:(UISlider *)sender;



@end
