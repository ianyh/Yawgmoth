#import "SIYUpdaterController.h"


@implementation SIYUpdaterController

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
	NSDictionary *versionToUpdateSelector = [NSDictionary dictionaryWithObjectsAndKeys:
											 @"update07", @"0.7",
											 @"update071", @"0.7.1",
											 nil];
	NSArray *versions = [versionToUpdateSelector allKeys];
	NSString *updateMarker = [self loadUpdateMarker];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF > %@", updateMarker];
	int i;
	
	if (updateMarker != nil) {
		versions = [versions filteredArrayUsingPredicate:predicate];
		if ([versions count] == 0) {
			return;
		}
	}
	updateCount = [versions count];
	
	[self startUpdate];
	
	for (i = 0; i < [versions count]; i++) {
		[self performSelector:NSSelectorFromString([versionToUpdateSelector objectForKey:[versions objectAtIndex:i]])];
	}

	[self endUpdate];

	[self writeUpdateMarker];
	[pool release];
}

- (void)startUpdate
{
	[progressIndicator setUsesThreadedAnimation:YES];
	modalSession = [NSApp beginModalSessionForWindow:updatePanel];
	[progressIndicator startAnimation:self];
}

- (void)endUpdate
{
	[progressIndicator stopAnimation:self];
	[NSApp endModalSession:modalSession];
	[updatePanel close];
}

- (NSString *)loadUpdateMarker
{
	NSString *updateMarkerPath = [[cardManager applicationSupportDirectory] stringByAppendingPathComponent:@"umarker"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:updateMarkerPath]) {
		return nil;
	}
	return [NSString stringWithContentsOfFile:updateMarkerPath encoding:NSASCIIStringEncoding error:nil];
}

