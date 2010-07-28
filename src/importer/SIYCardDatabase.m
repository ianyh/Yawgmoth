#import "SIYCardDatabase.h"


@implementation SIYCardDatabase

- (id)init
{
	NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"cards" ofType:@"db"];
	db = [[FMDatabase databaseWithPath:dbPath] retain];
	if (![db open]) {
		NSLog(@"failed to open cards.db");
	}
	[db setShouldCacheStatements:YES];
	
	numberOfRows = -1;

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
	if (numberOfRows < 0) {
		numberOfRows = (NSInteger) [db intForQuery:[self queryWithSelection:@"count(*)" singleSelection:NO]];
	}
	
	return numberOfRows;
}

- (void)populateCard:(NSManagedObject *)card withRowIndex:(NSInteger)rowIndex
{
	FMResultSet *resultSet = [db executeQuery:[self queryWithSelection:@"*" singleSelection:YES], [NSNumber numberWithInt:rowIndex]];
	
	if (![resultSet next]) {
		NSLog(@"failed to populate card at row %d", rowIndex);
	}
	
	card.convertedManaCost = [NSNumber numberWithInt:[resultSet intForColumn:@"converted_mana"]];
	card.manaCost = [resultSet stringForColumn:@"mana"];
	card.name = [resultSet stringForColumn:@"name"];
	card.rarity = [resultSet stringForColumn:@"rarity"];
	card.set = [resultSet stringForColumn:@"expansion"];
	card.text = [resultSet stringForColumn:@"text"];
	
	card.power = [NSNumber numberWithInt:[resultSet intForColumn:@"power"]];
	card.toughness = [NSNumber numberWithInt:[resultSet intForColumn:@"toughness"]];
	
	NSString *type = [resultSet stringForColumn:@"type"];
	card.superType = [self superTypeFromType:type];
	card.type = type;
	
	[resultSet close];
}

- (NSString *)queryWithSelection:(NSString *)selectStatement singleSelection:(BOOL)isSingleSelection
{
	NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM y_cards ", selectStatement];
	if (isSingleSelection) {
		query = [query stringByAppendingString:@"ORDER BY expansion LIMIT 1 OFFSET ?"];
	}
	
	return query;
}

- (NSString *)superTypeFromType:(NSString *)type
{
	NSArray *superTypeRegexStrings = [NSArray arrayWithObjects:@".*Instant.*", 
									  @".*Sorcery.*", 
									  @".*Artifact Creature.*", 
									  @".*Artifact Land.*", 
									  @".*Creature.*", 
									  @".*Artifact.*", 
									  @".*Land.*", 
									  @".*Enchantment.*", 
									  @".*Planeswalker.*", nil];
	NSArray *superTypes = [NSArray arrayWithObjects:@"Instant", 
						   @"Sorcery", 
						   @"Artifact Creature", 
						   @"Artifact Land", 
						   @"Creature", 
						   @"Artifact", 
						   @"Land", 
						   @"Enchantment", 
						   @"Planeswalker", nil];
	int i;
	
	for (i = 0; i < [superTypes count]; i++) {
		NSPredicate *superTypeRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", [superTypeRegexStrings objectAtIndex:i]];
		if ([superTypeRegex evaluateWithObject:type]) {
			return [superTypes objectAtIndex:i];
		}
	}
	
	return @"";
}

- (void)release
{
	[db close];
	[db release];
	
	[super release];
}

@end
