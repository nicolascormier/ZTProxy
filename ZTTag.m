//
//  ZTTag.m
//  zootoolapp
//
//  Created by nico on 6/10/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTTag.h"


@implementation ZTTag

@synthesize tid, name;

- (void) dealloc
{
  self.tid = nil;
  self.name = nil;
  [super dealloc];
}

- (id) initWithDictionary:(NSDictionary*)dict
{
  if (self = [super init])
  {
    self.tid = [[dict objectForKey:@"id"] description];
    self.name = [[dict objectForKey:@"tag"] description];
  }
  return self;
}

- (NSDictionary*) dictionary
{
  NSMutableDictionary* ret = [NSMutableDictionary dictionary];
  if (self.tid) [ret setObject:self.tid forKey:@"id"];
  if (self.name) [ret setObject:self.name forKey:@"tag"];
  return ret;
}

- (NSString*) description
{
  return [[self dictionary] description];
}

@end
