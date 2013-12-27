//
//  ComputeView.m
//  Hyve
//
//  Created by Alex Koren on 8/12/13.
//  Copyright (c) 2013 AlexAndSheldonApps. All rights reserved.
//

#import "ComputeView.h"


@implementation ComputeView
@synthesize loadImage;

@synthesize startButtonAttributes;
@synthesize totalScoreLabel;
@synthesize nowScoreLabel;

NSNumber *startNum;
NSNumber *endNum;

NSMutableArray *primes;
NSArray *loadPics;
int packetSize;
int totalNum;
bool stopped;
bool canRestart;

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
    totalNum= 0;
    packetSize = 10000;
    
    canRestart = YES;
    stopped = YES;
    [super viewDidLoad];
    primes = [[NSMutableArray alloc]init];

    [nowScoreLabel setText:[NSString stringWithFormat:@"%i", 0]];
    [totalScoreLabel setText:[NSString stringWithFormat:@"%i", 0]];

    
    loadPics = [NSArray arrayWithObjects:
                [UIImage imageNamed:@"HyveBgLoad(1)"],[UIImage imageNamed:@"HyveBgLoad(2)"],
                [UIImage imageNamed:@"HyveBgLoad(3)"],[UIImage imageNamed:@"HyveBgLoad(4)"],
                [UIImage imageNamed:@"HyveBgLoad(5)"],[UIImage imageNamed:@"HyveBgLoad(6)"],
                [UIImage imageNamed:@"HyveBgLoad(7)"],[UIImage imageNamed:@"HyveBgLoad(8)"],
                [UIImage imageNamed:@"HyveBgLoad(9)"],[UIImage imageNamed:@"HyveBgLoad(10)"],
                [UIImage imageNamed:@"HyveBgLoad(11)"],[UIImage imageNamed:@"HyveBgLoad(12)"],
                [UIImage imageNamed:@"HyveBgLoad(13)"],[UIImage imageNamed:@"HyveBgLoad(14)"],
                [UIImage imageNamed:@"HyveBgLoad(15)"],[UIImage imageNamed:@"HyveBgLoad(16)"],
                [UIImage imageNamed:@"HyveBgLoad(17)"],[UIImage imageNamed:@"HyveBgLoad(18)"],
                [UIImage imageNamed:@"HyveBgLoad(19)"],[UIImage imageNamed:@"HyveBgLoad(20)"],
                [UIImage imageNamed:@"HyveBgLoad(21)"],[UIImage imageNamed:@"HyveBgLoad(22)"], nil];
    //NSLog([NSString stringWithFormat:@"%i", [loadPics count]]);

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onStart:(id)sender  {
    if (stopped) {
        stopped = NO;
        [startButtonAttributes setTitle:@"Stop" forState:normal];
        [startButtonAttributes setTitleColor:[UIColor redColor] forState:normal];
        [self performSelectorInBackground:@selector(loadAnimate) withObject:self];
        
        [self queryForPacket];
    }
    else {
        //[primes removeAllObjects];

        stopped = YES;
        canRestart = NO;

        [self.loadImage stopAnimating];
        
        [startButtonAttributes setTitle:@"Start" forState:normal];
        [startButtonAttributes setTitleColor:[UIColor whiteColor] forState:normal];
        
    }
    
}

-(void) queryForPacket{
    [primes removeAllObjects];

    PFQuery *query = [PFQuery queryWithClassName:@"Packets"];
    [query orderByAscending:@"StartNumber"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            //error
        } else {
            
            startNum = [object objectForKey:@"StartNumber"];
            endNum = [object objectForKey:@"EndNumber"];
            
            [object deleteInBackground];

            NSThread* runningPrimesThread = [[NSThread alloc] initWithTarget:self
                                                                    selector:@selector(compute)
                                                                      object:nil];
            [runningPrimesThread start];
        }
    }];
}

- (bool)isPrime: (long) num {
    long n = num;
    long s = sqrt(n)+1;
    
    for (long x = 3; x < s; x++) {
        if (n%x==0) {
            return false;
        }
    }
    return true;
}



- (void)compute {
    long n = [startNum longValue];
    long e = [endNum longValue];

    if (!(n&1)) {
        n=n+1;
    }
    while (n < e && !stopped) {
        if ([self isPrime:n]) {
            [primes addObject:[NSNumber numberWithLong:n]];
        }
        n=n+2;
    }

    
    for (int x = 0; x < [primes count]; x++) {
        totalNum ++;

        [nowScoreLabel setText:[NSString stringWithFormat:@"%i", x]];
        [totalScoreLabel setText:[NSString stringWithFormat:@"%i", totalNum]];

        PFObject *temp = [PFObject objectWithClassName:@"Primes"];
        [temp setObject:[primes objectAtIndex:x] forKey:@"Prime"];
        [primes replaceObjectAtIndex:x withObject:temp];
    }
    [PFObject saveAllInBackground:primes block: ^(BOOL done, NSError *error){
        canRestart = YES;}];
    
    if (n < e && stopped) {
        NSLog(@"N IS LOWER: %li, %li", n, e);
        PFObject *packet = [PFObject objectWithClassName:@"Packets"];
        [packet setObject:[NSNumber numberWithLong:n] forKey:@"StartNumber"];
        [packet setObject:[NSNumber numberWithLong:e] forKey:@"EndNumber"];
        [packet saveInBackground];
        
        [nowScoreLabel setText:[NSString stringWithFormat:@"%i", [primes count]]];
        [totalScoreLabel setText:[NSString stringWithFormat:@"%i", totalNum]];
        
    } else {
        NSLog(@"MAX");
        PFQuery *maxQuery = [PFQuery queryWithClassName:@"Max"];
        [maxQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!object) {
                //error
            } else {
                long m = [[object objectForKey:@"Max"] longValue];
                for (int o = 0; o < 2; o++) {
                    PFObject *packet = [PFObject objectWithClassName:@"Packets"];
                    [packet setObject:[NSNumber numberWithLong:m + o * packetSize] forKey:@"StartNumber"];
                    [packet setObject:[NSNumber numberWithLong:m + (o + 1) * packetSize] forKey:@"EndNumber"];
                    [packet saveInBackground];
                }
                [object setObject:[NSNumber numberWithLong:m + (2 * packetSize)] forKey:@"Max"];
                [object saveInBackground];
            }
            [nowScoreLabel setText:[NSString stringWithFormat:@"%i", [primes count]]];
            [totalScoreLabel setText:[NSString stringWithFormat:@"%i", totalNum]];
            
            [self queryForPacket];
        }];        

        
    }
}

- (void)loadAnimate {
    self.loadImage.animationImages = loadPics;
    self.loadImage.animationDuration = 1.5;
    //self.loadImage.animationRepeatCount = 5;
    [self.loadImage startAnimating];
    
}

@end
