#import "SIYCardDatabase.h"


@implementation SIYCardDatabase

- (id)init
{
	NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"cards" ofType:@"db"];
	db = [[FMDatabase databaseWithPath:dbPath] retain];
	if (![db open]) {
		NSLog(@"failed to open cards.db");
	}
//	[db setShouldCacheStatements:YES];
	
	return [super init];
}

- (void)release
{
	[filterString release];
	[db close];
	[db release];
	
	[super release];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return (NSInteger) [db intForQuery:[self queryWithSelection:@"count(*)" singleSelection:NO]];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *value;
	NSString *valueType = [aTableColumn identifier];
	value = [[self cardValueType:valueType fromDBAtIndex:rowIndex] retain];
	[pool release];
	
	return value;
}

- (NSString *)cardValueType:(NSString *)type fromDBAtIndex:(NSInteger)rowIndex
{
	NSString *value;
	FMResultSet *resultSet;
	if ([type isEqualToString:@"name"]) {
		NSString *query = [self queryWithSelection:@"name" singleSelection:YES];
		resultSet = [db executeQuery:query, [NSNumber numberWithInt:rowIndex]];
	} else if ([type isEqualToString:@"set"]) {
		resultSet = [db executeQuery:[self queryWithSelection:@"expansion" singleSelection:YES], [NSNumber numberWithInt:rowIndex]];
	}
	
	if (![resultSet next]) {
		NSLog(@"no results found; rowIndex (%d) might be out of bound", rowIndex);
		[resultSet close];
		return @"";
	}
	
	if ([type isEqualToString:@"name"]) {
		value = [resultSet stringForColumn:@"name"];
	} else if ([type isEqualToString:@"set"]) {
		value = [resultSet stringForColumn:@"expansion"];
	}
	
	[resultSet close];
	
	return value;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return;
}

- (NSString *)queryWithSelection:(NSString *)selectStatement singleSelection:(BOOL)isSingleSelection
{
	NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM y_cards ", selectStatement];
	if (filterString != nil && ![filterString isEqualToString:@""]) {
		query = [query stringByAppendingFormat:@"WHERE name LIKE '%%%@%%' OR expansion LIKE '%%%@%%' ", filterString, filterString];
	}
	if (isSingleSelection) {
		query = [query stringByAppendingString:@"ORDER BY expansion LIMIT 1 OFFSET ?"];
	}
	
	return query;
}

- (void)updateFilter:(NSString *)newFilterString
{
	filterString = [[newFilterString copy] retain];
}

@end
