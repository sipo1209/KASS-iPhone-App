//
//  UIResponder+VariableStore.m
//  Demo
//
//  Created by Qi He on 12-2-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIResponder+VariableStore.h"

@implementation UIResponder (VariableStore)

- (VariableStore *) kassVS
{
  return VariableStore.sharedInstance;
}

- (void) kassAddToModelDict:(NSString *)controller:(NSDictionary *)model
{
  DLog(@"UIResponder+VariableStore::kassAddToModelDict:controller=%@", controller);
  [[self kassVS] addToModelDict:controller:model];
}

- (NSDictionary *) kassGetModelDict:(NSString *)modelName
{
  DLog(@"UIResponder+VariableStore::kassGetModelDict:controller=%@", NSStringFromClass(self.class));
  return [[self kassVS] getModelDict:NSStringFromClass(self.class):modelName];
}

- (void) kassRemoveFromModelDict
{
  [[self kassVS] removeFromModelDict:NSStringFromClass(self.class)];
}

- (User *) currentUser
{
//  DLog(@"UIResponder+VariableStore::currentUser:delegate=%@", NSStringFromClass(self.class));
  [self kassVS].user.delegate = self;
  return [self kassVS].user;
}

- (KassApp *) kassApp
{
//  DLog(@"UIResponder+VariableStore::kassApp:delegate=%@", NSStringFromClass(self.class));
  [self kassVS].kassApp.delegate = self;
  return [self kassVS].kassApp;
}

- (ListItem *) postingItem
{
  return [self kassVS].currentPostingItem;
}

- (Settings *) settings
{
  return [self kassVS].settings;
}

@end
