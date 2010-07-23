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
	[db close];
	[db release];
	
	[super release];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return (NSInteger) [db intForQuery:@"select count(*) from y_cards"];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSString *value;
	NSString *valueType = [aTableColumn identifier];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	value = [[self cardValueType:valueType fromDBAtIndex:rowIndex] retain];
	[pool release];
	
	return value;
}

- (NSString *)cardValueType:(NSString *)type fromDBAtIndex:(NSInteger)rowIndex
{
	NSString *value;
	FMResultSet *resultSet;
	if ([type isEqualToString:@"name"]) {
		resultSet = [db executeQuery:[self queryWithSelection:@"name"], [NSNumber numberWithInt:rowIndex]];
	} else if ([type isEqualToString:@"set"]) {
		resultSet = [db executeQuery:[self queryWithSelection:@"expansion"], [NSNumber numberWithInt:rowIndex]];
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

- (NSString *)queryWithSelection:(NSString *)selectStatement
{
	NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM y_cards ", selectStatement];
	/*
	if (filterString != nil) {
		query = [query stringByAppendingFormat:@"WHERE name LIKE %%%@%% OR expansion LIKE %%%@%% ", filterString, filterString];
	}*/
	query = [query stringByAppendingString:@"ORDER BY expansion LIMIT 1 OFFSET ?"];
	
	return query;
}

- (void)updateFilter:(NSString *)newFilterString
{
	filterString = newFilterString;
}

@end
