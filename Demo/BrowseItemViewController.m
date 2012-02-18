//
//  BrowseItemViewController.m
//  Demo
//
//  Created by zhicai on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BrowseItemViewController.h"
#import "VariableStore.h"
#import "UIViewController+ActivityIndicate.h"

@implementation BrowseItemViewController

@synthesize itemTitleLabel = _itemTitleLabel;
@synthesize itemDescriptionLabel = _itemDescriptionLabel;
@synthesize itemPriceLabel = _itemPriceLabel;
@synthesize itemExpiredDate = _itemExpiredDate;
@synthesize itemPriceChangedToLabel = _itemPriceChangedToLabel;
@synthesize currentItem = _currentItem;
@synthesize messageTextField = _messageTextField;
@synthesize navigationButton = _navigationButton;
@synthesize scrollView = _scrollView;
@synthesize pull = _pull;
@synthesize tpScrollView = _tpScrollView;
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


-(void)stopLoading
{
	[self.pull finishedLoading];
}

// called when the user pulls-to-refresh
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
  [self performSelector:@selector(loadOffer) withObject:nil afterDelay:2.0];	
}


-(void)loadMessageView
{
    CGFloat yOffset = 155;
    
    UIImage *line = [UIImage imageNamed:@"line.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:line];
    imageView.frame = CGRectMake(3, yOffset + 10, imageView.frame.size.width, imageView.frame.size.height);
    [self.scrollView addSubview:imageView];
    yOffset += 10;
    
    for (int i=0;i<[_currentOffer.messages count];i++) {
        yOffset += 5;
        UILabel* lblHeaderTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, yOffset, 310, 21)];
        [lblHeaderTitle setTextAlignment:UITextAlignmentLeft];
        //[lblHeaderTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0f]];
        [lblHeaderTitle setBackgroundColor:[UIColor lightGrayColor]];
        
      Message *message = [_currentOffer.messages objectAtIndex:i];
      
      NSString *title;
      
      if (VariableStore.sharedInstance.user.userId == message.dbId) {
        title = @"您";
      }else if(_currentOffer.buyerId == message.dbId) {
        title = @"买家";
      }else{
        title = @"卖家";
      }

        [lblHeaderTitle setTextColor:[UIColor blackColor]];
        
        [self.scrollView addSubview:lblHeaderTitle];
        
        UIImage *line = [UIImage imageNamed:@"line.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:line];
        imageView.frame = CGRectMake(3, yOffset + 25, imageView.frame.size.width, imageView.frame.size.height);
        [self.scrollView addSubview:imageView];
        
        //INCREMNET in yOffset 
        yOffset += 30;
        
        [self.scrollView setContentSize:CGSizeMake(320, yOffset)];    
    }
}

- (void)accountDidGetOffer:(NSDictionary *)dict
{
  DLog(@"BrowseItemViewController::accountDidGetOffer");  
  NSDictionary *offer = [dict objectForKey:@"offer"];
  _currentOffer = [[Offer alloc]initWithDictionary:offer];
  [self loadMessageView];
  [self hideIndicator];
  [self stopLoading];
  
  if (self.currentItem != nil) {
    self.itemTitleLabel.text = self.currentItem.title;
    self.itemDescriptionLabel.text = self.currentItem.description;
    self.itemPriceLabel.text = [NSString stringWithFormat:@"%@", self.currentItem.askPrice];
    self.itemPriceChangedToLabel.text = [NSString stringWithFormat:@"%@", self.currentItem.askPrice];
    
    NSTimeInterval theTimeInterval = [self.currentItem.postDuration integerValue];
    NSDate *postedDate = [[NSDate alloc] initWithTimeInterval:theTimeInterval sinceDate:self.currentItem.postedDate];
    
    //Set the required date format
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    //Get the string date
    self.itemExpiredDate.text = [formatter stringFromDate:postedDate];          
  } else if (self.currentOffer != nil) {
    self.itemTitleLabel.text = self.currentOffer.title;
    self.itemDescriptionLabel.text = self.currentOffer.description;
    self.itemPriceLabel.text = [NSString stringWithFormat:@"%@", self.currentOffer.price];
    self.itemPriceChangedToLabel.text = [NSString stringWithFormat:@"%@", self.currentOffer.price];
  }
  
}


