
#import <UIKit/UIKit.h>

@interface CurrencyPickerViewController : UITableViewController {
	NSMutableArray *allCurrencyCodes;
	NSString *selectedCurrency;
	}

@property (nonatomic, retain) NSMutableArray *allCurrencyCodes;
@property (nonatomic, retain) NSString *selectedCurrency;

@end
