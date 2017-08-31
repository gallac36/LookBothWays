//
//  COGVCTextTimeSlice.h
//  Look Both Ways
//
//  Created by Conor McNinja on 08/03/2013.
//  Copyright (c) 2013 Clarity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COGVCTextTimeSlice : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *textLink1;
@property (weak, nonatomic) IBOutlet UILabel *textLink2;
-(IBAction)linkButtonClicked:(UIButton *)sender;

@end
