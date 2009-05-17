
#import <Foundation/Foundation.h>

@interface GoogleClientLogin : NSObject {
	NSString *username;
	NSString *password;
	NSString *authToken;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *authToken;

@end
