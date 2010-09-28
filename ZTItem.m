//
//  ZTItem.m
//  zootoolapp
//
//  Created by nico on 23/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTItem.h"


@implementation ZTItem

@synthesize uid, title, url, views, likes, permalink, tinyurl, thumbnail;

- (id) initWithDictionary:(NSDictionary*)dict
{
  if (self = [super init])
  {
    NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.uid = [[dict objectForKey:@"uid"] description];
    self.title = [[dict objectForKey:@"title"] description];
    self.views = [formatter numberFromString:[[dict objectForKey:@"views"] description]];
    self.likes = [formatter numberFromString:[[dict objectForKey:@"likes"] description]];
    self.url = [NSURL URLWithString:[[dict objectForKey:@"url"] description]];
    self.permalink = [NSURL URLWithString:[[dict objectForKey:@"permalink"] description]];
    self.tinyurl = [NSURL URLWithString:[[dict objectForKey:@"tinyurl"] description]];
    self.thumbnail = [NSURL URLWithString:[[dict objectForKey:@"thumbnail"] description]];
  }
  return self;
}

- (NSDictionary*) dictionary
{
  NSMutableDictionary* ret = [NSMutableDictionary dictionary];
  if (self.uid) [ret setObject:self.uid forKey:@"uid"];
  if (self.title) [ret setObject:self.title forKey:@"title"];
  if (self.views) [ret setObject:[self.views stringValue] forKey:@"views"];
  if (self.likes) [ret setObject:[self.likes stringValue] forKey:@"likes"];                      
  if (self.url) [ret setObject:[self.url absoluteString] forKey:@"url"];
  if (self.permalink) [ret setObject:[self.permalink absoluteString] forKey:@"permalink"];
  if (self.tinyurl) [ret setObject:[self.tinyurl absoluteString] forKey:@"tinyurl"];
  if (self.thumbnail) [ret setObject:[self.thumbnail absoluteString] forKey:@"thumbnail"];
  return ret;
}

- (NSString*) description
{
  return [[self dictionary] description];
}

@end
