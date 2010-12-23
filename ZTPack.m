//
//  ZTPack.m
//  zootoolapp
//
//  Created by nico on 7/10/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTPack.h"


@implementation ZTPack

@synthesize pid, name, iconid;

- (void) dealloc
{
  self.pid = nil;
  self.name = nil;
  self.iconid = nil;
  [super dealloc];
}

- (id) initWithDictionary:(NSDictionary*)dict
{
  if (self = [super init])
  {
    self.pid = [[dict objectForKey:@"id"] description];
    self.name = [[dict objectForKey:@"name"] description];
    self.iconid = [[dict objectForKey:@"icon"] description];
  }
  return self;
}

- (NSDictionary*) dictionary
{
  NSMutableDictionary* ret = [NSMutableDictionary dictionary];
  if (self.pid) [ret setObject:self.pid forKey:@"id"];
  if (self.name) [ret setObject:self.name forKey:@"name"];
  if (self.iconid) [ret setObject:self.iconid forKey:@"icon"]; 
  return ret;
}

- (NSString*) description
{
  return [[self dictionary] description];
}

@end
