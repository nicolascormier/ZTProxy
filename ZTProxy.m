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
#import "ZTTag.h"
#import "ZTPack.h"
#import "ZTComment.h"

#import "APReachability.h"


// make sure to change the lines commented with CHANGEME


#pragma mark -

// you can choose to activate or desactivate caching
// if activated, we cache the JSON's output of each query sent to ZTProxy
// the following variable maxCacheSize is used to limitate the size of this cache
// we should probably cache ZT objects rather than the dictionaries and arrays
// used to create those objects, the downside of this strategy is that we may introduce 
// ownership issues so once again for simplicity's sake it's good enough
static BOOL useCacheByDefault = NO;

// hardcoded url used to query zootool's api
// not quite sexy but faster than building an URL from a dictionary for instance
// once again it's good enough for now :-p
#define ZTProxyServerHost @"zootool.com"
static NSString* ZT_userWithUsernameURL = @"http://"ZTProxyServerHost@"/api/users/info/?apikey=%@&username=%@"; // args[2] : apikey, username 
static NSString* ZT_userFriendsWithUsernameURL = @"http://"ZTProxyServerHost@"/api/users/friends/?apikey=%@&login=%@&username=%@&offset=%d&limit=%d"; // args[5] : apikey, login, username, offset, limit
static NSString* ZT_userFollowersWithUsernameURL = @"http://"ZTProxyServerHost@"/api/users/followers/?apikey=%@&login=%@&username=%@&offset=%d&limit=%d"; // args[5] : apikey, login, username, offset, limit
static NSString* ZT_userItemsWithUsernameURL = @"http://"ZTProxyServerHost@"/api/users/items/?apikey=%@&login=%@&username=%@&offset=%d&limit=%d"; // args[5] : apikey, login, username, offset, limit
static NSString* ZT_userItemsWithUsernameAndPackIDURL = @"http://"ZTProxyServerHost@"/api/users/items/?apikey=%@&login=%@&username=%@&pack_id=%@&offset=%d&limit=%d"; // args[6] : apikey, login, username, pack, offset, limit
static NSString* ZT_userFollowingWithUsernameURL = @"http://"ZTProxyServerHost@"/api/items/following/?apikey=%@&login=%@&username=%@&offset=%d&limit=%d"; // args[6] : apikey, login, username, offset, limit
static NSString* ZT_userItemsWithUsernameAndTagIDURL = @"http://"ZTProxyServerHost@"/api/users/items/?apikey=%@&login=%@&username=%@&tag_id=%@&offset=%d&limit=%d"; // args[6] : apikey, login, username, tag, offset, limit
static NSString* ZT_itemsWithTagURL = @"http://"ZTProxyServerHost@"/api/items/tagged/?apikey=%@&tag=%@&offset=%d&limit=%d"; // args[4] : apikey, tag, offset, limit
static NSString* ZT_userTagsWithUsernameURL = @"http://"ZTProxyServerHost@"/api/users/tags/?apikey=%@&login=%@&username=%@&filter=full&offset=%d&limit=%d"; // args[4] : apikey, login, offset, limit
static NSString* ZT_userRecentTagsWithUsernameURL = @"http://"ZTProxyServerHost@"/api/users/tags/?apikey=%@&login=%@&username=%@&filter=recent&offset=%d&limit=%d"; // args[4] : apikey, login, offset, limit
static NSString* ZT_userFavTagsWithUsernameURL = @"http://"ZTProxyServerHost@"/api/users/tags/?apikey=%@&login=%@&username=%@&filter=favorites&offset=%d&limit=%d"; // args[4] : apikey, login, offset, limit
static NSString* ZT_userPacksWithUsernameURL = @"http://"ZTProxyServerHost@"/api/users/packs/?apikey=%@&login=%@&username=%@&offset=%d&limit=%d"; // args[5] : apikey, login, username, offset, limit
static NSString* ZT_validateCredentials = @"http://"ZTProxyServerHost@"/api/users/validate?apikey=%@&login=true&username=%@&offset=%d&limit=%d"; // args[4] : apikey, username, offset, limit
static NSString* ZT_lastAddedItemsURL = @"http://"ZTProxyServerHost@"/api/items/all/?apikey=%@&login=true&offset=%d&limit=%d"; // args[3] : apikey, offset, limit
static NSString* ZT_todayPopularItemsURL = @"http://"ZTProxyServerHost@"/api/items/popular/?apikey=%@&login=true&type=today&offset=%d&limit=%d"; // args[3] : apikey, offset, limit
static NSString* ZT_thisWeekPopularItemsURL = @"http://"ZTProxyServerHost@"/api/items/popular/?apikey=%@&login=true&type=week&offset=%d&limit=%d"; // args[3] : apikey, offset, limit
static NSString* ZT_thisMonthPopularItemsURL = @"http://"ZTProxyServerHost@"/api/items/popular/?apikey=%@&login=true&type=month&offset=%d&limit=%d"; // args[3] : apikey, offset, limit
static NSString* ZT_popularItemsURL = @"http://"ZTProxyServerHost@"/api/items/popular/?apikey=%@&login=true&type=all&offset=%d&limit=%d"; // args[3] : apikey, offset, limit
static NSString* ZT_itemWithUIDURL = @"http://"ZTProxyServerHost@"/api/items/info/?apikey=%@&uid=%@"; // args[2] : apikey, uid
static NSString* ZT_itemLikesWithUIDURL = @"http://"ZTProxyServerHost@"/api/items/likes/?apikey=%@&uid=%@&offset=%d&limit=%d"; // args[4] : apikey, uid, offset, limit
static NSString* ZT_commentsWithItemUIDURL = @"http://"ZTProxyServerHost@"/api/comments/list?apikey=%@&uid=%@&offset=%d&limit=%d"; // args[4] : apikey, uid, offset, limit
static NSString* ZT_followUserWithUsernameURL = @"http://"ZTProxyServerHost@"/api/users/follow/?apikey=%@&login=%@&follow=%@"; // args[3] : apikey, login, username
static NSString* ZT_unfollowUserWithUsernameURL = @"http://"ZTProxyServerHost@"/api/users/unfollow/?apikey=%@&login=%@&unfollow=%@"; // args[3] : apikey, login, username
static NSString* ZT_isUserWithUsernameFollowingUserWithUsernameURL = @"http://"ZTProxyServerHost@"/api/users/isfriend/?apikey=%@&login=%@&user_a=%@&user_b=%@"; // args[4] : apikey, login, usernameA, usernameB
static NSString* ZT_likeItemURL = @"http://"ZTProxyServerHost@"/api/add/?apikey=%@&login=%@&url=%@&title=%@&description=%@&tags=%@&public=%@&pack=%@"; // args[4] : apikey, login, url, title, description, tags, public, pack
static NSString* ZT_unlikeItemWithUIDURL = @"http://"ZTProxyServerHost@"/api/items/delete/?apikey=%@&login=%@&uid=%@"; // args[4] : apikey, login, uid
static NSString* ZT_postCommentOnItemWithUIDURL = @"http://"ZTProxyServerHost@"/api/comments/add/?apikey=%@&login=%@&uid=%@&text=%@"; // args[4] : apikey, login, uid, text
static NSString* ZT_activeUsersURL = @"http://"ZTProxyServerHost@"/api/users/list/?apikey=%@&type=active&offset=%d&limit=%d"; // args[3] : apikey, offset, limit
static NSString* ZT_popularUsersURL = @"http://"ZTProxyServerHost@"/api/users/list/?apikey=%@&type=popular&offset=%d&limit=%d"; // args[3] : apikey, offset, limit
static NSString* ZT_newUsersURL = @"http://"ZTProxyServerHost@"/api/users/list/?apikey=%@&type=new&offset=%d&limit=%d"; // args[3] : apikey, offset, limit
static NSString* ZT_featuredUsersURL = @"http://"ZTProxyServerHost@"/api/users/list/?apikey=%@&type=featured&offset=%d&limit=%d"; // args[3] : apikey, offset, limit
static NSString* ZT_createAccountWithUsernameEmailAndPasswordURL = @"http://"ZTProxyServerHost@"/api/users/create/?apikey=%@&username=%@&email=%@&password1=%@&password2=%@"; // args[3] : apikey, username, email, password1, password2
static NSString* ZT_editProfileInfoURL = @"http://"ZTProxyServerHost@"/api/users/edit/?apikey=%@&login=%@"; // args[1+n] : apikey, login, ...
static NSString* ZT_editProfilePictureURL = @"http://"ZTProxyServerHost@"/api/avatars/upload/?apikey=%@&login=%@"; // args[2] : apikey, login 
static NSString* ZT_flagItemWithUIDURL = @"http://"ZTProxyServerHost@"/api/items/flag/?apikey=%@&login=%@&uid=%@"; // args[2] : apikey, login, uid


