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

- (void) doNotUseCredential; // default mode
- (void) useCredential:(NSURLCredential*)credentials;
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
