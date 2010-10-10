//
//  ZTTag.h
//  zootoolapp
//
//  Created by nico on 6/10/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//


@interface ZTTag : NSObject {

}

- (id) initWithDictionary:(NSDictionary*)dict; // dictionary string->string
- (NSDictionary*) dictionary; // dictionary string->string

@property (nonatomic, copy) NSString* tid;
@property (nonatomic, copy) NSString* name;

@end
