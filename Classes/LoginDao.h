
#import <Foundation/Foundation.h>
#import "GoogleClientLogin.h"

@interface LoginDao : NSObject {
}

-(GoogleClientLogin*)loginUser :(NSString*)username  :(NSString*)password;

@end
