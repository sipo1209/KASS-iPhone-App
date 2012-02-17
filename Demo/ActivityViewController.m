//
//  ActivityViewController.m
//  Demo
//
//  Created by zhicai on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityViewController.h"
#import "UIViewController+ActivityIndicate.h"


@implementation ActivityViewController
@synthesize emptyRecordsImageView = _emptyRecordsImageView;
@synthesize listingsTableView = _listingsTableView;

NSMutableArray *currentItems;

- (IBAction)activityChanged:(id)sender {
  DLog(@"ActivityViewController::(IBAction)activityChanged");
  if ( [[VariableStore sharedInstance].myBuyingListings count] == 0 || [[VariableStore sharedInstance].mySellingListings count] == 0) {
    [self setupArray];
  }else{
    [self reloadTable];
  }
}

- (void) accountLoadData
{
  DLog(@"ActivityViewController::accountLoadData");
  [self setupArray];
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

- (void)reloadTable
{
  DLog(@"ActivityViewController::reloadTable");
  if ( 0 == activitySegment.selectedSegmentIndex) {
    currentItems = [VariableStore sharedInstance].myBuyingListings;
  } else {
    currentItems = [VariableStore sharedInstance].mySellingListings;
  }
  if (self.emptyRecordsImageView && [currentItems count] > 0) {
    [self.emptyRecordsImageView removeFromSuperview];
    self.emptyRecordsImageView = nil;
  }
  
  [self.tableView reloadData];
  [self stopLoading];
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

-(void)setupArray{
  [self showLoadingIndicator];
  VariableStore.sharedInstance.user.delegate = self;
  if ( 0 == activitySegment.selectedSegmentIndex) {
    [VariableStore.sharedInstance.user getListings]; 
  } else {
    [VariableStore.sharedInstance.user getOffers];
  }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ActBuyingListToOffers"]) {
        UINavigationController *nc = [segue destinationViewController];
        ItemViewController *ivc = (ItemViewController *)nc.topViewController;
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        int row = [path row];
        ListItem *item = [currentItems objectAtIndex:row];
        ivc.currentItem = item;
      
    } else if ([segue.identifier isEqualToString:@"ActSellingListToMessageBuyer"]) {
      DLog(@"ActivityViewController::prepareForSegue:ActSellingListToMessageBuyer");
      BrowseItemViewController *bvc = [segue destinationViewController];
      
      NSIndexPath *path = [self.tableView indexPathForSelectedRow];
      int row = [path row];
      bvc.currentOffer = [currentItems objectAtIndex:row];
        
    } else if ([segue.identifier isEqualToString:@"ActBuyingListToPayView"]) {
        
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

//#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.navigationController.navigationBar.tintColor = [UIColor brownColor];  
  if ( ![VariableStore sharedInstance].user.delegate ) {
    [VariableStore sharedInstance].user.delegate = self;
  }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    activitySegment = nil;
    [self setEmptyRecordsImageView:nil];
    [self setListingsTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
//  DLog(@"VariableStore=%@,userid=%@",[VariableStore sharedInstance], [VariableStore sharedInstance].user.userId);
    if ([[VariableStore sharedInstance] isLoggedIn]) {        
        [self.emptyRecordsImageView removeFromSuperview];
        self.emptyRecordsImageView = nil;
        [self reloadTable];
    } else {
        if (self.emptyRecordsImageView == nil || self.emptyRecordsImageView.image == nil) {
            self.emptyRecordsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
            [self.view addSubview:self.emptyRecordsImageView];
        }
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    
    UIImage *rowBackground = [UIImage imageNamed:@"middleRow.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:rowBackground];
    cell.backgroundView = imageView;
    
    UIImage *selectedBackground = [UIImage imageNamed:@"middleRowSelected.png"];
    UIImageView *selectedImageView = [[UIImageView alloc] initWithImage:selectedBackground];
    cell.selectedBackgroundView = selectedImageView;
    
    int row = [indexPath row];
    for (UIView *view in cell.infoView.subviews) {
        [view removeFromSuperview];
    }
    // cell.infoView = [[UIView alloc] initWithFrame:CGRectMake(238, 6, 76, 76)];
    // customize table cell listing view
    
    // my buying list
    if ( 0 == activitySegment.selectedSegmentIndex ) {
        ListItem *item = [currentItems objectAtIndex:row];
        cell.title.text = item.title;
        cell.subTitle.text = item.description;
        //item.acceptedPrice = [NSDecimalNumber decimalNumberWithDecimal:
        //                 [[NSNumber numberWithDouble:50] decimalValue]];
        // if user already accepted any offer, show pay now icon
        if (item.acceptedPrice != nil && item.acceptedPrice > 0) {
        
            UIButton *buttonPayNow = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            buttonPayNow.frame = CGRectMake(2, 2, 70.0, 20.0);
            [buttonPayNow setTitle:UI_BUTTON_LABEL_PAY_NOW forState:UIControlStateNormal];
            [buttonPayNow setTitleColor: [UIColor orangeColor] forState: UIControlStateNormal];
            [cell.infoView addSubview:buttonPayNow];     
            
            UILabel *labelAskPrice = [[UILabel alloc] init];
            
            if (item.askPrice != nil && item.askPrice > 0) {
                [labelAskPrice setText:[item.askPrice stringValue]];
            }
            
            [labelAskPrice setTextColor:[UIColor blackColor]];
            labelAskPrice.frame = CGRectMake(cell.infoView.frame.size.width/2 - 5, cell.infoView.frame.size.height/2, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
            labelAskPrice.textAlignment = UITextAlignmentCenter;
            [labelAskPrice sizeToFit];
            [cell.infoView addSubview:labelAskPrice];             
        } else {
            int offersCount = [item.offers count];
            // if the listing has offers
            if (offersCount > 0) {
                UILabel *labelNeedsReview = [[UILabel alloc] init];
                [labelNeedsReview setText:UI_LABEL_NEEDS_REVIEW];
                [labelNeedsReview setTextColor:[UIColor blackColor]];
                labelNeedsReview.frame = CGRectMake(2, 2, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
                labelNeedsReview.textAlignment = UITextAlignmentCenter;
                [labelNeedsReview sizeToFit];
                [cell.infoView addSubview:labelNeedsReview];    
                
                UILabel *labelOffersCount = [[UILabel alloc] init];
                [labelOffersCount setText:[[NSString alloc] initWithFormat:@"%d %@", offersCount, UI_LABEL_OFFER]];
                [labelOffersCount setTextColor:[UIColor blackColor]];
                labelOffersCount.frame = CGRectMake(cell.infoView.frame.size.width/2 - 10, cell.infoView.frame.size.height/2 - 10, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
                labelOffersCount.textAlignment = UITextAlignmentCenter;
                [labelOffersCount sizeToFit];
                [cell.infoView addSubview:labelOffersCount];  
                
            } else { // otherwise show pending states                               
                UILabel *labelWaiting = [[UILabel alloc] init];
                [labelWaiting setText:UI_LABEL_WAITING_FOR_OFFER];
                [labelWaiting setTextColor:[UIColor blackColor]];
                
                DLog(@"x: %f, y: %f, w: %f, h: %f", cell.infoView.frame.origin.x, cell.infoView.frame.origin.y, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
                
                labelWaiting.frame = CGRectMake(2, 2, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
                labelWaiting.textAlignment = UITextAlignmentCenter;
                [labelWaiting sizeToFit];
                //labelWaiting.center = CGPointMake(cell.infoView.frame.size.width/2, 2);
                [cell.infoView addSubview:labelWaiting]; 
                
                UILabel *labelAskPrice = [[UILabel alloc] init];
                if (item.askPrice != nil && item.askPrice > 0) {
                    [labelAskPrice setText:[item.askPrice stringValue]];
                }
                [labelAskPrice setTextColor:[UIColor blackColor]];
                labelAskPrice.frame = CGRectMake(cell.infoView.frame.size.width/2 - 5, cell.infoView.frame.size.height/2 - 10, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
                labelAskPrice.textAlignment = UITextAlignmentCenter;
                //labelAskPrice.center = CGPointMake(cell.infoView.frame.size.width/2, cell.infoView.frame.size.height/2 + 3);
                [labelAskPrice sizeToFit];
                [cell.infoView addSubview:labelAskPrice]; 
                
                //TODO
                UILabel *labelExpiredDate = [[UILabel alloc] init];
                [labelExpiredDate setText:@"3天到期"];
                [labelExpiredDate setTextColor:[UIColor blackColor]];
                labelExpiredDate.frame = CGRectMake(2, cell.infoView.frame.size.height/2 + 12, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
                labelExpiredDate.textAlignment = UITextAlignmentCenter;
                //labelExpiredDate.center = CGPointMake(cell.infoView.frame.size.width/2, cell.infoView.frame.size.height/2 + 3);
                [labelExpiredDate sizeToFit];
                [cell.infoView addSubview:labelExpiredDate]; 
            }
        }
    } 
    
    // my selling list
    else {
        Offer *item = [currentItems objectAtIndex:row];
        cell.title.text = item.title;
        cell.subTitle.text = item.description;

        
        // TODO
        // if my offer has been accepted by buyer
        DLog(@"Offer State: %@", item.state);
        if ([item.state isEqualToString: OFFER_STATE_ACCEPTED] ) {
            UILabel *labelAccepted = [[UILabel alloc] init];
            [labelAccepted setText:UI_LABEL_ACCEPTED];
            [labelAccepted setTextColor:[UIColor blackColor]];
            
            labelAccepted.frame = CGRectMake(2, 2, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
            labelAccepted.textAlignment = UITextAlignmentCenter;
            [labelAccepted sizeToFit];
            //labelAccepted.center = CGPointMake(cell.infoView.frame.size.width/2, 2);
            [cell.infoView addSubview:labelAccepted]; 
            
            UILabel *labelAskPrice = [[UILabel alloc] init];
            
            if (item.price != nil && item.price > 0) {
                [labelAskPrice setText:[item.price stringValue]];
            }
            
            [labelAskPrice setTextColor:[UIColor blackColor]];
            labelAskPrice.frame = CGRectMake(cell.infoView.frame.size.width/2 - 5, cell.infoView.frame.size.height/2 - 10, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
            labelAskPrice.textAlignment = UITextAlignmentCenter;
            //labelAskPrice.center = CGPointMake(cell.infoView.frame.size.width/2, cell.infoView.frame.size.height/2 + 3);
            [labelAskPrice sizeToFit];
            [cell.infoView addSubview:labelAskPrice]; 
            
            //TODO
            UILabel *labelYouOffered = [[UILabel alloc] init];
            [labelYouOffered setText:UI_LABEL_YOU_OFFERED];
            [labelYouOffered setTextColor:[UIColor blackColor]];
            labelYouOffered.frame = CGRectMake(2, cell.infoView.frame.size.height/2 + 12, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
            labelYouOffered.textAlignment = UITextAlignmentCenter;
            //labelExpiredDate.center = CGPointMake(cell.infoView.frame.size.width/2, cell.infoView.frame.size.height/2 + 3);
            [labelYouOffered sizeToFit];
            [cell.infoView addSubview:labelYouOffered]; 
        } else {
            // TODO
            // if the listing is expired
            if (1 != 1) {
                UILabel *labelExpired = [[UILabel alloc] init];
                [labelExpired setText:UI_LABEL_EXPIRED];
                [labelExpired setTextColor:[UIColor blackColor]];
                
                labelExpired.frame = CGRectMake(2, 2, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
                labelExpired.textAlignment = UITextAlignmentCenter;
                [labelExpired sizeToFit];
                //labelWaiting.center = CGPointMake(cell.infoView.frame.size.width/2, 2);
                [cell.infoView addSubview:labelExpired]; 
                
                UILabel *labelAskPrice = [[UILabel alloc] init];
                
                if (item.price != nil && item.price > 0) {
                    [labelAskPrice setText:[item.price stringValue]];
                }
                
                [labelAskPrice setTextColor:[UIColor blackColor]];
                labelAskPrice.frame = CGRectMake(cell.infoView.frame.size.width/2 - 5, cell.infoView.frame.size.height/2 - 10, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
                labelAskPrice.textAlignment = UITextAlignmentCenter;
                [labelAskPrice sizeToFit];
                [cell.infoView addSubview:labelAskPrice]; 
                
                //TODO
                UILabel *labelYouOffered = [[UILabel alloc] init];
                [labelYouOffered setText:UI_LABEL_YOU_OFFERED];
                [labelYouOffered setTextColor:[UIColor blackColor]];
                labelYouOffered.frame = CGRectMake(2, cell.infoView.frame.size.height/2 + 12, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
                labelYouOffered.textAlignment = UITextAlignmentCenter;
                [labelYouOffered sizeToFit];
                [cell.infoView addSubview:labelYouOffered]; 
            } 
            // if the offer is pending
            else {
                UILabel *labelPending = [[UILabel alloc] init];
                [labelPending setText:UI_LABEL_OFFER_PENDING];
                [labelPending setTextColor:[UIColor blackColor]];
                
                labelPending.frame = CGRectMake(2, 2, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
                labelPending.textAlignment = UITextAlignmentCenter;
                [labelPending sizeToFit];
                //labelPending.center = CGPointMake(cell.infoView.frame.size.width/2, 2);
                [cell.infoView addSubview:labelPending]; 
                
                UILabel *labelAskPrice = [[UILabel alloc] init];
                
                if (item.price != nil && item.price > 0) {
                    [labelAskPrice setText:[item.price stringValue]];
                }
                
                [labelAskPrice setTextColor:[UIColor blackColor]];
                labelAskPrice.frame = CGRectMake(cell.infoView.frame.size.width/2 - 5, cell.infoView.frame.size.height/2 - 10, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
                labelAskPrice.textAlignment = UITextAlignmentCenter;
                [labelAskPrice sizeToFit];
                [cell.infoView addSubview:labelAskPrice]; 

                UILabel *labelOfferer = [[UILabel alloc] init];
                
                [labelOfferer setText:([item.state isEqualToString: OFFER_STATE_REJECTED] ? UI_LABEL_BUYER_OFFERED : UI_LABEL_YOU_OFFERED)];
                
                [labelOfferer setTextColor:[UIColor blackColor]];
                labelOfferer.frame = CGRectMake(2, cell.infoView.frame.size.height/2 + 12, cell.infoView.frame.size.width - 2, cell.infoView.frame.size.height / 2 - 5);
                labelOfferer.textAlignment = UITextAlignmentCenter;
                [labelOfferer sizeToFit];
                [cell.infoView addSubview:labelOfferer]; 
            }
            
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
    // <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    // Buying list segue
    if ( 0 == activitySegment.selectedSegmentIndex) {
        int row = [indexPath row];
        ListItem *item = [currentItems objectAtIndex:row];
//        item.acceptedPrice = [NSDecimalNumber decimalNumberWithDecimal:
//                        [[NSNumber numberWithDouble:50] decimalValue]];
        // if listing already has accepted offer, got to pay page
        if (item.acceptedPrice != nil && item.acceptedPrice > 0) {
            [self performSegueWithIdentifier:@"ActBuyingListToPayView" sender:self];
        } else {
            [self performSegueWithIdentifier:@"ActBuyingListToOffers" sender:self];
        }
    } 
    // Selling list segue
    else {
        [self performSegueWithIdentifier:@"ActSellingListToMessageBuyer" sender:self];
    }
    
}

// Reloading data
- (void)refresh {
    [self performSelector:@selector(setupArray) withObject:nil afterDelay:2.0];
}

@end
