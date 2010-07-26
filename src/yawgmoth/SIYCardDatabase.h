#import <Cocoa/Cocoa.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface SIYCardDatabase : NSObject {
	FMDatabase *db;
	id nameCache;
	id setCache;
	
	NSInteger numberOfRows;
	NSString *filterString;
}

- (NSString *)cardValueType:(NSString *)type fromDBAtIndex:(NSInteger)rowIndex;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (void)populateCard:(NSManagedObject *)card withRowIndex:(NSInteger)rowIndex;
- (NSString *)queryWithSelection:(NSString *)selectionStatement singleSelection:(BOOL)isSingleSelection;
- (NSString *)superTypeFromType:(NSString *)type;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void)updateFilter:(NSString *)newFilterString;

@end
