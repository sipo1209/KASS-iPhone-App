//
//  ActivityViewController.m
//  Demo
//
//  Created by zhicai on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityViewController.h"
#import "UIViewController+ActivityIndicate.h"
#import "UIViewController+SegueActiveModel.h"
#import "UIViewController+TableViewRefreshPuller.h"
#import "ViewHelper.h"


@implementation ActivityViewController

@synthesize tabImageView = _tabImageView;
@synthesize emptyImageView = _emptyImageView;
@synthesize indicatorImageView = _indicatorImageView;
@synthesize emptyRecordsImageView = _emptyRecordsImageView;
@synthesize listingsTableView = _listingsTableView;
@synthesize tableView = _tableView;
@synthesize activitySegment = _activitySegment;
@synthesize userId = _userId;

NSMutableArray *currentItems;

/**
 EGORefreshTableHeaderDelegate
 */
- (void)refreshing
{
  [self loadDataSource];
}

- (void)accountLogoutFinished
{
    DLog(@"ActivityViewController::accountLogoutFinished");
    [self updateTableView];
}

- (void) accountLoginFinished
{
    DLog(@"ActivityViewController::accountLoginFinished");
    [self updateTableView];
}

- (void) accountDidGetListings:(NSDictionary *)dict
{
    DLog(@"ActivityViewController::accountDidGetListings:dict");
    [self getBuyingItems:dict];
}

- (void) accountDidGetOffers:(NSDictionary *)dict
{
    DLog(@"ActivityViewController::accountDidGetOffers:dict");
    [self getSellingItems:dict];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isBuyingTabSelected
{
    return 0 == self.tabImageView.tag;
    //return 0 == self.activitySegment.selectedSegmentIndex;
}

- (BOOL) isSellingTabSelected
{
    return 1 == self.tabImageView.tag;
    //return 1 == self.activitySegment.selectedSegmentIndex;
}

- (void)showBackground
{
//    if (self.emptyRecordsImageView == nil || self.emptyRecordsImageView.image == nil) {
//        self.emptyRecordsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:UI_IMAGE_ACTIVITY_BACKGROUND]];
//        [self.view addSubview:self.emptyRecordsImageView];
//    }
    [self hideIndicator];
}

- (void)reset
{
    [VariableStore sharedInstance].myBuyingListings = nil;
    [VariableStore sharedInstance].mySellingListings = nil;
}

//- (void)hideBackground
//{
//    if( self.emptyRecordsImageView && [currentItems count] > 0){
//        [self.emptyRecordsImageView removeFromSuperview];
//        self.emptyRecordsImageView = nil;
//    }
//}

- (void)updateTableView
{
    if (![VariableStore.sharedInstance isLoggedIn]){
        [self showBackground];
    } else if (![VariableStore.sharedInstance isCurrentUser:_userId]) {     
        _userId = VariableStore.sharedInstance.user.userId;
        [self reset];
        [self loadDataSource];
    } else if ( (!VariableStore.sharedInstance.myBuyingListings && [self isBuyingTabSelected]) || 
               (!VariableStore.sharedInstance.mySellingListings && [self isSellingTabSelected]) ) {
        [self loadDataSource];
    } else {
        [self reloadTable];
    }
}

- (IBAction)pressBuyingListButton:(id)sender {
    DLog(@"MyActivityViewController::pressBuyingListButton");
    [self.tabImageView setImage:[UIImage imageNamed:@"buying.png"]];
    self.tabImageView.tag = 0;
    
    self.indicatorImageView.image = [UIImage imageNamed:UI_IMAGE_ACTIVITY_NOTE_POST];
    [self updateTableView];
}

- (IBAction)pressSellingListButton:(id)sender {
    DLog(@"MyActivityViewController::pressBuyingListButton");
    [self.tabImageView setImage:[UIImage imageNamed:@"selling.png"]];
    self.tabImageView.tag = 1;
    
    self.indicatorImageView.image = [UIImage imageNamed:UI_IMAGE_ACTIVITY_NOTE_BROWSE];
    [self updateTableView];
}
////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)activityChanged:(id)sender {
    DLog(@"ActivityViewController::(IBAction)activityChanged");
    [self updateTableView];
}

- (void)reloadTable
{
    DLog(@"ActivityViewController::reloadTable");
    if ( [self isBuyingTabSelected]) {
        currentItems = [VariableStore sharedInstance].myBuyingListings;
    } else {
        currentItems = [VariableStore sharedInstance].mySellingListings;
    }
    
    //[self hideBackground];
    [self.tableView reloadData];
    //[self stopLoading];
    [self doneLoadingTableViewData];
    [self hideIndicator];
}

- (void)getBuyingItems:(NSDictionary *)dict
{
    DLog(@"ActivityViewController::getBuyingItems");
    Listing *listing = [[Listing alloc] initWithDictionary:dict];
    [VariableStore sharedInstance].myBuyingListings = [listing listItems];
    [self reloadTable];
}


- (void)getSellingItems:(NSDictionary *)dict
{
    DLog(@"ActivityViewController::getSellingItems");
    Offers *offers = [[Offers alloc] initWithDictionary:dict];
    [VariableStore sharedInstance].mySellingListings = [offers offers];
    [self reloadTable];
}

