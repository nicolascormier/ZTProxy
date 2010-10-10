//
//  ZTProxy.h
//  zootoolapp
//
//  Created by nico on 22/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//


@class ZTUser;
@class ZTItem;
@class ZTTag;


@interface ZTProxy : NSObject {
}

// defaultProxy
// returns an app-wide global proxy object
+ (ZTProxy*) defaultProxy;

// proxyWithAPIKey
// create a new proxy object with a provided api key
// object has been auto-released prior return
+ (id) proxyWithAPIKey:(NSString*)apiKey;

// proxyWithAPIKey
// create a new proxy object with a provided api key
- (id) initWithAPIKey:(NSString*)apiKey;

- (void) useCache:(BOOL)enableCache; // default YES

// doNotUseCredential
// prevent ZTProxy from using a credential when querying zootool's server
// this is the default mode
- (void) doNotUseCredential;

// useCredential
// set a credential to be used when querying zootool's server
// this method does not validate provided credential
// you should call validateCredentialAgainstServer after this call
- (void) useCredential:(NSURLCredential*)credential; 
          
// tryToReuseCredentialForUsername
// try to see if username has been used previously
// if yes - try to reuse the credential
// once again no validation here
// you should call validateCredentialAgainstServer after this call
- (BOOL) tryToReuseCredentialForUsername:(NSString*)username; 
                        
// validateCredentialAgainstServer
// returns YES if the credential provided are valid
- (BOOL) validateCredentialAgainstServer;

- (ZTUser*) userWithUsername:(NSString*)username;
- (NSArray*) userFriendsWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTUser
- (NSArray*) userFollowersWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTUser
- (NSArray*) userItemsWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTItem
- (NSArray*) userItemsWithUsername:(NSString*)username andTag:(NSString*)tag withRange:(NSRange)range; // array of ZTItem
- (NSArray*) userItemsWithUsername:(NSString*)username andPack:(NSString*)pack withRange:(NSRange)range; // array of ZTItem
- (NSArray*) userTagsWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTTag
- (NSArray*) userPacksWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTPack
- (NSArray*) latestAddedItemsWithRange:(NSRange)range; // array of ZTItem
- (NSArray*) todayPopularItemsWithRange:(NSRange)range; // array of ZTItem
- (NSArray*) thisWeekPopularItemsWithRange:(NSRange)range; // array of ZTItem
- (NSArray*) thisMonthPopularItemsWithRange:(NSRange)range; // array of ZTItem
- (NSArray*) popularItemsWithRange:(NSRange)range; // array of ZTItem
- (ZTItem*) itemWithUID:(NSString*)uid;

@end
