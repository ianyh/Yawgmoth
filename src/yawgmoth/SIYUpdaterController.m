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
	[self startUpdate];
	
	double increment = 50.0;
	
	[progressLabel setStringValue:@"Adding missing cards..."];
	
	NSManagedObject *card;
	card = [cardManager managedObjectWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", @"AEther Burst"] inEntityWithName:@"FullCard"];
	if (card == nil) {
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
	
	[progressIndicator incrementBy:increment];
	[NSApp runModalSession:modalSession];
	
	[progressLabel setStringValue:@"Fixing existing cards..."];
	int i;
	NSArray *cards;
	
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
	
	[cardManager save];
	
	[progressIndicator incrementBy:increment];
	[NSApp runModalSession:modalSession];

	[self endUpdate];
	[pool release];
}

- (void)startUpdate
{
	modalSession = [NSApp beginModalSessionForWindow:updatePanel];
}

- (void)endUpdate
{
	[NSApp endModalSession:modalSession];
	[updatePanel close];
}

@end
