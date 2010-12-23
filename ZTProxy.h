//
//  ZTProxy.h
//  zootoolapp
//
//  Created by nico on 22/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//


@class ZTUser;
@class ZTItem;


// ZTProxy
// ZTProxy is a small helper to access the ZooTool API
// NB: ZTProxy objects are NOT THREAD SAFE!!
@interface ZTProxy : NSObject {
}

@property (nonatomic, retain) NSString* lastServerMessage; // TODO: this is rubbish...

// isAPIServerDown
// returns YES if the server is reachable
@property (nonatomic, assign, getter=isZooDown) BOOL zooDown;

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

// useCache
// activate or desactivate caching mechanism
- (void) useCache:(BOOL)enableCache; // default to NO

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

- (BOOL) createAccountWithUsername:(NSString*)username email:(NSString*)email andPassword:(NSString*)password;

- (ZTUser*) userWithUsername:(NSString*)username;
- (NSArray*) userFriendsWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTUser
- (NSArray*) userFollowersWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTUser
- (NSArray*) itemLikesWithUID:(NSString*)uid withRange:(NSRange)range; // array of ZTUser
- (NSArray*) activeUsersWithRange:(NSRange)range; // array of ZTUser
- (NSArray*) popularUsersWithRange:(NSRange)range; // array of ZTUser
- (NSArray*) newUsersWithRange:(NSRange)range; // array of ZTUser
- (NSArray*) featuredUsersWithRange:(NSRange)range; // array of ZTUser

- (NSArray*) userTagsWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTTag
- (NSArray*) userRecentTagsWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTTag
- (NSArray*) userFavTagsWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTTag

- (NSArray*) userPacksWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTPack

- (ZTItem*) itemWithUID:(NSString*)uid;
- (NSArray*) userItemsWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTItem
- (NSArray*) userItemsWithUsername:(NSString*)username andTagID:(NSString*)tagid withRange:(NSRange)range; // array of ZTItem
- (NSArray*) userItemsWithUsername:(NSString*)username andPackID:(NSString*)packid withRange:(NSRange)range; // array of ZTItem
- (NSArray*) userFollowingItemsWithUsername:(NSString*)username withRange:(NSRange)range; // array of ZTItem
- (NSArray*) itemsWithTag:(NSString*)tag withRange:(NSRange)range; // array of ZTItem
- (NSArray*) latestAddedItemsWithRange:(NSRange)range; // array of ZTItem
- (NSArray*) todayPopularItemsWithRange:(NSRange)range; // array of ZTItem
- (NSArray*) thisWeekPopularItemsWithRange:(NSRange)range; // array of ZTItem
- (NSArray*) thisMonthPopularItemsWithRange:(NSRange)range; // array of ZTItem
- (NSArray*) popularItemsWithRange:(NSRange)range; // array of ZTItem

- (NSArray*) commentsWithItemUID:(NSString*)uid withRange:(NSRange)range; // array of ZTComment

- (BOOL) followUserWithUsername:(NSString*)username; // need to be authenticated
- (BOOL) unfollowUserWithUsername:(NSString*)username; // need to be authenticated
- (BOOL) isUserWithUsername:(NSString*)usernameA followingUserWithUsername:(NSString*)usernameB;

- (BOOL) likeItem:(ZTItem*)item; // need to be authenticated
- (BOOL) likeItem:(ZTItem*)item keepItPrivate:(BOOL)priv addToPacks:(NSArray*)packs; // need to be authenticated
- (BOOL) unlikeItemWithUID:(NSString*)uid; // need to be authenticated

- (BOOL) postComment:(NSString*)comment onItemWithUID:(NSString*)uid; // need to be authenticated

- (BOOL) editProfileInfo:(NSDictionary*)values; // need to be authenticated
- (BOOL) editProfilePicture:(UIImage*)image; // need to be authenticated

- (BOOL) flagItemWithUID:(NSString*)uid;

@end
