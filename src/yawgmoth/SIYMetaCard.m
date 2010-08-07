#import "SIYMetaCard.h"


@implementation SIYMetaCard

@dynamic quantity;
@dynamic cards;
@dynamic deck;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"quantity"]) {
        [self updateQuantity];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updateQuantity
{
    [self setQuantity:[self valueForKeyPath:@"cards.@sum.quantity"]];
}

- (void)addCardsObject:(NSManagedObject *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"cards" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveCards] addObject:value];
    [self didChangeValueForKey:@"cards" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
    
    [value addObserver:self forKeyPath:@"quantity" options:0 context:nil];
    [self updateQuantity];
}

- (void)addCards:(NSSet *)value 
{    
    [self willChangeValueForKey:@"cards" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveCards] unionSet:value];
    [self didChangeValueForKey:@"cards" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    
    NSEnumerator *enumerator = [value objectEnumerator];
    NSManagedObject *object;
    
    while ((object = [enumerator nextObject]) != nil) {
        [object addObserver:self forKeyPath:@"quantity" options:0 context:nil];
    }
    [self updateQuantity];
}

@end