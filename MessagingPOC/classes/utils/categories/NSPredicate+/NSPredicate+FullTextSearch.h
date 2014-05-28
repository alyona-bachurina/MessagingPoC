@interface NSPredicate (FullTextSearch)
+ (NSPredicate *)predicateForSearchString:(NSString *)searchString
				 inFields:(NSArray *)fields
			     operatorType:(NSPredicateOperatorType)operatorType
				  options:(NSComparisonPredicateOptions)options;
@end;