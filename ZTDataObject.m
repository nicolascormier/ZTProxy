//
//  ZTDataObject.m
//  zootoolapp
//
//  Created by nico on 29/10/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTDataObject.h"


@implementation ZTDataObject
@synthesize tag;

- (id) initWithDictionary:(NSDictionary*)dict
{
  return [super init];
}

- (NSDictionary*) dictionary
{
  return nil;
}

- (NSString*) description
{
  return [[self dictionary] description];
}

- (id) copyWithZone:(NSZone*)zone
{
  return [[[self class] alloc] initWithDictionary:[self dictionary]];
}

@end