#pragma mark -
#pragma mark ••• private •••
@interface ZTProxy ()

@property (nonatomic, copy) NSString* apiKey;
@property (nonatomic, copy) NSString* username;
@property (nonatomic, retain) SBJsonParser* jsonParser; // retain since the instance is internal

@property (nonatomic, assign) NSCache* cache; // weak link - CHANGEME to copy
@property (nonatomic, assign) BOOL useCache;

@property (nonatomic, retain) APReachability* reachability;

- (id) parseJSONAtURL:(NSURL*)url forceNoCache:(BOOL)noCache;
- (id) parseJSONAtURL:(NSURL*)url;

@end

#define isUserAuthenticated() self.username != nil ? @"true" : @"false"

static inline id isDictionaryOrNil(id obj) { return [obj isKindOfClass:[NSDictionary class]] ? obj : nil; }
static inline id isArrayOrNil(id obj) { return [obj isKindOfClass:[NSArray class]] ? obj : nil; }


#pragma mark -
#pragma mark ••• implementation •••
@implementation ZTProxy

@synthesize apiKey=_apiKey, username=_username;
@synthesize jsonParser=_jsonParser, cache=_cache;
@synthesize useCache=_useCache;
@synthesize zooDown=_zooDown;
@synthesize reachability=_reachability;
@synthesize lastServerMessage=_lastServerMessage;

