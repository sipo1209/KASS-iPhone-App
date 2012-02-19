//
//  VariableStore.h
//  Demo
//
//  Created by zhicai on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  WARNING: This is a class storing global variables
//  using the Singleton design pattern. 

#import <Foundation/Foundation.h>
#import "ListItem.h"
#import "User.h"
#import "LocateMeManager.h"

@interface VariableStore : NSObject 

// Global variables
// Current Posting Process Cache
@property (strong, nonatomic) ListItem *currentPostingItem;
@property (strong, nonatomic) NSDictionary *expiredTime;

#pragma mark - Testing Array -
@property (strong, nonatomic) NSMutableArray *allListings;
@property (strong, nonatomic) NSMutableArray *myBuyingListings;
@property (strong, nonatomic) NSMutableArray *mySellingListings;

@property (strong, nonatomic) NSMutableArray *recentBrowseListings;
@property (strong, nonatomic) NSMutableArray *nearBrowseListings;
@property (strong, nonatomic) NSMutableArray *priceBrowseListings;

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) LocateMeManager *locateMeManager;

@property (strong, nonatomic) NSMutableDictionary *modelDict;

+ (VariableStore *) sharedInstance;
- (void) clearCurrentPostingItem;
- (void) initExpiredTime;
- (void) initListingsData;

- (BOOL) isLoggedIn;
- (BOOL) signInAccount:(NSString *)email:(NSString *)password;
- (BOOL) signInWeibo;
- (BOOL) signOut;
- (CLLocation *)location;

- (void) addToModelDict:(NSString *)controller:(NSDictionary *)model;
- (NSDictionary *) getModelDict:(NSString *)controller:(NSString *)modelName;
- (void) removeFromModelDict:(NSString *)controller;

@end
