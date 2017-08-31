//
//  COGVCTextInverse.m
//  Look Both Ways
//
//  Created by Conor McNinja on 08/03/2013.
//  Copyright (c) 2013 Clarity. All rights reserved.
//

#import "COGVCTextInverse.h"

@interface COGVCTextInverse ()

@end

@implementation COGVCTextInverse

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
	
    [_textLink1 setText:NSLocalizedString(@"InverseUniverseText1", nil)];
    [_textLink2 setText:NSLocalizedString(@"InverseUniverseText2", nil)];
}
-(IBAction)linkButtonClicked:(id)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.connolly-cleary.com/HALLofMIRRORS/INVERSE.html"]];
    
    NSLog(@"link button clicked");
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
