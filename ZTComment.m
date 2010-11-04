//
//  ZTComment.m
//  zootoolapp
//
//  Created by nico on 26/10/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTComment.h"
#import "ZTUser.h"


@implementation ZTComment

@synthesize user, text, added;

- (void) dealloc
{
  self.user = nil;
  self.text = nil;
  self.added = nil;
  [super dealloc];
}

- (id) initWithDictionary:(NSDictionary*)dict
{
  if (self = [super init])
  {
    NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];    
    id userDic = [dict objectForKey:@"user"];
    if (userDic && [userDic isKindOfClass:[NSDictionary class]])
    {
      self.user = [[[ZTUser alloc] initWithDictionary:userDic] autorelease];
    }
    self.text = [[dict objectForKey:@"text"] description];
    double unixTimestamp = [[formatter numberFromString:[[dict objectForKey:@"added"] description]] doubleValue]; 
    self.added = [NSDate dateWithTimeIntervalSince1970:unixTimestamp];    
  }
  return self;
}

- (NSDictionary*) dictionary
{
  NSMutableDictionary* ret = [NSMutableDictionary dictionary];
  if (self.user) [ret setObject:[self.user dictionary] forKey:@"user"];
  if (self.text) [ret setObject:self.text forKey:@"text"];
  if (self.added) [ret setObject:[NSString stringWithFormat:@"%d", [self.added timeIntervalSince1970]] forKey:@"added"];    
  return ret;
}

- (NSString*) description
{
  return [[self dictionary] description];
}

@end
