//
//  ZTProxy.m
//  zootoolapp
//
//  Created by nico on 22/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTProxy.h"
#import "JSON.h"
#import "NSString+SHA1.h"
#import "ZTUser.h"
#import "ZTItem.h"


#pragma mark -
#pragma mark ••• constants •••

// use zootool api webpage to generate a proper api key
// this is required by zootool's api http://zootool.com/api/docs
static NSString* ZT_defaultAPIKey = @"f7b6656c64750afaef371c0d382c6dfb"; // CHANGEME

// you can choose to activate or desactivate caching
// by default we cache the JSON's output of each query sent to ZTProxy
// the following variable maxCacheSize is used to limitate the size of this cache
// the strategy used behind this cache is simple and stupid and should be fixed
// but it's good enough for now ^_^
// we should probably cache ZT objects rather than the dictionaries and array
// used to create those objects
// once again for simplicity's sake it's good enough
static unsigned maxCacheSize = 500; // size in number of elements

// hardcoded url used to query zootool's api
// not quite sexy but faster than building an URL from a dictionary for instance
// once again it's good enough for now :-p
static NSString* ZT_userWithUsernameURL = @"http://zootool.com/api/users/info/?apikey=%@&username=%@"; // args[2] : apikey, username 
static NSString* ZT_userFriendsWithUsernameURL = @"http://zootool.com/api/users/friends/?apikey=%@&login=%@&username=%@&offset=%d&limit=%d"; // args[3] : apikey, login, username, offset, limit
static NSString* ZT_userFollowersWithUsernameURL = @"http://zootool.com/api/users/followers/?apikey=%@&login=%@&username=%@&offset=%d&limit=%d"; // args[3] : apikey, login, username, offset, limit
static NSString* ZT_userItemsWithUsernameURL = @"http://zootool.com/api/users/items/?apikey=%@&login=%@&username=%@&offset=%d&limit=%d"; // args[3] : apikey, login, username, offset, limit
static NSString* ZT_validateCredentials = @"http://zootool.com/api/users/validate?apikey=%@&login=true&username=%@&offset=%d&limit=%d"; // args[2] : apikey, username, offset, limit
static NSString* ZT_lastAddedItemsURL = @"http://zootool.com/api/users/items/?apikey=%@&offset=%d&limit=%d"; // args[1] : apikey, offset, limit
static NSString* ZT_todayPopularItemsURL = @"http://zootool.com/api/items/popular/?apikey=%@&type=today&offset=%d&limit=%d"; // args[1] : apikey, offset, limit
static NSString* ZT_thisWeekPopularItemsURL = @"http://zootool.com/api/items/popular/?apikey=%@&type=week&offset=%d&limit=%d"; // args[1] : apikey, offset, limit
static NSString* ZT_thisMonthPopularItemsURL = @"http://zootool.com/api/items/popular/?apikey=%@&type=month&offset=%d&limit=%d"; // args[1] : apikey, offset, limit
static NSString* ZT_popularItemsURL = @"http://zootool.com/api/items/popular/?apikey=%@&type=all&offset=%d&limit=%d"; // args[1] : apikey, offset, limit
static NSString* ZT_itemWithUIDURL = @"http://zootool.com/api/items/info/?apikey=%@&uid=%@"; // args[2] : apikey, uid


#pragma mark -
#pragma mark ••• private •••
@interface ZTProxy ()

@property (nonatomic, copy) NSString* apiKey;
@property (nonatomic, copy) NSString* username;
@property (nonatomic, retain) SBJsonParser* jsonParser; // retain since the instance is internal
@property (nonatomic, retain) NSMutableDictionary* cache;
@property (nonatomic, assign) BOOL useCache;
@property (nonatomic, assign) unsigned cacheSize; // in number of elements

- (id) parseJSONAtURL:(NSURL*)url;

@end

// handy defines
#define isUserAuthenticated() self.username != nil ? @"true" : @"false"
#define isDictionaryOrNil(o) [o isKindOfClass:[NSDictionary class]] ? o : nil // this should be somewhere else...
#define isArrayOrNil(o) [o isKindOfClass:[NSArray class]] ? o : nil // this should be somewhere else...


