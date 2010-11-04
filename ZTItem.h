//
//  ZTItem.h
//  zootoolapp
//
//  Created by nico on 23/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTDataObject.h"


@interface ZTItem : ZTDataObject<ZTDataObject> {

}

@property (nonatomic, copy) NSString* uid;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* desc;
@property (nonatomic, copy) NSURL* url;
@property (nonatomic, copy) NSNumber* views;
@property (nonatomic, copy) NSNumber* likes;
@property (nonatomic, copy) NSNumber* comments;
@property (nonatomic, copy) NSNumber* inthezoo;
@property (nonatomic, copy) NSURL* permalink;
@property (nonatomic, copy) NSURL* tinyurl;
@property (nonatomic, copy) NSURL* thumbnail;
@property (nonatomic, copy) NSURL* image;
@property (nonatomic, copy) NSURL* referer;
@property (nonatomic, copy) NSArray* tags;
@property (nonatomic, copy) NSDate* added;

@end
