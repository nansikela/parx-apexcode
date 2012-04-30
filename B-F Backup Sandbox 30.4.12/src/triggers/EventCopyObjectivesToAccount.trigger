trigger EventCopyObjectivesToAccount on Event (after insert, after update) {

     for(Event Evnt:Trigger.new){
      //get objectives info 
          for (Account Acct : [select ID from Account where id=:Evnt.AccountId])
          {
              if (Acct != null) {
                  //set the data
                  Acct.Objectives__c = Evnt.Objectives__c;
                  try {
                      update Acct;
                  } catch (exception e) {
                  }
              }
          }

      }
}