#pragma mark -
#pragma mark ••• implementation •••
@implementation ZTProxy

@synthesize apiKey=_apiKey, username=_username;
@synthesize jsonParser=_jsonParser, cache=_cache;
@synthesize useCache=_useCache, cacheSize=_cacheSize;

+ (NSURLProtectionSpace*) defaultProtectionSpace
{
  return [[[NSURLProtectionSpace alloc] initWithHost:@"zootool.com" 
                                                port:80
                                            protocol:@"http" 
                                               realm:@"rhino" 
                                authenticationMethod:NSURLAuthenticationMethodHTTPDigest] autorelease];      
}

- (void) dealloc
{
  // no KVO so we can use self.xxx = nil for releasing objects
  self.apiKey = nil;
  self.username = nil;
  self.jsonParser = nil;
  self.cache = nil;
  [super dealloc];
}

// proxy's singleton bouh bouh bouh!
static ZTProxy* ZT_defaultProxyInstance = nil;
+ (ZTProxy*) defaultProxy
{
  @synchronized(self)
  {
    if (!ZT_defaultProxyInstance) ZT_defaultProxyInstance = [[[self class] alloc] initWithAPIKey:ZT_defaultAPIKey];
  }
  return ZT_defaultProxyInstance;
}

+ (id) proxyWithAPIKey:(NSString*)apiKey
{
  return [[[[self class] alloc] initWithAPIKey:apiKey] autorelease];
}

- (id) initWithAPIKey:(NSString*)apiKey
{
  if (self = [super init])
  {
    self.jsonParser = [[[SBJsonParser alloc] init] autorelease];
    self.apiKey = apiKey;
    self.useCache = YES;
  }
  return self;
}

#pragma mark ••• credential •••

- (void) doNotUseCredential
{
  self.username = nil;
}

- (void) useCredential:(NSURLCredential*)credential
{
  NSString* username = [credential user];
  NSString* passwordHash = [[credential password] shasum]; // generate sha1 password as required by zootool.com
  // authentication
  NSURLCredential* hashedCredential = [NSURLCredential credentialWithUser:username password:passwordHash persistence:[credential persistence]];
  // set credentials in the shared storage - overwrite if required
  [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:hashedCredential forProtectionSpace:[ZTProxy defaultProtectionSpace]];
  self.username = username; // now using provided credential for username
}

- (BOOL) tryToReuseCredentialForUsername:(NSString*)username
{
  NSDictionary* credential = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:[ZTProxy defaultProtectionSpace]];
  if (![credential objectForKey:username]) return NO;
  self.username = username; // now using previously provided credential for username
  return YES;
}

- (BOOL) validateCredentialAgainstServer
{
  if (!self.username) return NO;
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_validateCredentials, self.apiKey, self.username]];
  id object = [self parseJSONAtURL:url];
  return [object respondsToSelector:@selector(valueForKey:)] && [[object valueForKey:@"username"] isEqual:self.username]; // validate server reponse  
}

#pragma mark ••• parsing and caching •••

- (void) useCache:(BOOL)enableCache
{
  self.useCache = enableCache;
  if (!enableCache)
  {
    // clear cache
    [self.cache removeAllObjects];
    self.cacheSize = 0;
  }
}

