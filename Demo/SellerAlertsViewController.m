//
//  SellerAlertsViewController.m
//  Demo
//
//  Created by Wesley Wang on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SellerAlertsViewController.h"
#import "UIResponder+VariableStore.h"
#import "SellerAlertsListingsViewController.h"

@implementation SellerAlertsViewController
@synthesize rightButton = _rightButton;
@synthesize leftButton = _leftButton;
@synthesize alertsTableView = _alertsTableView;
@synthesize alerts = _alerts;
@synthesize addAlertLabel = _addAlertLabel;
@synthesize alertTableFooter = _alertTableFooter;

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

- (void)customViewLoad
{
    // navigation bar background color
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:NAVIGATION_BAR_BACKGROUND_COLOR_RED green:NAVIGATION_BAR_BACKGROUND_COLOR_GREEN blue:NAVIGATION_BAR_BACKGROUND_COLOR_BLUE alpha:NAVIGATION_BAR_BACKGROUND_COLOR_ALPHA];
    [ViewHelper buildBackButton:self.leftButton];
    [ViewHelper buildEditButton:self.rightButton];
}

- (void)refreshViewAfterLoadData
{
    if (self.alerts.count <= 0) {
        self.addAlertLabel.hidden = NO;
        self.alertTableFooter.hidden = YES;
        self.alertsTableView.tableFooterView = self.alertTableFooter;
    } else {
        self.addAlertLabel.hidden = YES;
        self.alertTableFooter.hidden = NO;
        self.alertsTableView.tableFooterView = self.alertTableFooter;
    }
    [self.alertsTableView reloadData];
}

- (void)accountDidGetAlerts:(NSDictionary *)dict;
{
    DLog(@"SellerAlertsViewController::accountDidGetAlerts:dict%@", dict);
    self.alerts = [dict objectForKey:@"alerts"];

    if (self.alerts.count <= 0) {
        [self performSegueWithIdentifier:@"AlertTableToAddAlertView" sender:self];
    }
    [self refreshViewAfterLoadData];
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
    [self customViewLoad];
}

- (void)viewDidUnload
{
    [self setLeftButton:nil];
    [self setRightButton:nil];
    [self setAlertsTableView:nil];
    [self setAddAlertLabel:nil];
    [self setAlertTableFooter:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.currentUser getAlerts];
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
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
    return self.alerts.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myAlertTableCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSDictionary *alert = [self.alerts objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [alert objectForKey:@"query"];
    cell.detailTextLabel.text = [@"方圆" stringByAppendingFormat:@"%@ %@ %@", [[alert objectForKey:@"radius"] stringValue], @"公里 － ", @"浙江 杭州"];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"SellerAlertsToListingsView" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SellerAlertsToListingsView"]) {
        DLog(@"SellerAlertsViewController::prepareForSegue");
        SellerAlertsListingsViewController *lc = segue.destinationViewController;    
        lc.alertId = [[self.alerts objectAtIndex:self.alertsTableView.indexPathForSelectedRow.row] objectForKey:@"id"];
        lc.query = [[self.alerts objectAtIndex:self.alertsTableView.indexPathForSelectedRow.row] objectForKey:@"query"];
        DLog(@"SellerAlertsViewController Segue Data: %@", lc.alertId);
    }
}

- (IBAction)leftButtonAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)rightButtonAction:(id)sender {
}

- (IBAction)AddAlertButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"AlertTableToAddAlertView" sender:self];
}
@end