+ (NSURLProtectionSpace*) defaultProtectionSpace
{
  return [[[NSURLProtectionSpace alloc] initWithHost:ZTProxyServerHost 
                                                port:80
                                            protocol:@"http" 
                                               realm:@"rhino" 
                                authenticationMethod:NSURLAuthenticationMethodHTTPDigest] autorelease];      
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  // no KVO so we can use self.xxx = nil for releasing objects
  self.apiKey = nil;
  self.username = nil;
  self.jsonParser = nil;
  self.cache = nil;
  self.reachability = nil;
  [super dealloc];
}

// proxy's singleton bouh bouh bouh!
static ZTProxy* ZT_defaultProxyInstance = nil;
+ (ZTProxy*) defaultProxy
{
  //@synchronized(self) // not needed as ZTProxy is not thread safe anyway
  {
    // use zootool api webpage to generate a proper api key
    // this is required by zootool's api http://zootool.com/api/docs
    if (!ZT_defaultProxyInstance) ZT_defaultProxyInstance = [[[self class] alloc] initWithAPIKey:[ZTConstants defaultAPIKey]]; // CHANGEME - [ZTConstants defaultAPIKey] with your api key
  }
  return ZT_defaultProxyInstance;
}

+ (id) proxyWithAPIKey:(NSString*)apiKey
{
  return [[[[self class] alloc] initWithAPIKey:apiKey] autorelease];
}

- (void) reachabilityChanged:(NSNotification*)note
{
	APReachability* r = [note object];
	self.zooDown = r.currentReachabilityStatus == NotReachable;
  CSDebugLog(@"currentReachabilityStatus changed! %d\n", r.currentReachabilityStatus);
}

