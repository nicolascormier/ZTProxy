//
//  NSString+SHA1.m
//  zootoolapp
//
//  Created by nico on 23/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "NSString+SHA1.h"

#import <CommonCrypto/CommonDigest.h>


@implementation NSString (NSString_SHA1)

- (NSString*) shasum
{
  unsigned char raw[CC_SHA1_DIGEST_LENGTH];
  const char* passwordCStr = [self UTF8String];
  (void) CC_SHA1(passwordCStr, strlen(passwordCStr), raw);
  NSMutableString* passwordHash = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH*2];
  for (unsigned i = 0 ; i < CC_SHA1_DIGEST_LENGTH; i++) [passwordHash appendFormat:@"%02x" , raw[i]];
  return passwordHash;
}

@end