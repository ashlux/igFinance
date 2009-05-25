
#import <UIKit/UIKit.h>

#import "GoogleClientLogin.h"
#import "GDataFinance.h"

@interface PortfolioViewController : UITableViewController {
	IBOutlet UITableView *portfolioEntryTableView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UITabBar *myTabBar;
	
	GoogleClientLogin *googleClientLogin;
	
	GDataEntryFinancePortfolio *portfolio;
	GDataFeedFinancePosition *positionFeed;
	GDataServiceGoogleFinance *financeService;
}

@property (nonatomic, retain) IBOutlet UITableView *portfolioEntryTableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UITabBar *myTabBar;

@property (nonatomic, retain) GoogleClientLogin *googleClientLogin;

@property (nonatomic, retain) GDataEntryFinancePortfolio *portfolio;
@property (nonatomic, retain) GDataFeedFinancePosition *positionFeed;
@property (nonatomic, retain) GDataServiceGoogleFinance *financeService;

@end
