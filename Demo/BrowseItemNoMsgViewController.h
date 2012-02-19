//
//  BrowseItemNoMsgViewController.h
//  Demo
//
//  Created by zhicai on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "VariableStore.h"
#import "BrowseTableViewController.h"
#import "UIResponder+VariableStore.h"

@interface BrowseItemNoMsgViewController : UIViewController <UIActionSheetDelegate, AccountActivityDelegate>

@property (strong, nonatomic) ListItem *currentItem;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navigationButton;
@property (strong, nonatomic) IBOutlet UILabel *listingTitle;
@property (strong, nonatomic) IBOutlet UILabel *listingDescription;
@property (strong, nonatomic) IBOutlet UILabel *listingPrice;
@property (strong, nonatomic) IBOutlet UILabel *listingDate;
@property (strong, nonatomic) IBOutlet UILabel *offerPrice;

- (IBAction)navigationButtonAction:(id)sender;
@end
