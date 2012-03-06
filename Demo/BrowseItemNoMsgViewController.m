//
//  BrowseItemNoMsgViewController.m
//  Demo
//
//  Created by zhicai on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BrowseItemNoMsgViewController.h"
#import "UIViewController+ActivityIndicate.h"
#import "UIViewController+KeyboardSlider.h"

@implementation BrowseItemNoMsgViewController

@synthesize messageTextField = _messageTextField;
@synthesize currentItem = _currentItem;
@synthesize navigationButton = _navigationButton;
@synthesize listingTitle = _listingTitle;
@synthesize listingDescription = _listingDescription;
@synthesize listingPrice = _listingPrice;
@synthesize listingDate = _listingDate;
@synthesize offerPrice = _offerPrice;
@synthesize mainView = _mainView;
@synthesize buttomView = _buttomView;
@synthesize scrollView = _scrollView;
@synthesize priceButton = _priceButton;
@synthesize pull = _pull;
@synthesize userInfoButton = _userInfoButton;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init scroll view content size
    [self.scrollView setContentSize:CGSizeMake(_ScrollViewContentSizeX, self.scrollView.frame.size.height)];
    
    self.pull = [[PullToRefreshView alloc] initWithScrollView:self.scrollView];
    [self.pull setDelegate:self];
    [self.scrollView addSubview:self.pull];
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:UI_BUTTON_LABEL_BACK
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(OnClick_btnBack:)];
    self.navigationItem.leftBarButtonItem = btnBack;  
    
    if (self.currentItem != nil) {
        self.listingTitle.text = self.currentItem.title;
        self.listingDescription.text = self.currentItem.description;
        self.listingPrice.text = [NSString stringWithFormat:@"%@", self.currentItem.askPrice];
        self.offerPrice.text = [NSString stringWithFormat:@"%@", self.currentItem.askPrice];
      self.listingDate.text = [self.currentItem getTimeLeftTextlong];       
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePriceChangedNotification:) 
                                                 name:CHANGED_PRICE_NOTIFICATION
                                               object:nil];

    // navigation bar background color
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:NAVIGATION_BAR_BACKGROUND_COLOR_RED green:NAVIGATION_BAR_BACKGROUND_COLOR_GREEN blue:NAVIGATION_BAR_BACKGROUND_COLOR_BLUE alpha:NAVIGATION_BAR_BACKGROUND_COLOR_ALPHA];
    
    // Bottom view load
    UIImage *bottomViewImg = [UIImage imageNamed:UI_IMAGE_SEND_MESSAGE_BACKGROUND];
    self.buttomView.frame = CGRectMake(0, self.buttomView.frame.origin.y, bottomViewImg.size.width, bottomViewImg.size.height + 15);
    [self.buttomView setBackgroundColor:[[UIColor alloc] initWithPatternImage:bottomViewImg]];

    UIImage *priceButtonImg = [UIImage imageNamed:UI_IMAGE_SEND_MESSAGE_PRICE];
    UIImage *priceButtonPressImg = [UIImage imageNamed:UI_IMAGE_SEND_MESSAGE_PRICE_PRESS];
    self.priceButton.frame = CGRectMake(self.priceButton.frame.origin.x, self.priceButton.frame.origin.y, priceButtonImg.size.width, priceButtonImg.size.height);
    [self.priceButton setImage:priceButtonImg forState:UIControlStateNormal];
    [self.priceButton setImage:priceButtonPressImg forState:UIControlStateSelected];
    [self.priceButton setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:UI_IMAGE_SEND_MESSAGE_PRICE]]];
    
    self.messageTextField.frame = CGRectMake(self.priceButton.frame.size.width + 15, self.priceButton.frame.origin.y, self.buttomView.frame.size.width - self.priceButton.frame.size.width - 20, self.priceButton.frame.size.height);
    
    
    // User info button
    UIImage *userButtonImg = [UIImage imageNamed:UI_IMAGE_USER_INFO_BUTTON_GREEN];
    UIImage *userButtonPressImg = [UIImage imageNamed:UI_IMAGE_USER_INFO_BUTTON_DARK];
    self.userInfoButton.frame = CGRectMake(self.userInfoButton.frame.origin.x, self.userInfoButton.frame.origin.y, userButtonImg.size.width, userButtonImg.size.height);
    [self.userInfoButton setImage:userButtonImg forState:UIControlStateNormal];
    [self.userInfoButton setImage:userButtonPressImg forState:UIControlStateSelected];
}

