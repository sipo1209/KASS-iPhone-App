//
//  MainTabBarViewController.m
//  Demo
//
//  Created by zhicai on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainTabBarViewController.h"

@implementation MainTabBarViewController

- (void)tabBarController:(UITabBarController *)tbc didSelectViewController:(UIViewController *)vc {
    // Middle tab bar item in question.
    NSLog(@"MainTabBarViewController tabBarController");
    if (vc == [tbc.viewControllers objectAtIndex:4]) {
        NSLog(@"MainTabBarViewController vvvvvvvvv");
        //ScanVC *scanView = [[ScanVC alloc] initWithNibName:@"ScanViewController" bundle:nil];
        
        // set properties of scanView's ivars, etc
        
        //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:scanView];
        
        [tbc presentModalViewController:vc animated:YES];
        //[navigationController release];
        //[scanView release];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      NSLog(@"MainTabBarViewController::initWithNibName ");
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidAppear:(BOOL)animated
{
  NSLog(@"MainTabBarViewController::viewDidAppear ");
  [self showMessage];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{   
  NSLog(@"MainTabBarViewController::viewDidLoad ");
  [super viewDidLoad];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showMessage {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"KASS Get Started" 
                                                      message:@"Buy and Sell Anything with People Nearby " 
                                                     delegate:self 
                                            cancelButtonTitle:@"or just skip this for now" 
                                            otherButtonTitles:@"Sign Up", @"Login", @"Sign in with Facebook", nil];
    
    //UIImageView *Image =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"images.png"]];
    
    //[message addSubview:Image];
    
    //[message show];
    [MTPopupWindow showWindowWithHTMLFile:@"testContent.html" insideView:self.view];
    //[ALToastView toastInView:self.view withText:@"Hello ALToastView"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	
	if([title isEqualToString:@"Sign in with Facebook"])
	{
        [[VariableStore sharedInstance] signIn];
		NSLog(@"Sign in with Facebook was selected.");
	}
	else if([title isEqualToString:@"Sign Up"])
	{
		NSLog(@"Sign Up was selected.");
	}
	else if([title isEqualToString:@"Login"])
	{
        [[VariableStore sharedInstance] signIn];
        NSLog(@"Sign in: %@", [VariableStore sharedInstance].isLoggedIn);
		NSLog(@"Login was selected.");
	} 
	else if([title isEqualToString:@"or just skip this for now"])
    {
        NSLog(@"or just skip this for now was selected.");
    }
}

@end
