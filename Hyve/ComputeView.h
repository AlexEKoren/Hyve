//
//  ComputeView.h
//  Hyve
//
//  Created by Alex Koren on 8/12/13.
//  Copyright (c) 2013 AlexAndSheldonApps. All rights reserved.
//

#import <Parse/Parse.h>

@interface ComputeView : UIViewController
- (IBAction)onStart:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *startButtonAttributes;

@property (strong, nonatomic) IBOutlet UIImageView *loadImage;

@property (strong, nonatomic) IBOutlet UILabel *totalScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *nowScoreLabel;

@end