- (void) receivePriceChangedNotification:(NSNotification *) notification
{
    // [notification name] should always be CHANGED_PRICE_NOTIFICATION
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:CHANGED_PRICE_NOTIFICATION]) {
        
        self.offerPrice.text = (NSString *)[notification object];
        DLog (@"BrowseItemNoMsgViewController::receivePriceChangedNotification:%@", (NSString *)[notification object]);
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"changedPriceSegue"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        OfferChangingPriceViewController *ovc = (OfferChangingPriceViewController *)navigationController.topViewController;
        ovc.currentPrice = self.offerPrice.text;
    }
}

- (void)viewDidUnload
{
    [self setListingTitle:nil];
    [self setListingDescription:nil];
    [self setListingPrice:nil];
    [self setListingDate:nil];
    [self setOfferPrice:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGED_PRICE_NOTIFICATION object:nil];
    [self setPriceButton:nil];
    [self setUserInfoButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(IBAction)showActionSheet:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:UI_BUTTON_LABEL_SHARE_WITH_FRIEND delegate:self cancelButtonTitle:UI_BUTTON_LABEL_CANCEL destructiveButtonTitle:nil otherButtonTitles:UI_BUTTON_LABEL_WEIBO_SHARE, UI_BUTTON_LABEL_SEND_MESSAGE, UI_BUTTON_LABEL_SEND_EMAIL, nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

- (void)accountRequestFailed:(NSDictionary *)errors
{
  DLog(@"BrowseItemNoMsgViewController::requestFailed");
  [self hideIndicator];
}

- (void)accountDidCreateOffer:(NSDictionary *)dict
{
  DLog(@"BrowseItemNoMsgViewController::accountDidCreateOffer:dict=%@", dict);

  [self kassAddToModelDict:@"BrowseItemViewController":dict];
  
  UINavigationController *navController = self.navigationController;
  // Pop this controller and replace with another
  [navController popViewControllerAnimated:NO];
  [(BrowseTableViewController *)[navController.viewControllers objectAtIndex:([navController.viewControllers count]-1)] switchBrowseItemView];
  
}

- (IBAction)navigationButtonAction:(id)sender {
    if ([self.navigationButton.title isEqualToString:UI_BUTTON_LABEL_SHARE]) {
        // TODO - share on WEIBO
        [self showActionSheet:sender];
        
        
    } else if (self.navigationButton.title == UI_BUTTON_LABEL_SEND) {
      
      // submit listing
      DLog(@"BrowseItemNoMsgViewController::(IBAction)navigationButtonAction:createOffer:");
      NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     self.offerPrice.text, @"price",
                                     self.messageTextField.text, @"message",
                                     self.currentItem.dbId, @"listing_id",nil];
      
      [self showLoadingIndicator];
      [self.currentUser createOffer:params];
      [self.messageTextField resignFirstResponder];
      [self hideKeyboardAndMoveViewDown];
      
    }
}

- (void) accountWeiboShareFinished
{
  DLog(@"BrowseItemNoMsgViewController::accountWeiboShareFinished");
  
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
       
      //share weibo
      [[self currentUser] weiboShare:_currentItem];
      
    } else if (buttonIndex == 1) {
        //self.label.text = @"Other Button 1 Clicked";
    } else if (buttonIndex == 2) {
        //self.label.text = @"Other Button 2 Clicked";
    } else if (buttonIndex == 3) {
        //self.label.text = @"Cancel Button Clicked";
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if (sender == self.messageTextField) {
        self.navigationItem.leftBarButtonItem.title = UI_BUTTON_LABEL_CANCEL;
        self.navigationButton.title = UI_BUTTON_LABEL_SEND;
    }
    
    if ([sender isEqual:self.messageTextField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.mainView.frame.origin.y >= 0)
        {
            [self showKeyboardAndMoveViewUp];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately
    _keyboardRect = [[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue];
  [self registerKeyboardRect:_keyboardRect];
    
    if ([self.messageTextField isFirstResponder] && self.mainView.frame.origin.y >= 0)
    {
        [self showKeyboardAndMoveViewUp];
    }
}

/* Keyboard avoiding end */

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.messageTextField) {
        self.navigationItem.leftBarButtonItem.title = UI_BUTTON_LABEL_BACK;
        self.navigationButton.title = UI_BUTTON_LABEL_SHARE;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
  // register for keyboard view slider
  [self registerKeyboardSlider:_mainView :_scrollView :_buttomView];
  
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window]; 
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil]; 
}

-(void)stopLoading
{
	[self.pull finishedLoading];
}

// called when the user pulls-to-refresh
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];	
}

-(IBAction)OnClick_btnBack:(id)sender  {
    if ([self.navigationItem.leftBarButtonItem.title isEqualToString:UI_BUTTON_LABEL_BACK]) {
        [self dismissModalViewControllerAnimated:YES];
        //[self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.messageTextField resignFirstResponder];
        [self hideKeyboardAndMoveViewDown];
    }
}

@end
