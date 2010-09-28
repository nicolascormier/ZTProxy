//
//  ZTProxy.h
//  zootoolapp
//
//  Created by nico on 22/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//


@class ZTUser;
@class ZTItem;


@interface ZTProxy : NSObject {
}

+ (ZTProxy*) defaultProxy;

+ (id) proxyWithAPIKey:(NSString*)apiKey;
- (id) initWithAPIKey:(NSString*)apiKey;

- (void) useCache:(BOOL)enableCache; // default YES

- (void) doNotUseCredential; // default mode

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
                                                              
- (BOOL) validateCredentialAgainstServer;

- (ZTUser*) userWithUsername:(NSString*)username;
- (NSArray*) userFriendsWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTUser
- (NSArray*) userFollowersWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTUser
- (NSArray*) userItemsWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTItem
- (NSArray*) latestAddedItemsWithRange:(NSRange)range; // array of ZTItem
- (NSArray*) todayPopularItemsWithRange:(NSRange)range; // array of ZTItem
- (NSArray*) thisWeekPopularItemsWithRange:(NSRange)range; // array of ZTItem
- (NSArray*) thisMonthPopularItemsWithRange:(NSRange)range; // array of ZTItem
- (NSArray*) popularItemsWithRange:(NSRange)range; // array of ZTItem
- (ZTItem*) itemWithUID:(NSString*)uid;

@end
