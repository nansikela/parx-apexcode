@isTest
private class Test_QueryBuilder {
	static testMethod void testQueryBuild() {
    	QueryBuilder query = new QueryBuilder('Account');    	
    	query = new QueryBuilder(new String[]{'Name'}, 'Account');    	

        //Build WHERE Parameters
		List < QueryBuilder.IQueryPart > whereParts = new List < QueryBuilder.IQueryPart > ();

		whereParts.add(new QueryBuilder.StringQueryPart('Name1', QueryBuilder.SoqlCompareType.kEquals , 'kEquals'));
		whereParts.add(new QueryBuilder.StringQueryPart('Name2', QueryBuilder.SoqlCompareType.kLike , 'kLike'));
		whereParts.add(new QueryBuilder.StringQueryPart('Name3', QueryBuilder.SoqlCompareType.kStartsWith , 'kStartsWith'));
		whereParts.add(new QueryBuilder.StringQueryPart('Name4', QueryBuilder.SoqlCompareType.kNotEquals , 'kNotEquals'));
		whereParts.add(new QueryBuilder.StringQueryPart('Name5', QueryBuilder.SoqlCompareType.kIn  , new String[]{'kIn1','kIn2'}));
		whereParts.add(new QueryBuilder.StringQueryPart('Name6', QueryBuilder.SoqlCompareType.kIn  , new Set<String>{'kIn1','kIn2'}));

		whereParts.add(new QueryBuilder.ListQueryPart('Name6', true , new List<String>{'kIn1','kIn2'}));

		whereParts.add(new QueryBuilder.DateTimeQueryPart('Date', QueryBuilder.DateCompareType.kEquals , System.now()));
		whereParts.add(new QueryBuilder.DateTimeQueryPart('Date', QueryBuilder.DateCompareType.kEquals , System.today(), Time.newInstance(18, 30, 2, 20) ));

		whereParts.add(new QueryBuilder.DateQueryPart('Date', QueryBuilder.DateCompareType.kEquals , System.today()));
		whereParts.add(new QueryBuilder.DateQueryPart('Date', QueryBuilder.DateCompareType.kEquals , System.now()));

		whereParts.add(new QueryBuilder.NumberQueryPart('Date', QueryBuilder.NumberConditionType.kEquals , 1));

		whereParts.add(new QueryBuilder.IsNullQueryPart('Name7', true));
		whereParts.add(new QueryBuilder.IsNullQueryPart('Name8', false));


		query.addWhereParts(whereParts);

		query.addWherePart(new QueryBuilder.BooleanQueryPart('IsBoolean', true));    			
		
		query.setLimit(1);
		query.setOrder('Name');    			

		    			 
		System.debug('********************** query:' + query.getQueryString());       
 			
		
	}
}