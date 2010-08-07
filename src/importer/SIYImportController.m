#import "SIYImportController.h"


@implementation SIYImportController

- (NSString *)applicationSupportDirectory 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Yawgmoth"];
}

- (void)awakeFromNib
{
	NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"cards" ofType:@"db"];
	db = [[FMDatabase databaseWithPath:dbPath] retain];
	if (![db open]) {
		NSLog(@"failed to open cards.db");
	}

    rowCount = [db intForQuery:@"SELECT count(*) FROM y_cards"];
	NSString *string = [NSString stringWithFormat:@"0/%d", rowCount];
	[importText setStringValue:string];
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

- (void)import
{
    FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM y_cards"];
	NSManagedObject *card;
	double increment = 100.0 / rowCount;
	int i = 0;
	
    while ([resultSet next]) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		card = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:[self managedObjectContext]];
        
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

		[importProgress incrementBy:increment];
		NSString *string = [NSString stringWithFormat:@"%d/%d", ++i, rowCount];
		[importText setStringValue:string];
		[self save];
		[pool release];
	}	
}

- (IBAction)startImport:(id)sender
{
	[importButton setEnabled:NO];
	[NSThread detachNewThreadSelector:@selector(import) toTarget:self withObject:nil];
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

@end