- (id) initWithAPIKey:(NSString*)apiKey
{
  if (self = [super init])
  {
    self.jsonParser = [[[SBJsonParser alloc] init] autorelease];
    self.apiKey = apiKey;

    self.useCache = useCacheByDefault;
    self.cache = [[ZTGlobals mainGlobals] jsonCache]; // CHANGEME to [[NSCache alloc] init]
    
    
    // register to reachibility notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    self.reachability = [APReachability reachabilityWithHostName:ZTProxyServerHost];
    [self.reachability startNotifier];
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
  id object = [self parseJSONAtURL:url forceNoCache:YES]; // we obiously don't want to use a cached value
  return [object respondsToSelector:@selector(valueForKey:)] && [[[object valueForKey:@"username"] lowercaseString] isEqual:[self.username lowercaseString]]; // validate server reponse  
}

#pragma mark ••• parsing and caching •••

- (void) useCache:(BOOL)enableCache
{
  self.useCache = enableCache;
  if (!enableCache)
  {
    [self.cache removeAllObjects]; // clear cache
  }
}

- (void) updateLastServerMessage:(id)object
{
  if ([object respondsToSelector:@selector(valueForKey:)] && [object valueForKey:@"msg"])
  {
    self.lastServerMessage = [[object valueForKey:@"msg"] description];
  }
}

- (id) parseJSONFetchedWithURLRequest:(NSURLRequest*)request cost:(NSUInteger*)outputCost
{
  NSError* error = nil;  
  NSURLResponse* response;
  NSData* rawContent = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  if (!rawContent || error)
  {
    NSLog(@"ZTProxy request failed (%s) - %@ %@", __PRETTY_FUNCTION__, [error localizedDescription], [[request URL] description]);
    return nil;
  }  
  NSString* content = [[[NSString alloc] initWithData:rawContent encoding:NSUTF8StringEncoding] autorelease]; 
  NSLog(@"ZT SERVER %@", [[content stringByReplacingOccurrencesOfString:@"{" withString:@"\n{"] stringByReplacingOccurrencesOfString:@"}" withString:@"}\n"]);
  id object = [self.jsonParser objectWithString:content];
  // error checks
  if (!object) 
  {
    NSLog(@"ZTProxy parsing failed (%s) - %@ %@", __PRETTY_FUNCTION__, self.jsonParser.errorTrace, content);
    return nil;
  }
  else if ([object respondsToSelector:@selector(valueForKey:)] && [[object valueForKey:@"username"] isEqual:@"error"])
  {
    NSLog(@"ZTProxy parsing failed (%s) - %@ %@", __PRETTY_FUNCTION__, [object valueForKey:@"msg"], content);
    return nil;
  }
  [self updateLastServerMessage:object];
  *outputCost = [content length];
  return object;
}

- (id) parseJSONAtURL:(NSURL*)url withPOSTData:(NSDictionary*)data
{
  NSLog(@"ZT API %@ [POST]", url);  
  NSTimeInterval timeout = [ZTConstants defaultNetworkTimeout]; // CHANGEME - APPARENTLY DOES NOT WORK ON POST REQUEST
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];  
  [request setHTTPMethod:@"POST"];
  NSString* body = @"";
  for (NSString* key in [data allKeys])
  {
    body = [body stringByAppendingFormat:@"%@%@=%@", [body length] > 0 ? @"&" : @"", key, [data objectForKey:key]];
  }
  [request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];
  // fetch and parse
  NSUInteger cost = 0;
  return [self parseJSONFetchedWithURLRequest:request cost:&cost];
}

