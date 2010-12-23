//
//  ZTUser.m
//  zootoolapp
//
//  Created by nico on 23/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTUser.h"


@implementation ZTUser

@synthesize username, email, location, bio, website, avatar, profile, tinyurl, elsewhere, added;
@synthesize name, entries, following, followers;

- (void) dealloc
{
  self.username = nil;
  self.name = nil;  
  self.email = nil;
  self.location = nil; 
  self.bio = nil;  
  self.website = nil;
  self.avatar = nil;
  self.profile = nil;
  self.tinyurl = nil;  
  self.elsewhere = nil;
  self.added = nil;
  self.entries = nil;
  self.following = nil;
  self.followers = nil;
  [super dealloc];
}

- (id) initWithDictionary:(NSDictionary*)dict
{
  if (self = [super init])
  {
    NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];    
    self.username = [[dict objectForKey:@"username"] description];
    self.name = [[dict objectForKey:@"name"] description];
    self.email = [[dict objectForKey:@"email"] description];
    self.location = [[dict objectForKey:@"location"] description]; 
    self.bio = [[dict objectForKey:@"bio"] description]; 
    self.website = [NSURL URLWithString:[[dict objectForKey:@"website"] description]];
    self.avatar = [NSURL URLWithString:[[dict objectForKey:@"avatar"] description]];
    self.profile = [NSURL URLWithString:[[dict objectForKey:@"profile"] description]];
    self.tinyurl = [NSURL URLWithString:[[dict objectForKey:@"tinyurl"] description]];
    self.elsewhere = [dict objectForKey:@"elsewhere"];
    double unixTimestamp = [[formatter numberFromString:[[dict objectForKey:@"added"] description]] doubleValue]; 
    self.added = [NSDate dateWithTimeIntervalSince1970:unixTimestamp];    
    self.entries = [formatter numberFromString:[[dict objectForKey:@"entries"] description]];
    self.following = [formatter numberFromString:[[dict objectForKey:@"following"] description]];
    self.followers = [formatter numberFromString:[[dict objectForKey:@"followers"] description]];
  }
  return self;
}

- (NSDictionary*) dictionary
{
  NSMutableDictionary* ret = [NSMutableDictionary dictionary];
  if (self.username) [ret setObject:self.username forKey:@"username"];
  if (self.name) [ret setObject:self.name forKey:@"name"];
  if (self.email) [ret setObject:self.email forKey:@"email"];
  if (self.location) [ret setObject:self.location forKey:@"location"];  
  if (self.bio) [ret setObject:self.bio forKey:@"bio"];  
  if (self.website) [ret setObject:[self.website absoluteString] forKey:@"website"];
  if (self.avatar) [ret setObject:[self.avatar absoluteString] forKey:@"avatar"];
  if (self.profile) [ret setObject:[self.profile absoluteString] forKey:@"profile"]; 
  if (self.tinyurl) [ret setObject:[self.tinyurl absoluteString] forKey:@"tinyurl"];   
  if (self.elsewhere) [ret setObject:self.elsewhere forKey:@"elsewhere"];  
  if (self.added) [ret setObject:[NSString stringWithFormat:@"%d", [self.added timeIntervalSince1970]] forKey:@"added"];    
  if (self.entries) [ret setObject:[self.entries stringValue] forKey:@"entries"];
  if (self.following) [ret setObject:[self.following stringValue] forKey:@"following"];
  if (self.followers) [ret setObject:[self.followers stringValue] forKey:@"followers"];  
  return ret;
}

@end
