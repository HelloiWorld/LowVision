//
//  DropDownCell.m
//  DropDownTest
//
//  Created by Florian Krüger on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DropDownCell.h"


@implementation DropDownCell

@synthesize textLabel, arrow_upImg, arrow_downImg, isOpen;

- (void) setOpen 
{
    [arrow_downImg setHidden:YES];
    [arrow_upImg setHidden:NO];
    [self setIsOpen:YES];
}

- (void) setClosed
{
    [arrow_downImg setHidden:NO];
    [arrow_upImg setHidden:YES];
    [self setIsOpen:NO];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)changeSpeedValueSlider:(UISlider *)sender {
    self.ttsSpeedValueLbl.text=[NSString stringWithFormat:@"%.1f",sender.value];
}


@end