- (void)loadOffer
{
  DLog(@"BrowseItemViewController::loadingOffer");
  [self showLoadingIndicator];
  VariableStore.sharedInstance.user.delegate = self;
  [VariableStore.sharedInstance.user getOffer:self.currentOffer.dbId];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pull = [[PullToRefreshView alloc] initWithScrollView:self.scrollView];
    [self.pull setDelegate:self];
    [self.scrollView addSubview:self.pull];
    [self loadOffer];
 
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:UI_BUTTON_LABEL_BACK
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(OnClick_btnBack:)];
    self.navigationItem.leftBarButtonItem = btnBack;   

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePriceChangedNotification:) 
                                                 name:CHANGED_PRICE_NOTIFICATION
                                               object:nil];
}

- (void) receivePriceChangedNotification:(NSNotification *) notification
{
    // [notification name] should always be CHANGED_PRICE_NOTIFICATION
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:CHANGED_PRICE_NOTIFICATION]) {
        
        self.itemPriceChangedToLabel.text = (NSString *)[notification object];
        DLog (@"Successfully received price changed notification! %@", (NSString *)[notification object]);
    }
}

-(IBAction)OnClick_btnBack:(id)sender  {
    if ([self.navigationItem.leftBarButtonItem.title isEqualToString:UI_BUTTON_LABEL_BACK]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.messageTextField resignFirstResponder];
    }
}

- (void)viewDidUnload
{
    [self setItemTitleLabel:nil];
    [self setItemDescriptionLabel:nil];
    [self setNavigationButton:nil];
    [self setItemPriceLabel:nil];
    [self setItemExpiredDate:nil];
    [self setItemPriceChangedToLabel:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGED_PRICE_NOTIFICATION object:nil];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.messageTextField) {
        self.navigationItem.leftBarButtonItem.title = UI_BUTTON_LABEL_CANCEL;
        //self.navigationController.navigationBar.backItem.title = @"取消";
        //self.navigationItem.leftBarButtonItem.tintColor = [UIColor redColor];
        self.navigationButton.title = UI_BUTTON_LABEL_SUBMIT;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.messageTextField) {
        self.navigationItem.leftBarButtonItem.title = UI_BUTTON_LABEL_BACK;
        //self.navigationController.navigationBar.backItem.title = @"上一步";
        self.navigationButton.title = UI_BUTTON_LABEL_MAP;
    }
}

- (void)accountDidCreateOffer:(NSDictionary *)dict
{
  DLog(@"BrowseItemViewController::accountDidCreateOffer:dict=%@", dict);
  NSDictionary *offer = [dict objectForKey:@"offer"] ;
  
  VariableStore.sharedInstance.user.delegate = self;
  [VariableStore.sharedInstance.user getOffer:[offer objectForKey:@"id"]];
}

- (IBAction)navigationButtonAction:(id)sender {
    if ([self.navigationButton.title isEqualToString:UI_BUTTON_LABEL_MAP]) {
        [self performSegueWithIdentifier: @"dealMapModal" 
                                  sender: self];
    } else if (self.navigationButton.title == UI_BUTTON_LABEL_SUBMIT) {
        // TODO - submitting data to backend server
          
      DLog(@"BrowseItemViewController::(IBAction)navigationButtonAction:postingOffer:");
      
      NSString *listingId = _currentItem ? _currentItem.dbId : _currentOffer.listingId;
      
      NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     self.itemPriceLabel.text, @"price",
                                     self.messageTextField.text, @"message",
                                     listingId, @"listing_id",nil];
      
      // submit listing
      VariableStore.sharedInstance.user.delegate = self;
      [VariableStore.sharedInstance.user createOffer:params];
      [self.messageTextField resignFirstResponder];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"changedPriceSegue"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        OfferChangingPriceViewController *ovc = (OfferChangingPriceViewController *)navigationController.topViewController;
        ovc.currentPrice = self.itemPriceLabel.text;
    }
}

@end
