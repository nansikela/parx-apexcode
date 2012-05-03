trigger afterUpdatePromotion on Promotion__c (after update) {
    
system.debug('Your inside the afterUpdatePromotion Trigger');   
        
//  List <promotion__c> myPromotion = trigger.new;
//      Private promotion__c[] myPromotion = trigger.new;
//      promotion__c myPromotion = trigger.new[0];

for (promotion__c myPromotion : Trigger.new) {
        
        
        
system.debug('Here is what is in the myPromotion object :'+ '( '+ myPromotion + ' )');      

    
//Checking to see if this equals true this field is populated via workflow  
if (mypromotion.Promotion_Goal_Lock__c == true) {

Integer counter = 0;

system.debug('During the If it did find the flag set to:'+ '( '+ mypromotion.Promotion_Goal_Lock__c + ' )');


RecordType  unlocked_SP = ([Select Id From RecordType where name = 'Sales Promotion' and sobjecttype = 'promotion_goal__c'  limit 1]);

RecordType  unlocked_AG = ([Select Id From RecordType where name = 'Agreement' and sobjecttype = 'promotion_goal__c'  limit 1]);

string s_unlocked;

if (mypromotion.RecordTypeId == unlocked_SP.Id ) {
//Sales Promotion ID  
s_unlocked = unlocked_SP.id; } else{
//Agreement ID //I know it equals Sales Promotion
s_unlocked = unlocked_AG.id; }




RecordType locked_SP = ([Select Id From RecordType where name = 'Locked' and sobjecttype = 'promotion_goal__c' limit 1]);
RecordType locked_AG = ([Select Id From RecordType where name = 'Locked Agreement' and sobjecttype = 'promotion_goal__c' limit 1]);

string s_lockedId;

if (mypromotion.RecordTypeId == unlocked_SP.Id ) {

//Sales Promotion ID 
s_lockedId = locked_SP.id; } else{
//Agreement ID 
s_lockedId = locked_AG.id; }    



system.debug('Locked Select is complete:'+ '( '+ s_lockedId + ' )');    


    
system.debug('Unlocked Select is complete:'+ '( '+ s_unlocked + ' )');  

string q_mPM_var1 = s_unlocked;//Record Type Variable
string q_mPM_var2 = myPromotion.Id;//Promotion Number 
system.debug('Query Variable 1 (Record Type) = '+ '( '+ s_unlocked + ' )');
system.debug('Query Variable 2 (Promotion Number) = '+ '( '+ q_mPM_var2 + ' )');

//String for myPromotionGoals Query
string q_mPM_query = 'Select RecordTypeId,Id From Promotion_Goal__c p where p.RecordTypeId = :q_mPM_var1 and p.Promotion__c = :q_mPM_var2';
system.debug('Query String = '+ '( '+ q_mPM_query + ' )');

    List <Promotion_Goal__c> myPromotionGoals = database.query(q_mPM_query); 
system.debug('Here is the results of the Promotion Goal Query:'+ '( '+ myPromotionGoals + ' )'); 

    
    
    for (Promotion_Goal__c FL_1 :myPromotionGoals){//Open For 
        
    //For all of the unlocked records found set the record type "Locked"    
        FL_1.RecordTypeId = s_lockedId;
        //Does this work?
        counter = counter + 1;
        
    }//Closed For
    
 system.debug('Here is what the myPromotionGoals object looks AFTER the loop:'+ '( '+ myPromotionGoals + ' )');   
    
//Update the Promotion Goals with the new record type  
//Need to code so update only runs when it is supposed too  

if (counter > 0){
update myPromotionGoals;     
system.debug('After the UPDATE Statement:'+ '( '+ myPromotionGoals + ' )');}else {
system.debug('During the If it did find the flag set to:'+ '( '+ mypromotion.Promotion_Goal_Lock__c + ' )');}


                                
                    
        }
    }
}