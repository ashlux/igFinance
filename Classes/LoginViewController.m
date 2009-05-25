
#import "LoginViewController.h"
#import "GoogleClientLogin.h"

@implementation LoginViewController

@synthesize portfoliosViewController;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize rememberPasswordSwitch;

- (void)getDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults objectForKey:@"username"];
	if (username != nil) {
		usernameTextField.text = username;
	}
	
	// TODO: Do not store passwords this way
	NSString *password = [defaults objectForKey:@"password"];
	if (password != nil) {
		passwordTextField.text = password;
	}
	
	if ([defaults boolForKey:@"rememberPasswordSwitch"]) {
		rememberPasswordSwitch.on = TRUE;
	} else {
		rememberPasswordSwitch.on = FALSE;
	}
}

- (void)setDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:usernameTextField.text forKey:@"username"];
	
	// TODO: Do not store passwords this way
	[defaults setBool:[rememberPasswordSwitch isOn] forKey:@"rememberPasswordSwitch"];
	if ([rememberPasswordSwitch isOn]) {
		[defaults setObject:passwordTextField.text forKey:@"password"];
	} else {
		[defaults removeObjectForKey:@"password"];
	}
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

- (void)dealloc {
	[portfoliosViewController release];
	
	[usernameTextField release];
	[passwordTextField release];
	[rememberPasswordSwitch release];
	
    [super dealloc];
}


@end
