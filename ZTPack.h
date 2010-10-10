//
//  ZTPack.h
//  zootoolapp
//
//  Created by nico on 7/10/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//


@interface ZTPack : NSObject {

}

- (id) initWithDictionary:(NSDictionary*)dict; // dictionary string->string
- (NSDictionary*) dictionary; // dictionary string->string

@property (nonatomic, copy) NSString* pid;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* iconid;
@end
