//
//  ZTUser.h
//  zootoolapp
//
//  Created by nico on 23/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTDataObject.h"


@interface ZTUser : ZTDataObject<ZTDataObject> {
}

@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* location;
@property (nonatomic, copy) NSString* bio;
@property (nonatomic, copy) NSURL* website;
@property (nonatomic, copy) NSURL* avatar;
@property (nonatomic, copy) NSURL* profile;
@property (nonatomic, copy) NSURL* tinyurl;
@property (nonatomic, copy) NSArray* elsewhere;
@property (nonatomic, copy) NSDate* added;
@property (nonatomic, copy) NSNumber* entries;
@property (nonatomic, copy) NSNumber* following;
@property (nonatomic, copy) NSNumber* followers;

@end
