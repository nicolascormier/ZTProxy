//
//  ZTItem.m
//  zootoolapp
//
//  Created by nico on 23/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTItem.h"


@implementation ZTItem

@synthesize uid, title, url, views, likes, comments, permalink, tinyurl, thumbnail, image, referer, desc, tags, added, inthezoo;

- (void) dealloc
{
  // should be released... KVC/KVO...
  self.uid = nil;
  self.title = nil;
  self.desc = nil;
  self.views = nil;
  self.likes = nil;
  self.comments = nil;  
  self.inthezoo = nil;   
  self.url = nil;
  self.permalink = nil;
  self.tinyurl = nil;
  self.thumbnail = nil;
  self.image = nil;
  self.referer = nil;
  self.tags = nil;
  self.added = nil;
  [super dealloc];
}


- (id) initWithDictionary:(NSDictionary*)dict
{
  if (self = [super init])
  {
    NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.uid = [[dict objectForKey:@"uid"] description];
    self.title = [[dict objectForKey:@"title"] description];
    self.desc = [[dict objectForKey:@"description"] description];    
    self.views = [formatter numberFromString:[[dict objectForKey:@"views"] description]];
    self.likes = [formatter numberFromString:[[dict objectForKey:@"likes"] description]];
    self.comments = [formatter numberFromString:[[dict objectForKey:@"comments"] description]];
    self.inthezoo = [formatter numberFromString:[[dict objectForKey:@"inthezoo"] description]];
    self.url = [NSURL URLWithString:[[dict objectForKey:@"url"] description]];
    self.permalink = [NSURL URLWithString:[[dict objectForKey:@"permalink"] description]];
    self.tinyurl = [NSURL URLWithString:[[dict objectForKey:@"tinyurl"] description]];
    self.thumbnail = [NSURL URLWithString:[[dict objectForKey:@"thumbnail"] description]];
    self.image = [NSURL URLWithString:[[dict objectForKey:@"image"] description]];
    self.referer = [NSURL URLWithString:[[dict objectForKey:@"referer"] description]];
    self.tags = [dict objectForKey:@"tags"];
    double unixTimestamp = [[formatter numberFromString:[[dict objectForKey:@"added"] description]] doubleValue];
    self.added = [NSDate dateWithTimeIntervalSince1970:unixTimestamp];
  }
  return self;
}

- (NSDictionary*) dictionary
{
  NSMutableDictionary* ret = [NSMutableDictionary dictionary];
  if (self.uid) [ret setObject:self.uid forKey:@"uid"];
  if (self.title) [ret setObject:self.title forKey:@"title"];
  if (self.desc) [ret setObject:self.desc forKey:@"description"];  
  if (self.views) [ret setObject:[self.views stringValue] forKey:@"views"];
  if (self.likes) [ret setObject:[self.likes stringValue] forKey:@"likes"];                      
  if (self.comments) [ret setObject:[self.comments stringValue] forKey:@"comments"];                      
  if (self.inthezoo) [ret setObject:[self.inthezoo stringValue] forKey:@"inthezoo"];                      
  if (self.url) [ret setObject:[self.url absoluteString] forKey:@"url"];
  if (self.permalink) [ret setObject:[self.permalink absoluteString] forKey:@"permalink"];
  if (self.tinyurl) [ret setObject:[self.tinyurl absoluteString] forKey:@"tinyurl"];
  if (self.thumbnail) [ret setObject:[self.thumbnail absoluteString] forKey:@"thumbnail"];
  if (self.image) [ret setObject:[self.image absoluteString] forKey:@"image"];  
  if (self.referer) [ret setObject:[self.referer absoluteString] forKey:@"referer"];    
  if (self.tags) [ret setObject:self.tags forKey:@"tags"]; 
  if (self.added) [ret setObject:[NSString stringWithFormat:@"%d", [self.added timeIntervalSince1970]] forKey:@"added"];  
  return ret;
}

- (NSString*) description
{
  return [[self dictionary] description];
}

@end
