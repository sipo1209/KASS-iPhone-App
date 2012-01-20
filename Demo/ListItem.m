//
//  ListItem.m
//  Demo
//
//  Created by zhicai on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ListItem.h"

@implementation ListItem

@synthesize title = _title;
@synthesize description = _description;
@synthesize needItBy = _needItBy;
@synthesize askPrice = _askPrice;
@synthesize picFileName = _picFileName;

- (id) initWithDictionary:(NSDictionary *) theDictionary
{
  if (self = [super init]) {
    _title        = [theDictionary objectForKey:@"title"];
    _description  = [theDictionary objectForKey:@"description"];
    _askPrice     = [NSDecimalNumber decimalNumberWithDecimal:[[theDictionary objectForKey:@"price"] decimalValue]];
  }
  return self;
}

@end
