//
//  BrowseItemViewController.m
//  Demo
//
//  Created by zhicai on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BrowseItemViewController.h"
#import "VariableStore.h"
#import "ViewHelper.h"
#import "UIViewController+ActivityIndicate.h"
#import "UIViewController+KeyboardSlider.h"
#import "UIViewController+SegueActiveModel.h"
#import "UIViewController+ScrollViewRefreshPuller.h"
#import "UIViewController+PriceModifier.h"

@implementation BrowseItemViewController

@synthesize itemTitleLabel = _itemTitleLabel;
@synthesize itemPriceLabel = _itemPriceLabel;
@synthesize itemExpiredDate = _itemExpiredDate;
@synthesize itemPriceChangedToLabel = _itemPriceChangedToLabel;

@synthesize messageTextField = _messageTextField;
@synthesize navigationButton = _navigationButton;
@synthesize scrollView = _scrollView;
@synthesize mainView = _mainView;
@synthesize buttomView = _buttomView;
@synthesize topView = _topView;
@synthesize userInfoButton = _userInfoButton;
@synthesize mapButton = _mapButton;

@synthesize descriptionTextView = _descriptionTextView;
@synthesize changePriceMessage = _changePriceMessage;
@synthesize leftButton = _leftButton;
@synthesize rightButton = _rightButton;
@synthesize priceButton = _priceButton;
@synthesize currentOffer = _currentOffer;

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

/**
 Scroll View Refresh Puller Delegate
 */
- (void)refreshing{
  [self loadDataSource];
}

- (void)populateData:(NSDictionary *)dict
{
  NSDictionary *offer = [dict objectForKey:@"offer"];
  self.currentOffer = [[Offer alloc]initWithDictionary:offer];
  
  [ViewHelper buildOfferScrollView:self.scrollView:[self currentUser]:_currentOffer];
  [self hideIndicator];
  [self stopLoading];
  
  self.itemTitleLabel.text = self.currentOffer.title;
  self.descriptionTextView.text = self.currentOffer.description;
  self.itemPriceLabel.text = [NSString stringWithFormat:@"%@", self.currentOffer.price];
  
  [self modifyPriceModifierPrice:self.currentOffer.price];
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setAMSymbol:@"AM"];
  [formatter setPMSymbol:@"PM"];
  [formatter setDateFormat:@"MM/dd/yy hh:mm a"];
  self.itemExpiredDate.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:self.currentOffer.listItemEndedAt]];
  
}

- (void)accountDidGetOffer:(NSDictionary *)dict
{
  DLog(@"BrowseItemViewController::accountDidGetOffer");  
  [self populateData:dict];
}


- (void)accountRequestFailed:(NSDictionary *)errors
{
  DLog(@"BrowseItemViewController::requestFailed");
  [self hideIndicator];
  [self stopLoading];
}

- (void)loadDataSource
{
  DLog(@"BrowseItemViewController::loadingOffer");
  [self showLoadingIndicator];
  
  //check if currentOffer object is nil, if so get from kassModelDict
  NSString *offerId = [[self kassGetModelDict:@"offer"] objectForKey:@"id"];
  
  if ( offerId && ![offerId isBlank] ) {
    [self.currentUser getOffer:offerId];
  }
}

- (void)priceModificationDidFinish:(NSInteger)price
{
  DLog (@"BrowseItemViewController::priceModificationDidFinish:%d", price);
  self.itemPriceChangedToLabel.text = [NSString stringWithFormat:@"%d", price];
  
  [CommonView setMessageWithPriceView:self.scrollView payImage:nil bottomView:self.buttomView priceButton:self.priceButton messageField:self.messageTextField price:self.itemPriceChangedToLabel.text changedPriceMessage:self.changePriceMessage];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // navigation bar background color
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:NAVIGATION_BAR_BACKGROUND_COLOR_RED green:NAVIGATION_BAR_BACKGROUND_COLOR_GREEN blue:NAVIGATION_BAR_BACKGROUND_COLOR_BLUE alpha:NAVIGATION_BAR_BACKGROUND_COLOR_ALPHA];
    
    // init scroll view content size
    [self.scrollView setContentSize:CGSizeMake(_ScrollViewContentSizeX, self.scrollView.frame.size.height)]; 

    [self registerPriceModifier];
    
    // Bottom view load
    [CommonView setMessageWithPriceView:self.scrollView payImage:nil bottomView:self.buttomView priceButton:self.priceButton messageField:self.messageTextField price:self.itemPriceChangedToLabel.text changedPriceMessage:self.changePriceMessage];
    
    // User info button
    [ViewHelper buildUserInfoButton:self.userInfoButton]; 
    [ViewHelper buildMapButton:self.rightButton];
    self.rightButton.tag = RIGHT_BAR_BUTTON_MAP;
    [ViewHelper buildBackButton:self.leftButton];
    self.leftButton.tag = LEFT_BAR_BUTTON_BACK;

}