- (id) parseJSONAtURL:(NSURL*)url
{
  if (self.useCache)
  {
    id object = [self.cache objectForKey:[url absoluteString]];
    if (object) return object;
  }
  // fetch content at url
  NSError* error = nil;
  NSString* content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
  if (error)
  {
    NSLog(@"ZTProxy fetching failed (%s) - %@ %@", __PRETTY_FUNCTION__, [error description], [url description]);
    return nil;
  }
  id object = [self.jsonParser objectWithString:content];
  // error checks
  if (!object) 
  {
    NSLog(@"ZTProxy parsing failed (%s) - %@ %@", __PRETTY_FUNCTION__, self.jsonParser.errorTrace, content);
  }
  else if ([object respondsToSelector:@selector(valueForKey:)] && [[object valueForKey:@"username"] isEqual:@"error"])
  {
    NSLog(@"ZTProxy parsing failed (%s) - %@ %@", __PRETTY_FUNCTION__, [object valueForKey:@"msg"], content);
    return nil;
  }
  // we should be good here - jsonParser only provides us with NSArray or NSDictionary
  if (self.useCache) // cache object if required
  {
    if (isDictionaryOrNil(object)) self.cacheSize += [object count];
    else self.cacheSize += 1;
    // quick and dirty cleanup if needed
    if (self.cacheSize > maxCacheSize)
    {
      // dummy strategy - enumerate collection and remove objects using enumeration order
      for (id key in self.cache)
      {
        id oldObject = [self.cache objectForKey:key];
        if (isDictionaryOrNil(oldObject)) self.cacheSize -= [oldObject count];
        else self.cacheSize -= 1;
        [self.cache removeObjectForKey:key];
        if (self.cacheSize <= maxCacheSize) break;
      }
    }
    // add object in cache
    [self.cache setObject:object forKey:[url absoluteString]];
  }
  return object;
}

#pragma mark ••• queries •••

- (ZTUser*) userWithUsername:(NSString*)username
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_userWithUsernameURL, self.apiKey, username]];
  NSDictionary* userDic = isDictionaryOrNil([self parseJSONAtURL:url]);
  if (userDic) return [[[ZTUser alloc] initWithDictionary:userDic] autorelease];
  return nil;
}

- (ZTItem*) itemWithUID:(NSString*)uid
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_itemWithUIDURL, self.apiKey, uid]];
  NSDictionary* itemDic = isDictionaryOrNil([self parseJSONAtURL:url]);
  if (itemDic) return [[[ZTItem alloc] initWithDictionary:itemDic] autorelease];
  return nil;  
}

- (NSArray*) usersWithURL:(NSURL*)url
{
  NSArray* users = isArrayOrNil([self parseJSONAtURL:url]);
  if (users)
  {
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[users count]];
    for (NSDictionary* userDic in users)
    {
      if (isDictionaryOrNil(userDic))
      {
        ZTUser* user = [[[ZTUser alloc] initWithDictionary:userDic] autorelease];
        [ret addObject:user];
      }
    }
    return ret;
  }
  return nil;
}

- (NSArray*) itemsWithURL:(NSURL*)url
{
  NSArray* items = isArrayOrNil([self parseJSONAtURL:url]);
  if (items)
  {
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[items count]];
    for (NSDictionary* itemDic in items)
    {
      if (isDictionaryOrNil(itemDic))
      {
        ZTItem* item = [[[ZTItem alloc] initWithDictionary:itemDic] autorelease];
        [ret addObject:item];
      }
    }
    return ret;
  }
  return nil;
}

- (NSArray*) userFriendsWithUsername:(NSString*)username withRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_userFriendsWithUsernameURL, self.apiKey, isUserAuthenticated(), username, range.location, range.length]];
  return [self usersWithURL:url];
}

- (NSArray*) userFollowersWithUsername:(NSString*)username withRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_userFollowersWithUsernameURL, self.apiKey, isUserAuthenticated(), username, range.location, range.length]];
  return [self usersWithURL:url];
}

- (NSArray*) userItemsWithUsername:(NSString*)username withRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_userItemsWithUsernameURL, self.apiKey, isUserAuthenticated(), username, range.location, range.length]];
  return [self itemsWithURL:url];
}

- (NSArray*) latestAddedItemsWithRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_lastAddedItemsURL, self.apiKey, range.location, range.length]];
  return [self itemsWithURL:url];
}

- (NSArray*) todayPopularItemsWithRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_todayPopularItemsURL, self.apiKey, range.location, range.length]];
  return [self itemsWithURL:url];
}

- (NSArray*) thisWeekPopularItemsWithRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_thisWeekPopularItemsURL, self.apiKey, range.location, range.length]];
  return [self itemsWithURL:url];
}

- (NSArray*) thisMonthPopularItemsWithRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_thisMonthPopularItemsURL, self.apiKey, range.location, range.length]];
  return [self itemsWithURL:url];
}

- (NSArray*) popularItemsWithRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_popularItemsURL, self.apiKey, range.location, range.length]];
  return [self itemsWithURL:url];
}



@end
