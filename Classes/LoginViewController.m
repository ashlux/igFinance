
#import "LoginViewController.h"
#import "GoogleClientLogin.h"

@implementation LoginViewController

@synthesize portfoliosViewController;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize autoLoginSwitch;

- (void)getDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSLog(@"%@", defaults);
	NSString *username = [defaults objectForKey:@"username"];
	NSLog(@"%@", [defaults objectForKey:@"username"]);
	if (username != nil) {
		usernameTextField.text = username;
	}
	
	NSString *password = [defaults objectForKey:@"password"];
	if (password != nil) {
		passwordTextField.text = password;
	}
	
	if ([defaults boolForKey:@"autoLogin"]) {
		autoLoginSwitch.on = TRUE;
	} else {
		autoLoginSwitch.on = FALSE;
	}
}

- (void)setDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSLog(@"%@", defaults);
	[defaults setObject:usernameTextField.text forKey:@"username"];
	
	[defaults setBool:[autoLoginSwitch isOn] forKey:@"autoLogin"];
	if ([autoLoginSwitch isOn]) {
		[defaults setObject:passwordTextField.text forKey:@"password"];
	} else {
		[defaults removeObjectForKey:@"password"];
	}
	NSLog(@"%@", defaults);
	[defaults synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Account Details";
	[self getDefaults];
}

- (IBAction)useAccount {
	GoogleClientLogin *googleClientLogin = [[GoogleClientLogin alloc] autorelease];
	googleClientLogin.username = usernameTextField.text;
	googleClientLogin.password = passwordTextField.text;
	
	[portfoliosViewController release];
	PortfoliosViewController *aView = [[PortfoliosViewController alloc] 
									   initWithNibName:@"PortfoliosViewController" bundle:[NSBundle mainBundle]];
	[aView setGoogleClientLogin:googleClientLogin];
	portfoliosViewController = aView;
	
	[self setDefaults];
	[self.navigationController pushViewController:portfoliosViewController animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {	
    if (theTextField == usernameTextField) {
        [usernameTextField resignFirstResponder];
    }
	
	if (theTextField == passwordTextField) {
		[passwordTextField resignFirstResponder];
	}
	
    return YES;
}

- (void)dealloc {
	[portfoliosViewController release];
	
	[usernameTextField release];
	[passwordTextField release];
	[autoLoginSwitch release];
	
    [super dealloc];
}


@end
