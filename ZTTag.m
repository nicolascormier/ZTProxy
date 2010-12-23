//
//  ZTTag.m
//  zootoolapp
//
//  Created by nico on 6/10/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTTag.h"


@implementation ZTTag

@synthesize tid, name, recent, fav, suggestion;

- (void) dealloc
{
  self.recent = nil;
  self.fav = nil;
  self.suggestion = nil;
  self.tid = nil;
  self.name = nil;
  [super dealloc];
}

- (id) initWithDictionary:(NSDictionary*)dict
{
  if (self = [super init])
  {
    NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

    self.tid = [[dict objectForKey:@"id"] description];
    self.name = [[dict objectForKey:@"tag"] description];
    self.recent = [formatter numberFromString:[[dict objectForKey:@"recent"] description]];
    self.fav = [formatter numberFromString:[[dict objectForKey:@"fav"] description]];
    self.suggestion = [formatter numberFromString:[[dict objectForKey:@"suggestion"] description]];
  }
  return self;
}

- (NSDictionary*) dictionary
{
  NSMutableDictionary* ret = [NSMutableDictionary dictionary];
  if (self.tid) [ret setObject:self.tid forKey:@"id"];
  if (self.name) [ret setObject:self.name forKey:@"tag"];
  if (self.recent) [ret setObject:[self.recent stringValue] forKey:@"recent"];                      
  if (self.fav) [ret setObject:[self.fav stringValue] forKey:@"fav"];                      
  if (self.suggestion) [ret setObject:[self.suggestion stringValue] forKey:@"suggestion"];                      
  return ret;
}

- (NSString*) description
{
  return [[self dictionary] description];
}

@end
