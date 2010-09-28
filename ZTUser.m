//
//  ZTUser.m
//  zootoolapp
//
//  Created by nico on 23/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTUser.h"


@implementation ZTUser

@synthesize username, email, website, avatar;

- (void) dealloc
{
  self.username = nil;
  self.email = nil;
  self.website = nil;
  self.avatar = nil;
  [super dealloc];
}

- (id) initWithDictionary:(NSDictionary*)dict
{
  if (self = [super init])
  {
    self.username = [[dict objectForKey:@"username"] description];
    self.email = [[dict objectForKey:@"email"] description];
    self.website = [NSURL URLWithString:[[dict objectForKey:@"website"] description]];
    self.avatar = [NSURL URLWithString:[[dict objectForKey:@"avatar"] description]];
  }
  return self;
}

- (NSDictionary*) dictionary
{
  NSMutableDictionary* ret = [NSMutableDictionary dictionary];
  if (self.username) [ret setObject:self.username forKey:@"username"];
  if (self.email) [ret setObject:self.email forKey:@"email"];
  if (self.website) [ret setObject:[self.website absoluteString] forKey:@"website"];
  if (self.avatar) [ret setObject:[self.avatar absoluteString] forKey:@"avatar"];
  return ret;
}

- (NSString*) description
{
  return [[self dictionary] description];
}

@end
