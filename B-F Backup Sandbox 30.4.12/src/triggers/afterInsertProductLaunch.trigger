trigger afterInsertProductLaunch on Product_Launch__c (after insert) {

for (Product_Launch__c myProductLaunch : Trigger.new) {


//If this is a NEW Product Launch - Do Stuff	
if (myProductLaunch.Initial__c == false){

//Creating a new Detail Record (Template)
Product_Launch_Detail__c  theNewRecord = new Product_Launch_Detail__c();

//Initializing a few fields
theNewRecord.Product_Launch__c = myProductLaunch.id;
theNewRecord.Survey_Date__c = myProductLaunch.Launch_Date__c;
theNewRecord.Counter__c = 1;
theNewRecord.Week__c = 'Week1';


//Create the record
insert (theNewRecord);

//Update Record
Product_Launch__c setIntial = ([Select Initial__c From Product_Launch__c where id =:myProductLaunch.id limit 1]);

//Setting the intial Flag
setIntial.Initial__c = true;

//Updating the intial flag
update (setIntial);

}	



}


}