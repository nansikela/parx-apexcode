public class cloneClever {
	
	//We will copy the field from the sOBject2 to the sObject 1 if they have the same name.
	//The case of the API Name is ignored as if the field is a standard field or not.
	//e.g. custom field FiEld1__c from the object1 will match standard field field1 from the object2.
/*	
	public static list<SObject> clone(list<SObject> sObject1, list<SObject> sObject2){
			
		Map<String,Schema.SObjectField> sObjectFieldsMap1 = sObject1.getSObjectType().getDescribe().fields.getMap();
		Map<String,Schema.SObjectField> sObjectFieldsMap2 = sObject2.getSObjectType().getDescribe().fields.getMap();

		sObject sobj_helper;
	
		String help2;
		map<String,String> sObject_filtered_2 = new map<String,String>();
		
		for(String help1:sObjectFieldsMap2.keySet()) { //we eliminate the __c of the object to clone
			help2 = help1;
			if(help1.contains('__c'))
				help2= help1.split('__c')[0];

			sObject_filtered_2.put(help2,help1);
		}
		
		if(sObject1.size() < sObject2.size()) {//we add enough sObject according to the size of the object to clone
			for(Integer j=sObject1.size();j<sObject2.size();j++) {
				sobj_helper = sObject1.getSObjectType().newSObject() ;
				sObject1.add(sobj_helper);
			}
		}
		
		for(String help1:sObjectFieldsMap1.keySet()) {	
			help2 = help1;
			if(help1.contains('__c'))   //we eliminate the __c of the object which will be cloned
				help2= help1.split('__c')[0];
			
			if(sObject_filtered_2.keySet().contains(help2)) {  //if we have a match
           		DescribeFieldResult fieldDescribe1 = sObjectFieldsMap1.get(help1).getDescribe();
		
				for(Integer i=0;i<sObject2.size();i++) {

					if(sObject2.get(i).get(sObject_filtered_2.get(help2)) != null && fieldDescribe1.isUpdateable()) {  //isUpdateable and we avoid all the read only field
						try{
							sObject1.get(i).put(help1, sObject2.get(i).get(sObject_filtered_2.get(help2)));
						}
						catch(exception e) { //should happen if the user did a bad configuration (e.g. a text field which will be cloned in a checkbox ...)
							sObject1.get(i).addError('Problem with the mapping, please check the following field: ' + sObject_filtered_2.get(help2));
							sObject2.get(i).addError('Problem with the mapping, please check the following field: ' + sObject_filtered_2.get(help2));	
						}						
					}
				}
			}
		}	

		return sObject1;
	}
	
	//same as the other one but it clones just a single object
	public static SObject clone(SObject sObject1, SObject sObject2){
			
		Map<String,Schema.SObjectField> sObjectFieldsMap1 = sObject1.getSObjectType().getDescribe().fields.getMap();
		Map<String,Schema.SObjectField> sObjectFieldsMap2 = sObject2.getSObjectType().getDescribe().fields.getMap();
		
		String help2;
		map<String,String> sObject_filtered_2 = new map<String,String>();
		
		for(String help1:sObjectFieldsMap2.keySet()) {
			help2 = help1;
			if(help1.contains('__c'))
				help2= help1.split('__c')[0];

			sObject_filtered_2.put(help2,help1);
		}
		
		for(String help1:sObjectFieldsMap1.keySet()) {	
			help2 = help1;
			if(help1.contains('__c'))
				help2= help1.split('__c')[0];
			
			if(sObject_filtered_2.keySet().contains(help2)) {
           		DescribeFieldResult fieldDescribe1 = sObjectFieldsMap1.get(help1).getDescribe();
		
				if(sObject2.get(sObject_filtered_2.get(help2)) != null && fieldDescribe1.isUpdateable()) {
					try{
						sObject1.put(help1, sObject2.get(sObject_filtered_2.get(help2)));
					}
					catch(exception e) {
						sObject1.addError('Problem with the mapping, please check the following field: ' + sObject_filtered_2.get(help2));
						sObject2.addError('Problem with the mapping, please check the following field: ' + sObject_filtered_2.get(help2));	
					}						
				}
			}
		}	

		return sObject1;
	}
*/	
	public static list<SObject> cloneDynamic(list<SObject> sObject1, list<SObject> sObject2, list<String> Ids){
			
		Map<String,Schema.SObjectField> sObjectFieldsMap1 = sObject1.getSObjectType().getDescribe().fields.getMap();
		Map<String,Schema.SObjectField> sObjectFieldsMap2 = sObject2.getSObjectType().getDescribe().fields.getMap();
		
		
		String query = 'select ';
		for(String help1:sObjectFieldsMap2.keySet()) {
			query += help1 + ',';
		}
		query = query.substring(0, query.length()-1) ;
		query += ' from ' + sObject2.getSObjectType() + ' where Id IN (';
		
		for(String help1:Ids) {
			query += '\'' + help1 + '\',';
		}
		query = query.substring(0, query.length()-1) ;
		query +=')';
				
		system.debug('QUERY STRING !!'  + query);
		sObject2 = Database.query(query);
		
		
		sObject sobj_helper;
	
		String help2;
		map<String,String> sObject_filtered_2 = new map<String,String>();
		
		for(String help1:sObjectFieldsMap2.keySet()) { //we eliminate the __c of the object to clone
			help2 = help1;
			if(help1.contains('__c'))
				help2= help1.split('__c')[0];

			sObject_filtered_2.put(help2,help1);
		}
		
		if(sObject1.size() < sObject2.size()) {//we add enough sObject according to the size of the object to clone
			for(Integer j=sObject1.size();j<sObject2.size();j++) {
				sobj_helper = sObject1.getSObjectType().newSObject() ;
				sObject1.add(sobj_helper);
			}
		}
		
		for(String help1:sObjectFieldsMap1.keySet()) {	
			help2 = help1;
			if(help1.contains('__c'))   //we eliminate the __c of the object which will be cloned
				help2= help1.split('__c')[0];
			
			if(sObject_filtered_2.keySet().contains(help2)) {  //if we have a match
           		DescribeFieldResult fieldDescribe1 = sObjectFieldsMap1.get(help1).getDescribe();
		
				for(Integer i=0;i<sObject2.size();i++) {

					if(sObject2.get(i).get(sObject_filtered_2.get(help2)) != null && fieldDescribe1.isUpdateable()) {  //isUpdateable and we avoid all the read only field
						try{
							sObject1.get(i).put(help1, sObject2.get(i).get(sObject_filtered_2.get(help2)));
						}
						catch(exception e) { //should happen if the user did a bad configuration (e.g. a text field which will be cloned in a checkbox ...)
							sObject1.get(i).addError('Problem with the mapping, please check the following field: ' + sObject_filtered_2.get(help2));
							sObject2.get(i).addError('Problem with the mapping, please check the following field: ' + sObject_filtered_2.get(help2));	
						}						
					}
				}
			}
		}	

		return sObject1;
	}
}