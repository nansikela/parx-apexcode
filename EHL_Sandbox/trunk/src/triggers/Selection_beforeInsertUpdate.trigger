/**
 * Case 2967
 * 
 * Would it be possible to add the Selection Day sub-section directly in the main Contact page layout ? 
 * Suggestion: 
 * Link the selection object ADDITIONALLY to the Contact detail. This can be done using a trigger that creates the relationship between the selection object and the contact object.
 * The selection object still needs to be created from the application object. 	
 */
trigger Selection_beforeInsertUpdate on Selection__c (before insert, before update)
{
	// find relevant application ids
	Set<Id> applicationIdSet = new Set<Id>();
	for (Selection__c s : Trigger.new)
	{
		if (s.Application__c != null)
		{
			applicationIdSet.add(s.Application__c);
		}
	}
	
	// qurey details for relevant applications
	Map<Id,Application__c> relatedApplicationMap = new Map<Id,Application__c>([Select a.Student__c, a.Id From Application__c a Where a.Id In :applicationIdSet]);
	
	// update selections (if student id is available)
	for (Selection__c s : Trigger.new)
	{
		if (s.Application__c != null && relatedApplicationMap.containsKey(s.Application__c))
		{
			Application__c app = relatedApplicationMap.get(s.Application__c);
			if (app.Student__c != null)
			{
				s.Student__c = app.Student__c;
			}
			
		}
	}
	
}