- (id) parseJSONAtURL:(NSURL*)url forceNoCache:(BOOL)noCache
{
  NSLog(@"ZT API %@", url);
  if (!noCache && self.useCache)
  {
    id object = [self.cache objectForKey:url];
    if (object)
    {
      [self updateLastServerMessage:object];
      return object;
    }
  }
  // fetch content at url
  NSTimeInterval timeout = [ZTConstants defaultNetworkTimeout]; // CHANGEME
  NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
  // fetch and parse
  NSUInteger cost = 0;
  id object = [self parseJSONFetchedWithURLRequest:request cost:&cost];
  // we should be good here - jsonParser only provides us with NSArray or NSDictionary
  if (!noCache && self.useCache) // cache object if required
  {
    [self.cache setObject:object forKey:url cost:cost];   
  }
  return object;
}

- (id) parseJSONAtURL:(NSURL*)url
{
  return [self parseJSONAtURL:url forceNoCache:NO];
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

- (NSArray*) commentsWithURL:(NSURL*)url
{
  NSArray* comments = isArrayOrNil([self parseJSONAtURL:url]);
  if (comments)
  {
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[comments count]];
    for (NSDictionary* commentDic in comments)
    {
      if (isDictionaryOrNil(commentDic))
      {
        ZTComment* comment = [[[ZTComment alloc] initWithDictionary:commentDic] autorelease];
        [ret addObject:comment];
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

- (NSArray*) tagsWithURL:(NSURL*)url
{
  NSArray* items = isArrayOrNil([self parseJSONAtURL:url]);
  if (items)
  {
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[items count]];
    for (NSDictionary* itemDic in items)
    {
      if (isDictionaryOrNil(itemDic))
      {
        ZTTag* tag = [[[ZTTag alloc] initWithDictionary:itemDic] autorelease];
        [ret addObject:tag];
      }
    }
    return ret;
  }
  return nil;
}

- (NSArray*) packsWithURL:(NSURL*)url
{
  NSArray* items = isArrayOrNil([self parseJSONAtURL:url]);
  if (items)
  {
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[items count]];
    for (NSDictionary* itemDic in items)
    {
      if (isDictionaryOrNil(itemDic))
      {
        ZTPack* pack = [[[ZTPack alloc] initWithDictionary:itemDic] autorelease];
        [ret addObject:pack];
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

- (NSArray*) activeUsersWithRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_activeUsersURL, self.apiKey, range.location, range.length]];
  return [self usersWithURL:url];
}

- (NSArray*) popularUsersWithRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_popularUsersURL, self.apiKey, range.location, range.length]];
  return [self usersWithURL:url];
}

- (NSArray*) newUsersWithRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_newUsersURL, self.apiKey, range.location, range.length]];
  return [self usersWithURL:url];
}

- (NSArray*) featuredUsersWithRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_featuredUsersURL, self.apiKey, range.location, range.length]];
  return [self usersWithURL:url];
}

- (NSArray*) itemLikesWithUID:(NSString*)uid withRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_itemLikesWithUIDURL, self.apiKey, uid, range.location, range.length]];
  // TODO: we take a shortcut here... Users are directly fetched without taking care of additional information as added and tags
  // TODO: we should create ZTLike objects instead of ZTUser objects
  NSArray* likes = isArrayOrNil([self parseJSONAtURL:url]);
  if (likes)
  {
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:[likes count]];
    for (NSDictionary* likeDic in likes)
    {
      if (isDictionaryOrNil(likeDic))
      {
        NSDictionary* userDic = [likeDic objectForKey:@"user"];
        if (isDictionaryOrNil(userDic))
        {
          ZTUser* user = [[[ZTUser alloc] initWithDictionary:userDic] autorelease];
          [ret addObject:user];
        }
      }
    }
    return ret;
  }
  return nil;
}

- (NSArray*) commentsWithItemUID:(NSString*)uid withRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_commentsWithItemUIDURL, self.apiKey, uid, range.location, range.length]];
  return [self commentsWithURL:url];  
}

- (NSArray*) userItemsWithUsername:(NSString*)username withRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_userItemsWithUsernameURL, self.apiKey, isUserAuthenticated(), username, range.location, range.length]];
  return [self itemsWithURL:url];
}

