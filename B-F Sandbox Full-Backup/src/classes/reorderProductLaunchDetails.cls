public with sharing class reorderProductLaunchDetails {




public Id myDelete(Id myRecord) {
string dummy;	

	
	
List<Product_Launch_Detail__c> reorder = [SELECT Id, Counter__c, week__c,Survey_Date__c FROM Product_Launch_Detail__c where Product_Launch__c =:myRecord ORDER BY Survey_Date__c ASC];

Integer i = 1;

for(Product_Launch_Detail__c FL1 : reorder){



FL1.Counter__c = i;
FL1.Week__c = 'Week'+i; 	
	
i = i + 1;

}

update(reorder);

Product_Launch__c updateVisit = [Select Week__c from Product_Launch__c where Id =:myRecord];

updateVisit.Week__c = i-1; 

update(updateVisit);

return dummy;

}
								
public Id myUpdate(Id myRecord) {
string jtest;	

//Getting List of Product Launch Details
List<Product_Launch_Detail__c> reorder = [SELECT Id, Counter__c, week__c,Survey_Date__c,Product_Launch__c FROM Product_Launch_Detail__c where Product_Launch__c =:myRecord ORDER BY Survey_Date__c ASC];


//Loop through the List
for(Product_Launch_Detail__c FL1 : reorder){

//Checking the Sync Flag
Product_Launch__c myFlag = [SELECT Id, sync__c FROM Product_Launch__c where Id = :fL1.Product_Launch__c limit 1];


	
//Chacking to see if the Sync Flag is unchecked
if (myFlag.sync__c == false){

//Setting the Flag to True
myFlag.sync__c = true;

//My Counter	
Integer x = 1;

//This loop realigns the records based of of the Survey Date
for(Product_Launch_Detail__c FL2 : reorder){

//New Values
FL2.Counter__c = x;
FL2.Week__c = 'Week'+x; 	

//Increase the Counter	
x = x + 1;

}
//This update prevents the update from becoming recursive
update(myFlag);

//Update the Product Launch Detail records
update(reorder);
//update(myFlag);
}

break;
}

return jtest;	
}
	
	

}