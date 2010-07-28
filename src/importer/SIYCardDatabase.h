#import <Cocoa/Cocoa.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "SIYDataModelManagedObjects.h"

@interface SIYCardDatabase : NSObject {
	FMDatabase *db;
	
	NSInteger numberOfRows;
}

- (NSString *)cardValueType:(NSString *)type fromDBAtIndex:(NSInteger)rowIndex;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (void)populateCard:(NSManagedObject *)card withRowIndex:(NSInteger)rowIndex;
- (NSString *)queryWithSelection:(NSString *)selectionStatement singleSelection:(BOOL)isSingleSelection;
- (NSString *)superTypeFromType:(NSString *)type;

@end
