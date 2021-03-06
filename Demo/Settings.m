//
//  Settings.m
//  Demo
//
//  Created by Qi He on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"
#import "Constants.h"

@implementation Settings

@synthesize expiredTimeDict = _expiredTimeDict;
@synthesize durationToServerDic = _durationToServerDic;
@synthesize postTemplatesDict = _postTemplatesDict;
@synthesize messageTypesDict = _messageTypesDict;
@synthesize weiboShareDict = _weiboShareDict;
@synthesize siteDict = _siteDict;
@synthesize alertKeywordsServiceArray = _alertKeywordsServiceArray;
@synthesize alertKeywordsGoodsArray = _alertKeywordsGoodsArray;
@synthesize default_per_page = _default_per_page;

- (id) initWithDictionary:(NSDictionary *)dict
{
  if (self = [super init]) {
    // save to variable store
    self.weiboShareDict    = [dict objectForKey:@"weibo"];
    self.siteDict          = [dict objectForKey:@"site"];
    NSDictionary *settings = [dict objectForKey:@"settings"];
    
    NSDictionary *duration = [settings objectForKey:@"duration"];
    NSDictionary *secToString = [duration objectForKey:@"sec_string"];
    NSDictionary *secToText   = [duration objectForKey:@"sec_text"];
    NSDictionary *alertKeywords = [settings objectForKey:@"alert_keywords"];
    
    self.durationToServerDic = [[NSMutableDictionary alloc] init];
    self.expiredTimeDict     = [[NSMutableDictionary alloc] init];
    
    for (id key in secToString) {
      [self.durationToServerDic setObject:[secToString objectForKey:key] forKey:[NSNumber numberWithInt:[key intValue]]];
    }
    
    for (id key in secToText) {
      [self.expiredTimeDict setObject:[NSNumber numberWithInt:[key intValue]] forKey:[secToText objectForKey:key]];
    }
    
    self.postTemplatesDict = [settings objectForKey:@"post_templates"];
    self.messageTypesDict  = [settings objectForKey:@"message_types"];
      
    if (alertKeywords.count > 0) {
      self.alertKeywordsServiceArray = [alertKeywords objectForKey:@"service"];
      self.alertKeywordsGoodsArray = [alertKeywords objectForKey:@"goods"];
    }
    
    //pagination
    NSDictionary *pagination = [dict objectForKey:@"pagination"];
    _default_per_page  = (int)[[pagination objectForKey:@"default_per_page"] intValue];
    if ( !_default_per_page ) { _default_per_page = DEFAULT_PER_PAGE; }
  }
  return self;
}

- (NSString *) getTextForMessageType:(NSString *)type
{
  return [self.messageTypesDict objectForKey:type];
}

@end
