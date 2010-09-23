//
//  ZTProxy.h
//  zootoolapp
//
//  Created by nico on 22/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//


@interface ZTProxy : NSObject {
}

+ (ZTProxy*) defaultProxy;

+ (id) proxyWithAPIKey:(NSString*)apiKey;
- (id) initWithAPIKey:(NSString*)apiKey;

- (void) doNotUseCredential; // default mode
- (void) useCredential:(NSURLCredential*)credentials;
- (BOOL) tryToReuseCredentialForUsername:(NSString*)username;
- (BOOL) validateCredentialAgainstServer;

- (NSDictionary*) userWithUsername:(NSString*)username;
- (NSArray*) userFriendsWithUsername:(NSString*)username withRange:(NSRange)range; // array of dictionnary
- (NSArray*) userFollowersWithUsername:(NSString*)username withRange:(NSRange)range; // array of dictionnary
- (NSArray*) userItemsWithUsername:(NSString*)username withRange:(NSRange)range; // array of dictionnary
- (NSArray*) latestAddedItemsWithRange:(NSRange)range; // array of dictionnary
- (NSArray*) todayPopularItemsWithRange:(NSRange)range; // array of dictionnary
- (NSArray*) thisWeekPopularItemsWithRange:(NSRange)range; // array of dictionnary
- (NSArray*) thisMonthPopularItemsWithRange:(NSRange)range; // array of dictionnary
- (NSArray*) popularItemsWithRange:(NSRange)range; // array of dictionnary
- (NSDictionary*) itemWithUID:(NSString*)uid;

@end
