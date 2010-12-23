//
//  ZTDataObject.h
//  zootoolapp
//
//  Created by nico on 29/10/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//


// ZTDataObject is an abstract class
// All medthods declared in ZTDataObject protocol must be implemented

@protocol ZTDataObject

- (id) initWithDictionary:(NSDictionary*)dict; // dictionary string->string
- (NSDictionary*) dictionary; // dictionary string->string

@end


@interface ZTDataObject : NSObject<NSCopying, ZTDataObject> {
}

@property (nonatomic, assign) NSInteger tag; // programmer defined tag (similar to UIView's tag)

@end
