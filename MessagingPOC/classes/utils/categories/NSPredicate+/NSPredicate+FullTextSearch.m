#include "NSPredicate+FullTextSearch.h"

@implementation NSPredicate (FullTextSearch)


/**
	Utility method to build a Boolean decision tree in the form of a compound 
	NSPredicate which can be used to perform a full-text search on a collection. 
	The resulting predicate will match only those objects which, for each search 
	term, have at least one keypath in the set of provided keypaths for which the 
	corresponding value matches the search term. The type of operator to perform 
	(prefix, contains, exact match) can be configured, as can diacritic-sensitivity 
	and case-sensitivity options.

	@param searchString A space-delimited list of search terms
	@param fields An array of keypaths to search in the target collection
	@param operatorType One of: NSLikePredicateOperatorType, 
		NSBeginsWithPredicateOperatorType, NSEndsWithPredicateOperatorType, 
		NSContainsPredicateOperatorType
	@param searchString An options mask. Zero or more of: 
		NSCaseInsensitivePredicateOption, NSDiacriticInsensitivePredicateOption
	@returns A compound NSPredicate which can be used to filter a collection 
		returning only items for which there is a match (under the specified 
		operator and options) between each of the search terms and one of the values 
		corresponding to the supplied keypaths.
*/
+ (NSPredicate *)predicateForSearchString:(NSString *)searchString 
				 inFields:(NSArray *)fields
			     operatorType:(NSPredicateOperatorType)operatorType
				  options:(NSComparisonPredicateOptions)options
{
	NSArray *searchTerms = nil;
	
	// If we're doing a LIKE search without wildcards, it doesn't make sense to split 
	// the search terms, since a given field cannot be "like" two different terms.
	// Otherwise, split the search term on spaces.
	if(operatorType == NSLikePredicateOperatorType)
		searchTerms = [NSArray arrayWithObject:searchString];
	else
		searchTerms = [searchString componentsSeparatedByString:@" "];
	
	NSString *operatorName = nil;
	
	// Assert supported operator types.
	NSAssert((operatorType == NSLikePredicateOperatorType) || 
		 (operatorType == NSBeginsWithPredicateOperatorType) || 
		 (operatorType == NSEndsWithPredicateOperatorType) || 
		 (operatorType == NSContainsPredicateOperatorType), 
		 @"Unsupported operator type specified");
	
	// Transform operator type to operator name for predicate format.
	switch (operatorType) {
		case NSLikePredicateOperatorType:
			operatorName = @"LIKE";
			break;
		case NSBeginsWithPredicateOperatorType:
			operatorName = @"BEGINSWITH";
			break;
		case NSEndsWithPredicateOperatorType:
			operatorName = @"ENDSWITH";
			break;
		case NSContainsPredicateOperatorType:
			operatorName = @"CONTAINS";
			break;

        case NSLessThanPredicateOperatorType:break;
        case NSLessThanOrEqualToPredicateOperatorType:break;
        case NSGreaterThanPredicateOperatorType:break;
        case NSGreaterThanOrEqualToPredicateOperatorType:break;
        case NSEqualToPredicateOperatorType:break;
        case NSNotEqualToPredicateOperatorType:break;
        case NSMatchesPredicateOperatorType:break;
        case NSInPredicateOperatorType:break;
        case NSCustomSelectorPredicateOperatorType:break;
        case NSBetweenPredicateOperatorType:break;
    }
	
	// Build operator options string (e.g., [dc])
	NSMutableString *operatorOptions = [NSMutableString stringWithCapacity:4];
	
	if(options & NSDiacriticInsensitivePredicateOption)
		[operatorOptions appendString:@"d"];
	
	if(options & NSCaseInsensitivePredicateOption)
		[operatorOptions appendString:@"c"];
	
	if([operatorOptions length] > 0) 
	{
		[operatorOptions insertString:@"[" atIndex:0];
		[operatorOptions appendString:@"]"];
	}
	
	// Build array of subpredicates, each of which compares a single term to all fields
	NSMutableArray *termSubpredicates = [NSMutableArray array];
	for(NSString *searchTerm in searchTerms) 
	{
		// If our splitting produced an empty string, don't include it as a term
		NSString *trimmedTerm = [searchTerm stringByTrimmingCharactersInSet:
					 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		if([trimmedTerm length] == 0)
			continue;
		
		// Build array of subsubpredicates, each of which compares a single term to a single field
		NSMutableArray *termFieldSubsubpredicates = [NSMutableArray array];
		for(NSString *field in fields) 
		{
			// Construct the predicate format string (e.g. "%K CONTAINS[dc] %@")
			NSString *predicateFormat = [NSString stringWithFormat:
						     @"%%K %@%@ %%@", 
						     operatorName, operatorOptions];
			
			NSPredicate *termFieldSubsubpredicate = 
			[NSPredicate predicateWithFormat:
			 predicateFormat, field, trimmedTerm];
			
			[termFieldSubsubpredicates addObject:termFieldSubsubpredicate];
		}
		
		// If none of the fields produced subsubpredicates for this term, 
		// don't bother creating a subpredicate for this term.
		if([termFieldSubsubpredicates count] == 0)
			continue;
		
		// Combine all field subsubpredicates into the term subpredicate.
		NSPredicate *termSubpredicate = [NSCompoundPredicate 
						 orPredicateWithSubpredicates:
						 termFieldSubsubpredicates];
		
		[termSubpredicates addObject:termSubpredicate];
	}
	
	// If there were no terms, no objects match. You could argue philosophically 
	// that all objects match. If that's your epistemological conclusion, feel 
	// free to change the constant below. 
	NSPredicate *searchPredicate = [NSPredicate predicateWithValue:YES];
	
	// Build the final predicate that will combine all term subpredicates.
	if([termSubpredicates count] > 0) 
	{
		searchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:
				   termSubpredicates];
	}
	
	return searchPredicate;
}

@end;