- (NSArray*) userItemsWithUsername:(NSString*)username andTagID:(NSString*)tagid withRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_userItemsWithUsernameAndTagIDURL, self.apiKey, isUserAuthenticated(), username, tagid, range.location, range.length]];
  return [self itemsWithURL:url];  
}

- (NSArray*) userItemsWithUsername:(NSString*)username andPackID:(NSString*)packid withRange:(NSRange)range
{  
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_userItemsWithUsernameAndPackIDURL, self.apiKey, isUserAuthenticated(), username, packid, range.location, range.length]];
  return [self itemsWithURL:url];  
}

- (NSArray*) userFollowingItemsWithUsername:(NSString*)username withRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_userFollowingWithUsernameURL, self.apiKey, isUserAuthenticated(), username, range.location, range.length]];
  return [self itemsWithURL:url];    
}

- (NSArray*) userTagsWithUsername:(NSString*)username withRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_userTagsWithUsernameURL, self.apiKey, isUserAuthenticated(), username, range.location, range.length]];
  return [self tagsWithURL:url];
}

- (NSArray*) userRecentTagsWithUsername:(NSString*)username withRange:(NSRange)range
{  
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_userRecentTagsWithUsernameURL, self.apiKey, isUserAuthenticated(), username, range.location, range.length]];
  return [self tagsWithURL:url];
}

- (NSArray*) userFavTagsWithUsername:(NSString*)username withRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_userFavTagsWithUsernameURL, self.apiKey, isUserAuthenticated(), username, range.location, range.length]];
  return [self tagsWithURL:url];
}

- (NSArray*) userPacksWithUsername:(NSString*)username withRange:(NSRange)range
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_userPacksWithUsernameURL, self.apiKey, isUserAuthenticated(), username, range.location, range.length]];
  return [self packsWithURL:url];
}

- (NSArray*) itemsWithTag:(NSString*)tag withRange:(NSRange)range
{
  tag = [tag stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_itemsWithTagURL, self.apiKey, tag, range.location, range.length]];
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

- (BOOL) createAccountWithUsername:(NSString*)username email:(NSString*)email andPassword:(NSString*)password
{  
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_createAccountWithUsernameEmailAndPasswordURL, self.apiKey, username, email, password, password]];
  id object = [self parseJSONAtURL:url forceNoCache:YES]; // we obiously don't want to use a cached value
  return [object respondsToSelector:@selector(valueForKey:)] && [[[object valueForKey:@"status"] lowercaseString] isEqual:@"success"]; // validate server reponse  
}

- (BOOL) followUserWithUsername:(NSString*)username
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_followUserWithUsernameURL, self.apiKey, isUserAuthenticated(), username]];
  id object = [self parseJSONAtURL:url forceNoCache:YES]; // we obiously don't want to use a cached value
  return [object respondsToSelector:@selector(valueForKey:)] && [[[object valueForKey:@"status"] lowercaseString] isEqual:@"success"]; // validate server reponse  
}

- (BOOL) unfollowUserWithUsername:(NSString*)username
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_unfollowUserWithUsernameURL, self.apiKey, isUserAuthenticated(), username]];
  id object = [self parseJSONAtURL:url forceNoCache:YES]; // we obiously don't want to use a cached value
  return [object respondsToSelector:@selector(valueForKey:)] && [[[object valueForKey:@"status"] lowercaseString] isEqual:@"success"]; // validate server reponse    
}

- (BOOL) isUserWithUsername:(NSString*)usernameA followingUserWithUsername:(NSString*)usernameB;
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_isUserWithUsernameFollowingUserWithUsernameURL, self.apiKey, isUserAuthenticated(), usernameA, usernameB]];
  id object = [self parseJSONAtURL:url forceNoCache:YES]; // we obiously don't want to use a cached value
  return [object respondsToSelector:@selector(valueForKey:)] 
      && [[[object valueForKey:@"status"] lowercaseString] isEqual:@"success"]
      && [[object valueForKey:@"isfriend"] isEqual:[NSNumber numberWithUnsignedInt:1]]
  ; // validate server reponse      
}

