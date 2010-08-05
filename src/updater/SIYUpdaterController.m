#import "SIYUpdaterController.h"


@implementation SIYUpdaterController

- (NSString *)applicationSupportDirectory 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Yawgmoth"];
}

- (void)awakeFromNib
{
    setToCards = [[NSMutableDictionary dictionary] retain];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtPath:resourcePath];
    NSString *fileName;
    
    while ((fileName = [directoryEnumerator nextObject]) != nil) {
        if ([fileName hasSuffix:@".csv"]) {
            NSString *setName = [[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
            NSString *fileString = [NSString stringWithContentsOfFile:[resourcePath stringByAppendingPathComponent:fileName] 
                                                             encoding:NSASCIIStringEncoding 
                                                             error:nil];
            NSArray *setRows = [self csvRowsFromString:fileString];
            [setToCards setObject:setRows forKey:setName];
        }
    }    
}

- (NSArray *)csvRowsFromString:(NSString *)fileString 
{
    NSMutableArray *rows = [NSMutableArray array];
    
    // Get newline character set
    NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
    
    // Characters that are important to the parser
    NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:@",\""];
    [importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
    
    // Create scanner, and scan string
    NSScanner *scanner = [NSScanner scannerWithString:fileString];
    [scanner setCharactersToBeSkipped:nil];
    while ( ![scanner isAtEnd] ) {        
        BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:10];
        NSMutableString *currentColumn = [NSMutableString string];
        while ( !finishedRow ) {
            NSString *tempString;
            if ( [scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
                [currentColumn appendString:tempString];
            }
            
            if ( [scanner isAtEnd] ) {
                if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                finishedRow = YES;
            }
            else if ( [scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString] ) {
                if ( insideQuotes ) {
                    // Add line break to column text
                    [currentColumn appendString:tempString];
                }
                else {
                    // End of row
                    if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ( [scanner scanString:@"\"" intoString:NULL] ) {
                if ( insideQuotes && [scanner scanString:@"\"" intoString:NULL] ) {
                    // Replace double quotes with a single quote in the column string.
                    [currentColumn appendString:@"\""]; 
                }
                else {
                    // Start or end of a quoted string.
                    insideQuotes = !insideQuotes;
                }
            }
            else if ( [scanner scanString:@"," intoString:NULL] ) {  
                if ( insideQuotes ) {
                    [currentColumn appendString:@","];
                }
                else {
                    // This is a column separating comma
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
                    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                }
            }
        }
        if ( [columns count] > 0 ) [rows addObject:columns];
    }
    
    return rows;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"com.scarredions.yawgmoth" code:9999 userInfo:dict];
		NSLog(@"%@", [error localizedDescription]);
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
	
    return managedObjectContext;
}

- (NSManagedObject *)managedFullCardWithName:(NSString *)cardName withSet:(NSString *)cardSet
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"FullCard" inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@) AND (set = %@)", cardName, cardSet];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    if (results == nil) {
        // TODO: present error and fail
        return nil;
    }
    
    if ([results count] > 0) {
        return (NSManagedObject *) [results objectAtIndex:0];
    }
    
    return nil;
}

- (NSManagedObjectModel *)managedObjectModel 
{
    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
												  configuration:nil 
															URL:url 
														options:nil 
														  error:&error]) {
		NSLog(@"%@", [error localizedDescription]);
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }
	
    return persistentStoreCoordinator;
}

- (void)save
{
    NSError *error;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[self managedObjectContext] save:&error]) {
		NSLog(@"%@", [error localizedDescription]);
    }	
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

- (void)update
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSArray *setNames = [setToCards allKeys];
    double setIncrement = 100.0 / [setNames count];
    int i, j;
    
    for (i = 0; i < [setNames count]; i++) {
        NSString *setName = [setNames objectAtIndex:i];
        [setLabel setStringValue:setName];
        
        NSArray *setRows = [setToCards objectForKey:setName];
        [cardNumberLabel setStringValue:[NSString stringWithFormat:@"0/%d", [setRows count]]];
        [cardProgressIndicator setDoubleValue:0.0];
        double increment = 100.0 / [setRows count];
        
        for (j = 0; j < [setRows count]; j++) {
            NSArray *row = [setRows objectAtIndex:j];
            NSManagedObject *card = [self managedFullCardWithName:[row objectAtIndex:0] withSet:setName];
            if (card == nil) {
                card = [NSEntityDescription insertNewObjectForEntityForName:@"FullCard" inManagedObjectContext:[self managedObjectContext]];
                
                card.name = [row objectAtIndex:0];
                card.manaCost = [row objectAtIndex:1];
                card.convertedManaCost = [NSNumber numberWithInt:[[row objectAtIndex:2] intValue]];
                card.power = [NSNumber numberWithInt:[[row objectAtIndex:3] intValue]];
                card.toughness = [NSNumber numberWithInt:[[row objectAtIndex:4] intValue]];
                card.rarity = [row objectAtIndex:5];
                card.type = [row objectAtIndex:6];
                card.superType = [self superTypeFromType:[row objectAtIndex:6]];
                if ([row count] > 7) {
                    card.text = [row objectAtIndex:7];
                }
                card.set = setName;
                
                [self save];
            }
            
            [cardNumberLabel setStringValue:[NSString stringWithFormat:@"%d/%d", j+1, [setRows count]]];
            [cardProgressIndicator incrementBy:increment];
        }
        
        [setProgressIndicator incrementBy:setIncrement];
    }
    
    [pool release];
}

- (IBAction)startUpdate:(id)sender
{
    [updateButton setEnabled:NO];
    [NSThread detachNewThreadSelector:@selector(update) toTarget:self withObject:NULL];
}

@end
