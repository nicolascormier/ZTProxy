//
//  ZTComment.h
//  zootoolapp
//
//  Created by nico on 26/10/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTDataObject.h"


@class ZTUser;

@interface ZTComment : ZTDataObject<ZTDataObject> {

}

@property (nonatomic, copy) ZTUser* user;
@property (nonatomic, copy) NSString* text;
@property (nonatomic, copy) NSDate* added;

@end
