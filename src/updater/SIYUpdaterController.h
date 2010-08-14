#import <Cocoa/Cocoa.h>
#import "SIYCardManager.h"


@interface SIYUpdaterController : NSObject {
	IBOutlet SIYCardManager *cardManager;
	
	IBOutlet NSPanel *updatePanel;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *progressLabel;
	
	NSModalSession modalSession;
}

- (NSArray *)csvRowsFromString:(NSString *)fileString;
- (NSString *)superTypeFromType:(NSString *)type;
- (void)update;
- (void)startUpdate;
- (void)endUpdate;

@end
