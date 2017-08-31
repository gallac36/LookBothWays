//
//  COGVCMovingStill.m
//  Look Both Ways
//
//  Created by Conor McNinja on 08/03/2013.
//  Copyright (c) 2013 Clarity. All rights reserved.
//

#import "COGVCMovingStill.h"

@interface COGVCMovingStill ()

@end

@implementation COGVCMovingStill

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(IBAction)linkButtonClicked:(id)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.connolly-cleary.com/HALLofMIRRORS/MOVING.html"]];
    
    NSLog(@"link button clicked");
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    [_textLink1 setText:NSLocalizedString(@"MoveingStillText", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//Lock the screen into portrait
- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
// pre-iOS 6 support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
