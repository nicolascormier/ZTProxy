//
//  ZTTag.h
//  zootoolapp
//
//  Created by nico on 6/10/10.
//  Copyright 2010 Nicolas CORMIER. All rights reserved.
//

#import "ZTDataObject.h"


@interface ZTTag : ZTDataObject<ZTDataObject> {

}

@property (nonatomic, copy) NSString* tid;
@property (nonatomic, copy) NSString* name;

@property (nonatomic, copy) NSNumber* recent;
@property (nonatomic, copy) NSNumber* fav;
@property (nonatomic, copy) NSNumber* suggestion;

@end
