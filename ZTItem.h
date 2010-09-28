//
//  ZTItem.h
//  zootoolapp
//
//  Created by nico on 23/09/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//


@interface ZTItem : NSObject {

}

- (id) initWithDictionary:(NSDictionary*)dict; // dictionary string->string
- (NSDictionary*) dictionary; // dictionary string->string

@property (nonatomic, copy) NSString* uid;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSURL* url;
@property (nonatomic, copy) NSNumber* views;
@property (nonatomic, copy) NSNumber* likes;
@property (nonatomic, copy) NSURL* permalink;
@property (nonatomic, copy) NSURL* tinyurl;
@property (nonatomic, copy) NSURL* thumbnail;



@end
