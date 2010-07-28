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
	
	/*
	id cacheClass = NSClassFromString(@"NSCache");
	if (cacheClass == nil) {
		nameCache = [[NSMutableDictionary dictionaryWithCapacity:1000] retain];
		setCache = [[NSMutableDictionary dictionaryWithCapacity:1000] retain];
	} else {
		nameCache = [[[cacheClass alloc] init] retain];
		setCache = [[[cacheClass alloc] init] retain];
		[nameCache setCountLimit:1000];
		[setCache setCountLimit:1000];
	}
	 */
	
	numberOfRows = -1;
	
	/*
	nextRowToCache = 0;
	lastRequestedRow = -1;
	
	cachingThread = [[[NSThread alloc] initWithTarget:self selector:@selector(cache) object:nil] retain];
	cacheLock = [[[NSLock alloc] init] retain];
	 */
	
	return [super init];
}

- (void)cache
{
	while(1) {
		if (nextRowToCache - lastRequestedRow < 200) {
			[cacheLock lock];
			NSString *value = [nameCache objectForKey:[NSNumber	numberWithInt:nextRowToCache]];
			while (value != nil) {
				[cacheLock unlock];
				[NSThread sleepForTimeInterval:50.0/(nextRowToCache - lastRequestedRow + 1)];
				[cacheLock lock];
				
				nextRowToCache++;
				value = [nameCache objectForKey:[NSNumber numberWithInt:nextRowToCache]];
			}
			
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			[nameCache setObject:[self cardValueType:@"name" fromDBAtIndex:nextRowToCache] forKey:[NSNumber numberWithInt:nextRowToCache]];
			[setCache setObject:[self cardValueType:@"expansion" fromDBAtIndex:nextRowToCache] forKey:[NSNumber numberWithInt:nextRowToCache]];
			[pool release];
			
			[cacheLock unlock];
		}
		[NSThread sleepForTimeInterval:50.0/(nextRowToCache - lastRequestedRow + 1)];
	}
}

/**
 * must acquire cacheLock before calling
 */
- (NSString *)cardValueType:(NSString *)type fromDBAtIndex:(NSInteger)rowIndex
{
	NSString *value;
	id cache;
	
	if ([type isEqualToString:@"name"]) {
		cache = nameCache;
	} else {
		cache = setCache;
	}
	
	value = [cache objectForKey:[NSNumber numberWithInt:rowIndex]];	
	
	if (value == nil) {
		FMResultSet *resultSet = [db executeQuery:[self queryWithSelection:type singleSelection:YES], [NSNumber numberWithInt:rowIndex]];
		
		if (![resultSet next]) {
			NSLog(@"no results found; rowIndex (%d) might be out of bound", rowIndex);
			[resultSet close];
			return @"";
		}
		
		value = [resultSet stringForColumn:type];
		[resultSet close];
		
		[cache setObject:value forKey:[NSNumber numberWithInt:rowIndex]];
	}
	
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
	
	card.manaCost = [resultSet stringForColumn:@"mana"];
	card.name = [resultSet stringForColumn:@"name"];
	card.quantity = [NSNumber numberWithInt:0];
	card.rarity = [resultSet stringForColumn:@"rarity"];
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
	if (filterString != nil && ![filterString isEqualToString:@""]) {
		query = [query stringByAppendingFormat:@"WHERE name LIKE '%%%@%%' OR expansion LIKE '%%%@%%' ", filterString, filterString];
	}
	if (isSingleSelection) {
		query = [query stringByAppendingString:@"ORDER BY expansion LIMIT 1 OFFSET ?"];
	}
	
	return query;
}

- (void)startCachingThread
{
	[cachingThread start];
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

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *value;
	NSString *valueType = [aTableColumn identifier];
	[cacheLock lock];
	value = [self cardValueType:valueType fromDBAtIndex:rowIndex];
	lastRequestedRow = rowIndex;
	if (lastRequestedRow > nextRowToCache) {
		nextRowToCache = lastRequestedRow;
	}
	[cacheLock unlock];
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
	numberOfRows = -1;
	[nameCache removeAllObjects];
	[setCache removeAllObjects];
	nextRowToCache = 0;
	
	[filterString release];
	filterString = [[newFilterString copy] retain];
}

@end