- (void)viewDidUnload
{
    [self unregisterPriceModifier];
    [self setItemTitleLabel:nil];
    [self setNavigationButton:nil];
    [self setItemPriceLabel:nil];
    [self setItemExpiredDate:nil];
    [self setItemPriceChangedToLabel:nil];
    [self setMainView:nil];
    [self setButtomView:nil];
    [self setTopView:nil];
    [self setPriceButton:nil];
    [self setUserInfoButton:nil];
    [self setDescriptionTextView:nil];
    [self setChangePriceMessage:nil];
    [self setLeftButton:nil];
    [self setRightButton:nil];
    [super viewDidUnload];
    [self setMapButton:nil];
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

- (void)accountDidModifyOffer:(NSDictionary *)dict
{
  DLog(@"BrowseItemViewController::accountDidModifyOffer");  
  [self populateData:dict];
}

- (IBAction)leftButtonAction:(id)sender {
    if (self.leftButton.tag == LEFT_BAR_BUTTON_BACK) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.messageTextField resignFirstResponder];
        [self hideKeyboardAndMoveViewDown];
    }
}


- (IBAction)rightButtonAction:(id)sender {
    if (self.rightButton.tag == RIGHT_BAR_BUTTON_SEND) {
        
      DLog(@"BrowseItemViewController::(IBAction)rightButtonAction:modifyOffer:");
      NSMutableDictionary* params = [Offer getParamsToModify:[self kassVS].priceToModify:self.messageTextField.text];
      
      // modify listing
      [self showLoadingIndicator];
      [self.currentUser modifyOffer:params:_currentOffer.dbId];
      [self.messageTextField resignFirstResponder];
      [self hideKeyboardAndMoveViewDown];
      
    } else if (self.rightButton.tag == RIGHT_BAR_BUTTON_MAP) {
        
      VariableStore.sharedInstance.itemToShowOnMap = [_currentOffer getListItemToMap];
      [self performSegueWithIdentifier: @"dealMapModal" 
                                  sender: self];
    }
}

/** 
 KeyboardSliderDelegate
 */
- (void) keyboardMainViewMovedDown{
  [ViewHelper buildBackButton:self.leftButton];
  self.leftButton.tag = LEFT_BAR_BUTTON_BACK;
  [ViewHelper buildMapButton:self.rightButton];
  self.rightButton.tag = RIGHT_BAR_BUTTON_MAP;
}

- (void) keyboardMainViewMovedUp{
  [ViewHelper buildCancelButton:self.leftButton];
  self.leftButton.tag = LEFT_BAR_BUTTON_CANCEL;
  [ViewHelper buildSendButton:self.rightButton];
  self.rightButton.tag = RIGHT_BAR_BUTTON_SEND;
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:_messageTextField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.mainView.frame.origin.y >= 0)
        {
            [self showKeyboardAndMoveViewUp];
        }
    }
    if ([sender isEqual:_messageTextField]) {
        [ViewHelper buildCancelButton:self.leftButton];
        self.leftButton.tag = LEFT_BAR_BUTTON_CANCEL;
    }
}

/**
 Overwrite UIViewController+KeyboardSlider shouldKeyboardViewMoveUp
 */
- (BOOL)shouldKeyboardViewMoveUp
{
  return [_messageTextField isFirstResponder] && self.mainView.frame.origin.y >= 0;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.messageTextField) {
        self.navigationItem.leftBarButtonItem.title = UI_BUTTON_LABEL_BACK;
        self.navigationButton.title = UI_BUTTON_LABEL_MAP;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [self registerKeyboardSlider:_mainView :_scrollView :_buttomView];
  [self registerKeyboardSliderTextView:_descriptionTextView];
  [self registerScrollViewRefreshPuller:self.scrollView];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [self unregisterScrollViewRefreshPuller];
  [self unregisterKeyboardSlider];
}

@end
