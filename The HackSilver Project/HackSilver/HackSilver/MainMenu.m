//
//  MainMenu.m
//  HackSilver
//
//  Created by Matthew French on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "AppDelegate.h"

@implementation MainMenu

- (void)snowUpdate {
    if (rand()%2 == 0) {
        UIImageView *flake = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Snow Flake.png"]];
        flake.center = CGPointMake((rand()%800)-300,-10);
        [self.view addSubview: flake];
        [snowPieces addObject:flake];
    }
    for (int i = 0; i < [snowPieces count];i++) {
        UIImageView *flake = [snowPieces objectAtIndex:i];
        flake.center = CGPointMake(flake.center.x+1,flake.center.y+1);
        if (flake.center.y > 330 || flake.center.x > 490) {
            [flake removeFromSuperview];
            [snowPieces removeObjectAtIndex:i];
            i-=1;
        }
    }
}

- (IBAction)play {
    [self.navigationController pushViewController:[[Game alloc] initWithNibName:@"Game" bundle:nil] animated:YES];
}
- (IBAction)instructions {
    [self.navigationController pushViewController:[[Instructions alloc] initWithNibName:@"Instructions" bundle:nil] animated:YES];
}
- (IBAction)credits {
    [self.navigationController pushViewController:[[Credits alloc] initWithNibName:@"Credits" bundle:nil] animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    snowPieces = [[NSMutableArray alloc] init];
    snowTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(snowUpdate) userInfo:nil repeats:YES];
    srand(time(NULL));
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return ( UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

@end
