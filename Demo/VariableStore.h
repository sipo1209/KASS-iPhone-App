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
#import "KassApp.h"
#import "Settings.h"
#import "Alert.h"

@interface VariableStore : NSObject 

// Global variables
// Current Posting Process Cache
@property (strong, nonatomic) ListItem *currentPostingItem;
// Current Add Alert Process Cache
@property (strong, nonatomic) Alert *currentAddAlert;

//settings
@property (strong, nonatomic) Settings *settings;

#pragma mark - Testing Array -
@property (strong, nonatomic) NSMutableArray *allListings;
@property (strong, nonatomic) NSMutableArray *myBuyingListings;
@property (strong, nonatomic) NSMutableArray *mySellingListings;

@property (strong, nonatomic) NSMutableArray *recentBrowseListings;
@property (strong, nonatomic) NSMutableArray *nearBrowseListings;
@property (strong, nonatomic) NSMutableArray *priceBrowseListings;

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) LocateMeManager *locateMeManager;
@property (strong, nonatomic) KassApp *kassApp;

@property (strong, nonatomic) NSMutableDictionary *modelDict;
@property (strong, nonatomic) NSDictionary *modelJson;

@property (strong, nonatomic) UITabBarController *mainTabBar;

@property (nonatomic,assign) id<AccountActivityDelegate> currentViewControllerDelegate;

@property (strong, nonatomic) ListItem *itemToShowOnMap;
@property (strong, nonatomic) NSString *userToShowId;
@property (strong, nonatomic) NSMutableArray *itemClassAndIdToShow;
@property (strong, nonatomic) NSDictionary *remoteNotification;
@property (strong, nonatomic) UIResponder *appDelegate;

@property NSInteger priceToModify;
@property Boolean isAutoLogin;

+ (VariableStore *) sharedInstance;
- (void) clearCurrentPostingItem;
- (void) clearCurrentAddAlert;
- (void)loadSettings:(id<KassAppDelegate>)delegate;
- (void)storeSettings:(NSDictionary *)dict;
- (void)loadAndStoreSettings:(id<KassAppDelegate>)delegate;
- (void) appendPostingItemToListings:(NSDictionary *)dict;
- (void)resetActivityListings;
- (NSMutableDictionary *) getDefaultCriteria;
- (void)assignItemToShow:(ActiveModel *)am;

- (BOOL) isCurrentUser:(NSString *)userId;
- (BOOL) isLoggedIn;
- (BOOL) signInAccount:(NSString *)email:(NSString *)password;
- (BOOL) signInWeibo;
- (BOOL) signOut;
- (BOOL) signUpAccount:(NSDictionary *)userInfo;
- (BOOL) loginIfPreviouslyLoggedIn;
- (CLLocation *)location;

- (BOOL) signInRenren;

- (void) getAuth;
- (void) addToModelDict:(NSString *)controller:(NSDictionary *)model;
- (NSDictionary *) getModelDict:(NSString *)controller:(NSString *)modelName;
- (void) removeFromModelDict:(NSString *)controller;

@end
