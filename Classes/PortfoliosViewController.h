
#import <UIKit/UIKit.h>
#import "GoogleClientLogin.h"

@interface PortfoliosViewController : UITableViewController {
	NSArray *portfolios;
	GoogleClientLogin *googleClientLogin;
}

@property (nonatomic, retain) NSArray *portfolios;
@property (nonatomic, retain) GoogleClientLogin *googleClientLogin;

@end