- (BOOL) likeItem:(ZTItem*)item keepItPrivate:(BOOL)priv addToPacks:(NSArray*)packs
{
  NSString* itemURL = [[item.url absoluteString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString* itemTitle = [item.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString* itemDesc = [item.desc stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString* thetags = @"";
  for (NSString* tagname in item.tags) if ([tagname length]) thetags = [thetags stringByAppendingFormat:@"%@,", tagname];
  thetags = [thetags stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString* public = priv ? @"n" : @"y";
  NSString* pack = [[packs lastObject] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString* urlStr = [NSString stringWithFormat:ZT_likeItemURL, self.apiKey, isUserAuthenticated(), itemURL, 
                      itemTitle != nil ? itemTitle : @"",
                      itemDesc != nil ? itemDesc : @"", 
                      thetags, 
                      public,
                      pack != nil ? pack : @""];
  NSURL* url = [NSURL URLWithString:urlStr];
  id object = [self parseJSONAtURL:url forceNoCache:YES]; // we obiously don't want to use a cached value
  return [object respondsToSelector:@selector(valueForKey:)] && [[[object valueForKey:@"status"] lowercaseString] isEqual:@"success"]; // validate server reponse      
}

- (BOOL) likeItem:(ZTItem*)item
{
  return [self likeItem:item keepItPrivate:NO addToPacks:nil];
}

- (BOOL) unlikeItemWithUID:(NSString*)uid
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_unlikeItemWithUIDURL, self.apiKey, isUserAuthenticated(), uid]];
  id object = [self parseJSONAtURL:url forceNoCache:YES]; // we obviously don't want to use a cached value
  return [object respondsToSelector:@selector(valueForKey:)] && [[[object valueForKey:@"status"] lowercaseString] isEqual:@"success"]; // validate server reponse      
}

- (BOOL) postComment:(NSString*)comment onItemWithUID:(NSString*)uid
{
  comment = [comment stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_postCommentOnItemWithUIDURL, self.apiKey, isUserAuthenticated(), uid, comment]];
  id object = [self parseJSONAtURL:url forceNoCache:YES]; // we obviously don't want to use a cached value
  return [object respondsToSelector:@selector(valueForKey:)] && [[[object valueForKey:@"status"] lowercaseString] isEqual:@"success"]; // validate server reponse      
}

- (BOOL) editProfileInfo:(NSDictionary*)values
{
  NSString* urlString = [NSString stringWithFormat:ZT_editProfileInfoURL, self.apiKey, isUserAuthenticated()];
  for (NSString* key in [values allKeys])
  {
    urlString = [urlString stringByAppendingFormat:@"&%@=%@", key, [[values objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  }
  NSURL* url = [NSURL URLWithString:urlString];
  id object = [self parseJSONAtURL:url forceNoCache:YES]; // we obviously don't want to use a cached value
  return [object respondsToSelector:@selector(valueForKey:)] && [[[object valueForKey:@"status"] lowercaseString] isEqual:@"success"]; // validate server reponse      
}

- (BOOL) editProfilePicture:(UIImage*)image
{
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_editProfilePictureURL, self.apiKey, isUserAuthenticated()]];
  NSDictionary* data = [NSDictionary dictionaryWithObject:[UIImagePNGRepresentation(image) base64EncodedString] forKey:@"image"];
  id object = [self parseJSONAtURL:url withPOSTData:data];
  return [object respondsToSelector:@selector(valueForKey:)] && [[[object valueForKey:@"status"] lowercaseString] isEqual:@"success"]; // validate server reponse      
}

- (BOOL) flagItemWithUID:(NSString*)uid
{  
  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ZT_flagItemWithUIDURL, self.apiKey, isUserAuthenticated(), uid]];
  id object = [self parseJSONAtURL:url forceNoCache:YES]; // we obviously don't want to use a cached value
  return [object respondsToSelector:@selector(valueForKey:)] && [[[object valueForKey:@"status"] lowercaseString] isEqual:@"success"]; // validate server reponse      
}

@end
