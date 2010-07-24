#import "SIYController.h"


@implementation SIYController

- (void)awakeFromNib
{
	cardDatabase = [[[SIYCardDatabase alloc] init] retain];
	[allCardsTable setDataSource:cardDatabase];
}

- (IBAction)addCardToLibraryAddTable:(id)sender
{
	NSString *name = [cardDatabase cardValueType:@"name" fromDBAtIndex:[allCardsTable selectedRow]];
	NSString *set = [cardDatabase cardValueType:@"expansion" fromDBAtIndex:[allCardsTable selectedRow]];
	
	NSEntityDescription *tempCardEntityDescription = [NSEntityDescription entityForName:@"TempCard" inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *existenceCheckFetchRequest = [[NSFetchRequest alloc] init];
	[existenceCheckFetchRequest setEntity:tempCardEntityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@) AND (set = %@)", name, set];
	[existenceCheckFetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *checkResults = [[self managedObjectContext] executeFetchRequest:existenceCheckFetchRequest error:&error];
	if (checkResults == nil) {
		// TODO: do something with error
	}
	
	if ([checkResults count] > 0) {
		NSManagedObject *card = [checkResults objectAtIndex:0];
		card.quantity = [NSNumber numberWithInt:[card.quantity intValue]+1];
	} else {
		NSManagedObject *newCard = [NSEntityDescription insertNewObjectForEntityForName:@"TempCard" inManagedObjectContext:[self managedObjectContext]];
		[cardDatabase populateCard:newCard withRowIndex:[allCardsTable selectedRow]];
	}
	
	[self save];
}

- (IBAction)addToLibrary:(id)sender
{
}

- (NSString *)applicationSupportDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Yawgmoth"];
}

- (IBAction)cancelAddToLibrary:(id)sender
{
	[libraryAddingWindow close];
}

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"com.scarredions.yawgmoth" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
	
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (IBAction)openAddToLibraryWindow:(id)sender
{	
	[libraryAddingWindow makeKeyAndOrderFront:self];
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
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
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
												  configuration:nil 
															URL:url 
														options:nil 
														  error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    
	
    return persistentStoreCoordinator;
}

- (IBAction)removeCardFromLibraryAddTable:(id)sender
{
}

- (void)performCardSelection
{
}

- (void)save
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }	
}

- (IBAction)updateFilter:(id)sender
{
	[cardDatabase updateFilter:[allCardsSearchField stringValue]];
	[allCardsTable reloadData];
}

@end
