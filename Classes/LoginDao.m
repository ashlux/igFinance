
#import "LoginDao.h"

@implementation LoginDao

-(GoogleClientLogin*)loginUser :(NSString*)username  :(NSString*)password {
	NSLog(@"Logging in...");
	NSURL *url = [NSURL URLWithString:@"https://www.google.com/accounts/ClientLogin"];
	NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:url];
	[loginRequest setHTTPMethod:@"POST"];
	
	//set headers
	[loginRequest addValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];
	[loginRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	NSString *requestBody = [[NSString alloc] 
							 initWithFormat:@"Email=%@&Passwd=%@&service=finance&source=%@",
							 username, password, [NSString stringWithFormat:@"%@%d", @"ashlux-igFinance-1.0"]];
	[loginRequest setHTTPBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]];
	
	
	NSHTTPURLResponse *response = NULL;	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:loginRequest returningResponse:&response error:nil];
	NSString *responseDataString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
	NSLog(@"Response from Google: %@", responseDataString);
	
	if ([response statusCode] == 200) {
		NSLog(@"Login successful.");
		GoogleClientLogin *aGoogleClientLogin = [GoogleClientLogin alloc];
		aGoogleClientLogin.username = username;
		aGoogleClientLogin.password = password;
		NSString *authToken = [[responseDataString componentsSeparatedByString:@"Auth="] objectAtIndex:1];
		NSLog(@"Google authToken=%@", authToken);
		aGoogleClientLogin.authToken = authToken;
		return [aGoogleClientLogin autorelease];
	} else {
		NSLog(@"Login failed.");
		return nil;
	}
}

@end
