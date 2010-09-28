
ZTProxy
=======

ZTProxy is a small helper to access the ZooTool API within an objective-C app.

ZTProxy requires [json-framework](http://github.com/stig/json-framework)
 

Example
-------

		ZTProxy* prox = [ZTProxy defaultProxy];
		NSURLCredential* cred = [NSURLCredential credentialWithUser:@"XXX" 
                                                       password:@"XXX" 
                                                    persistence:NSURLCredentialPersistencePermanent];
		[prox useCredential:cred];
    NSLog(@"%@", [prox userWithUsername:@"bastian"]);
    NSLog(@"%@", [prox itemWithUID:@"ooq2k"]);
    NSLog(@"%@", [prox userFriendsWithUsername:@"bastian" withRange:NSMakeRange(1, 2)]);
    NSLog(@"%@", [prox popularItemsWithRange:NSMakeRange(1, 2)]);