- (void)writeUpdateMarker
{
	NSString *updateMarkerPath = [[cardManager applicationSupportDirectory] stringByAppendingPathComponent:@"umarker"];
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	[version writeToFile:updateMarkerPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
}

- (void)incrementProgress:(double)increment
{
//	[progressIndicator incrementBy:increment/updateCount];
	[NSApp runModalSession:modalSession];
}

- (void)update07
{
	double increment = 50.0;
	
	// add AEther Burst
	[progressLabel setStringValue:@"Adding missing cards..."];
	NSManagedObject *card;
	card = [cardManager managedObjectWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", @"AEther Burst"] inEntityWithName:@"FullCard"];
	if (card == nil) {
		[progressDetail setStringValue:@"AEther Burst"];
		[NSApp runModalSession:modalSession];
		card = [NSEntityDescription insertNewObjectForEntityForName:@"FullCard" inManagedObjectContext:[cardManager managedObjectContext]];
		card.convertedManaCost = [NSNumber numberWithInt:2];
		card.manaCost = @"1U";
		card.name = @"AEther Burst";
		card.power = nil;
		card.rarity = @"C";
		card.set = @"Odyssey";
		card.superType = @"Instant";
		card.text = [@"Return up to X target creatures to their owners' hands, where X is " stringByAppendingString:
					 @"one plus the number of cards named AEther Burst in all graveyards as you cast AEther Burst."];
		card.toughness = nil;
		card.type = @"Instant";
		[cardManager save];
	}
	
	// fix Creeping Tar Pit
	[progressLabel setStringValue:@"Fixing existing cards..."];
	[progressDetail setStringValue:@"Creeping Tar Pit"];
	[NSApp runModalSession:modalSession];
	NSArray *cards;
	int i;
	
	cards = [cardManager managedObjectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", @"Creeping Tar Pits"] inEntityWithName:@"FullCard"];
	for (i = 0; i < [cards count]; i++) {
		card = [cards objectAtIndex:i];
		card.name = @"Creeping Tar Pit";
	}
	
	cards = [cardManager managedObjectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", @"Creeping Tar Pits"] inEntityWithName:@"MetaCard"];
	for (i = 0; i < [cards count]; i++) {
		card = [cards objectAtIndex:i];
		card.name = @"Creeping Tar Pit";
	}
	
	cards = [cardManager managedObjectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", @"Creeping Tar Pits"] inEntityWithName:@"CollectionCard"];
	for (i = 0; i < [cards count]; i++) {
		card = [cards objectAtIndex:i];
		card.name = @"Creeping Tar Pit";
	}
	
	[cardManager save];
}

- (void)update071
{
	// nullify power/toughness for non-creatures
	// nullify (converted)manaCost for lands
	// M2010/M2011 -> Magic 2010/Magic 2011
	[progressLabel setStringValue:@"Fixing existing cards..."];
	[NSApp runModalSession:modalSession];
	
	NSPredicate *nonCreaturePredicate = [NSPredicate predicateWithFormat:@"superType != %@ AND superType != %@",
										 @"Creature", @"Artifact Creature"];
	NSPredicate *magic2010Predicate = [NSPredicate predicateWithFormat:@"set = %@", @"M2010"];
	NSPredicate *magic2011Predicate = [NSPredicate predicateWithFormat:@"set = %@", @"M2011"];
	NSArray *entities = [NSArray arrayWithObjects:@"FullCard", @"MetaCard", @"CollectionCard", nil];
	NSArray *cards;
	NSManagedObject *card;
	int i, j;
	
	for (i = 0; i < [entities count]; i++) {
		// nullify power/toughness for non-creatures
		cards = [cardManager managedObjectsWithPredicate:nonCreaturePredicate inEntityWithName:[entities objectAtIndex:i]];
		[progressLabel setStringValue:@"Fixing non-creature attributes..."];
		for (j = 0; j < [cards count]; j++) {
			card = [cards objectAtIndex:j];
			[progressDetail setStringValue:card.name];
			[NSApp runModalSession:modalSession];
			card.power = nil;
			card.toughness = nil;
			
			if ([card.superType isEqualToString:@"Land"]) {
				card.convertedManaCost = nil;
				card.manaCost = nil;
			}
		}
		
		// M2010 -> Magic 2010
		cards = [cardManager managedObjectsWithPredicate:magic2010Predicate inEntityWithName:[entities objectAtIndex:i]];
		[progressLabel setStringValue:@"Renaming M2010"];
		for (j = 0; j < [cards count]; j++) {
			card = [cards objectAtIndex:j];
			[progressDetail setStringValue:card.name];
			[NSApp runModalSession:modalSession];
			card.set = @"Magic 2010";
		}
		
		// M2011 -> Magic 2011
		cards = [cardManager managedObjectsWithPredicate:magic2011Predicate inEntityWithName:[entities objectAtIndex:i]];
		for (j = 0; j < [cards count]; j++) {
			card = [cards objectAtIndex:j];
			[progressDetail setStringValue:card.name];
			[NSApp runModalSession:modalSession];			
			card.set = @"Magic 2011";
		}
	}
	
	// fix creature powers
	NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	NSArray *fileNames = [NSArray arrayWithObjects:@"Shards of Alara.csv", @"Conflux.csv", @"Alara Reborn.csv", @"Magic 2010.csv",
						  @"Zendikar.csv", @"Worldwake.csv", @"Rise of the Eldrazi.csv", @"Magic 2011.csv", nil];
	NSEnumerator *enumerator = [fileNames objectEnumerator];
	NSString *fileName;
	
	[progressLabel setStringValue:@"Fixing creature powers..."];
	
	while ((fileName = [enumerator nextObject]) != nil) {
		NSString *setName = [[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
		NSString *fileString = [NSString stringWithContentsOfFile:[resourcePath stringByAppendingPathComponent:fileName] 
														 encoding:NSASCIIStringEncoding 
															error:nil];
		NSArray *setRows = [self csvRowsFromString:fileString];
		NSArray *row;
		for (i = 0; i < [setRows count]; i++) {
			row = [setRows objectAtIndex:i];			
			card = [cardManager managedObjectWithPredicate:[NSPredicate predicateWithFormat:@"set = %@ AND name = %@", setName, [row objectAtIndex:0]] 
										  inEntityWithName:@"FullCard"];
			if ([card.superType isEqualToString:@"Creature"] || [card.superType isEqualToString:@"Artifact Creature"]) {
				[progressDetail setStringValue:[NSString stringWithFormat:@"%@ - %@", setName, [row objectAtIndex:0]]];
				[NSApp runModalSession:modalSession];
				card.power = [row objectAtIndex:3];
				cards = [cardManager managedObjectsWithPredicate:[NSPredicate predicateWithFormat:@"set = %@ AND name = %@", setName, [row objectAtIndex:0]] 
												inEntityWithName:@"CollectionCard"];
				for (j = 0; j < [cards count]; j++) {
					card = [cards objectAtIndex:j];
					card.power = [row objectAtIndex:3];
					card.metaCard.power = card.power;
				}
				[cardManager save];
			}
		}
	}
}

@end
