//
//  PostFlowSetDateViewController.m
//  Demo
//
//  Created by zhicai on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PostFlowSetDateViewController.h"

@implementation PostFlowSetDateViewController
@synthesize PostDurationPicker = _PostDurationPicker;
@synthesize PostDurationLabel = _PostDurationLabel;
@synthesize PostFlowSegment = _PostFlowSegment;
NSArray *arrayTimePicker;

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

- (void)loadCurrentPostingData
{
    if ([VariableStore sharedInstance].currentPostingItem.postDuration) {
        NSArray *keys = [[VariableStore sharedInstance].expiredTime 
                         allKeysForObject:[VariableStore sharedInstance].currentPostingItem.postDuration];
        if (keys) {
            NSString *selectedItem = [keys objectAtIndex:0];
            if ([selectedItem length] != 0) {
                [self.PostDurationPicker selectRow:[arrayTimePicker indexOfObject:selectedItem] inComponent:0 animated:NO];
                self.PostDurationLabel.text = selectedItem;
            }
            //self.PostDurationPicker sele
        }
        //self.priceTextField.text = [NSString stringWithFormat:@"%@", [VariableStore sharedInstance].currentPostingItem.askPrice];
    }
}

- (void)saveCurrentPostingData
{
    if (self.PostDurationLabel.text) {
        [VariableStore sharedInstance].currentPostingItem.postDuration = [[VariableStore sharedInstance].expiredTime objectForKey:self.PostDurationLabel.text];
    }
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
    arrayTimePicker = [[VariableStore sharedInstance].expiredTime keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        return [(NSNumber *)obj1 compare:(NSNumber *)obj2];
    }];
    [self loadCurrentPostingData];
}

- (void)viewDidUnload
{
    [self setPostDurationPicker:nil];
    [self setPostDurationLabel:nil];
    [self setPostFlowSegment:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveCurrentPostingData];
}

#pragma mark -
#pragma mark Picker View Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	
	return [arrayTimePicker count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	return [arrayTimePicker objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.PostDurationLabel.text = [arrayTimePicker objectAtIndex:row];
	NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayTimePicker objectAtIndex:row], row);
}

@end
