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

- (NSString *)cardValueType:(NSString *)type fromDBAtIndex:(NSInteger)rowIndex
{
	NSString *value;
	FMResultSet *resultSet = [db executeQuery:[self queryWithSelection:type singleSelection:YES], [NSNumber numberWithInt:rowIndex]];
	
	if (![resultSet next]) {
		NSLog(@"no results found; rowIndex (%d) might be out of bound", rowIndex);
		[resultSet close];
		return @"";
	}
	
	value = [resultSet stringForColumn:type];
	[resultSet close];
	
	return value;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return (NSInteger) [db intForQuery:[self queryWithSelection:@"count(*)" singleSelection:NO]];
}

- (void)populateCard:(NSManagedObject *)card withRowIndex:(NSInteger)rowIndex
{
	FMResultSet *resultSet = [db executeQuery:[self queryWithSelection:@"*" singleSelection:YES], [NSNumber numberWithInt:rowIndex]];
	
	if (![resultSet next]) {
		NSLog(@"failed to populate card at row %d", rowIndex);
	}
	
	card.manaCost = [resultSet stringForColumn:@"mana"];
	card.name = [resultSet stringForColumn:@"name"];
	card.quantity = [NSNumber numberWithInt:1];
	card.rarity = [resultSet stringForColumn:@"rarity"];
	card.text = [resultSet stringForColumn:@"text"];
	
	card.power = [NSNumber numberWithInt:[resultSet intForColumn:@"power"]];
	card.toughness = [NSNumber numberWithInt:[resultSet intForColumn:@"toughness"]];
	
	NSString *type = [resultSet stringForColumn:@"type"];
	card.superType = [self superTypeFromType:type];
	card.type = type;
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

- (NSString *)superTypeFromType:(NSString *)type
{
	// TODO: run a regex on type to determine super type
	return @"";
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

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return;
}

- (void)release
{
	[filterString release];
	[db close];
	[db release];
	
	[super release];
}

- (void)updateFilter:(NSString *)newFilterString
{
	filterString = [[newFilterString copy] retain];
}

@end