-(void)loadDataSource{
    if (![[self kassVS] isLoggedIn]) { 
        [self showBackground];
        return; 
    }
    
    if ( [self isBuyingTabSelected] ) {
        [self.currentUser getListings]; 
    } else {
        [self.currentUser getOffers];
    }
}

//- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    if ([segue.identifier isEqualToString:@"ActBuyingListToOffers"]) {
//    } else if ([segue.identifier isEqualToString:@"ActSellingListToMessageBuyer"]) {
//        DLog(@"ActivityViewController::prepareForSegue:ActSellingListToMessageBuyer");
//    } else if ([segue.identifier isEqualToString:@"ActBuyingListToPayView"]) {
//        DLog(@"ActivityViewController::prepareForSegue:ActBuyingListToPayView");
//    }
//}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reset];
    
    // table footer should be clear in order to see the arrow 
    self.tableView.tableFooterView = self.emptyImageView;
    
    // navigation bar background color
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:NAVIGATION_BAR_BACKGROUND_COLOR_RED green:NAVIGATION_BAR_BACKGROUND_COLOR_GREEN blue:NAVIGATION_BAR_BACKGROUND_COLOR_BLUE alpha:NAVIGATION_BAR_BACKGROUND_COLOR_ALPHA];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:UI_IMAGE_ACTIVITY_TITLE]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedFromOfferViewNotification:) 
                                                 name:OFFER_TO_PAY_VIEW_NOTIFICATION
                                               object:nil];
    
}

- (void) receivedFromOfferViewNotification:(NSNotification *) notification
{
    // [notification name] should always be OFFER_TO_PAY_VIEW_NOTIFICATION
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:OFFER_TO_PAY_VIEW_NOTIFICATION]) {
      Offer *offer = (Offer *)[notification object];       
        
      if (offer) {
          DLog (@"ActivityViewController::receivedFromOfferViewNotification! %@", offer);
          [self performSegueWithModelJson:offer.toJson:@"ActBuyingListToPayView":self];
      }
    }
}

- (void)viewDidUnload
{
    self.activitySegment = nil;
    [self setEmptyRecordsImageView:nil];
    [self setListingsTableView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OFFER_TO_PAY_VIEW_NOTIFICATION object:nil];
    [self setTableView:nil];
    [self setTabImageView:nil];
    [self setEmptyImageView:nil];
    [self setIndicatorImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self registerTableViewRefreshPuller:self.tableView:self.view];
  [self updateTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [self unregisterTableViewRefreshPuller];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    return [currentItems count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"activityCell";
    ListingTableCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ListingTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    UIImage *rowBackground = [UIImage imageNamed:UI_IMAGE_TABLE_CELL_BG];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:rowBackground];
    cell.backgroundView = imageView;
    
    UIImage *selectedBackground = [UIImage imageNamed:UI_IMAGE_TABLE_CELL_BG_PRESS];
    UIImageView *selectedImageView = [[UIImageView alloc] initWithImage:selectedBackground];
    cell.selectedBackgroundView = selectedImageView;
    
    int row = [indexPath row];
    for (UIView *view in cell.infoView.subviews) {
        [view removeFromSuperview];
    }

    // customize table cell listing view
    
    // set cell background for all
    [cell.infoView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:UI_IMAGE_ACTIVITY_PRICE_BG]]];
    
    // my buying list
    if ( [self isBuyingTabSelected] ) {
        ListItem *item = [currentItems objectAtIndex:row];
        cell.title.text = item.title;
        cell.subTitle.text = item.description;
        
        if (item.isExpired) {
            [ViewHelper buildListItemExpiredCell:item:cell];
        } else {
            // if user already accepted any offer, show pay now icon
            if (item.acceptedPrice != nil && item.acceptedPrice > 0) {
                [ViewHelper buildListItemPayNowCell:item:cell];            
            } else {
                int offersCount = [item.offers count];
                // if the listing has offers
                if (offersCount > 0) {
                    [ViewHelper buildListItemHasOffersCell:item:cell];                
                } else { // otherwise show pending states                               
                    [ViewHelper buildListItemNoOffersCell:item:cell];
                }
            }
        }
    } 
    
    // my selling list
    else {
        Offer *item = [currentItems objectAtIndex:row];
        cell.title.text = item.title;
        cell.subTitle.text = item.description;
        
        // if my offer has been accepted by buyer
        if ([item.state isEqualToString: OFFER_STATE_ACCEPTED] ) {
            [ViewHelper buildOfferAcceptedCell:item:cell];
        } else {
            // if the listing is expired
            if ([item isExpired]) {
                [ViewHelper buildOfferExpiredCell:item:cell];
            } 
            // if the offer is pending
            else {
                [ViewHelper buildOfferPendingCell:item:cell];
            }            
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Buying list segue
    if ( [self isBuyingTabSelected] ) {
        
        ListItem *item = [currentItems objectAtIndex:[indexPath row]];
        
        // if listing already has accepted offer, got to pay page
        if (item.isAccepted) {
          [self performSegueWithModelJson:item.acceptedOffer.toJson:@"ActBuyingListToPayView":self];
        } else {
          [self performSegueWithModelJson:item.toJson:@"ActBuyingListToOffers":self];
        }
    } 
    // Selling list segue
    else { 
      Offer *offer = [currentItems objectAtIndex:[indexPath row]];
      [self performSegueWithModelJson:offer.toJson:@"ActSellingListToMessageBuyer":self];
    }
    
}


@end
