trigger onOpportunity on Opportunity (before insert, before update, after update/*, before delete*/) {
    if((trigger.isBefore || trigger.isAfter) && onOpportunity.inFutureContextStoredId != 'true' && onOpportunity.inFutureContextStoredId!= '' && onOpportunity.inFutureContextStoredId != String.valueOf(trigger.new[0].Id))
        onOpportunity.clearStaticVariable();
        
    if(onOpportunity.inFutureContextStoredId == '' && onOpportunityLineItem.inFutureContextStoredId == '') {
        onOpportunity.inFutureContextStoredId = 'true';
        if(trigger.isAfter)
            onOpportunity.inFutureContextStoredId = trigger.new[0].Id;
        if(trigger.isBefore && !trigger.isDelete) { //Warenempfänger = AccountId falls Warenempfänger = nichts
            String temp;
            for(Opportunity trig:Trigger.new) {  
                if(!trig.SkipTriggerfromDataloader__c) {
                    temp = trig.KDWE2A__c;
                    if((temp == null || temp == '') &&  trig.AccountId != null)
                        trig.KDWE2A__c = trig.AccountId;
                }
            }
        }
         
    /*    if(trigger.isUpdate && trigger.isAfter) {//we update (only on Update) the rabatt from each opp prod if the rabatt from the opp is updated.
            list<Opportunity> opps = new list<Opportunity>();
            list<Opportunity> opps2 = new list<Opportunity>();
            for(Opportunity opp:trigger.new) {
                if(!opp.SkipTriggerfromDataloader__c)
                    opps.add(opp);
            }
            for(Opportunity opp:trigger.old) {
                if(!opp.SkipTriggerfromDataloader__c) 
                    opps2.add(opp);
            }
            if(!opps.isEmpty())
                onOpportunity.onafterupdate(opps, opps2);
        }
       */ 
        if(trigger.isUpdate && trigger.isBefore) {
            for(Opportunity trig:trigger.new) {
                if(trig.StageNamePosition__c >= 1 && trig.RecordTypeId == '012200000009lZE') //erfassung
                    trig.RecordTypeId = '012200000009lZO';   //freigabe / faktura
            }
            list<Opportunity> opps = new list<Opportunity>();
            list<Opportunity> opps2 = new list<Opportunity>();
            for(Opportunity opp:trigger.new) {
                if(!opp.SkipTriggerfromDataloader__c)
                    opps.add(opp);
            }
            for(Opportunity opp:trigger.old) {
                if(!opp.SkipTriggerfromDataloader__c)
                    opps2.add(opp);
            }
            if(!opps2.isEmpty())
                onOpportunity.onbeforeupdate(opps, opps2);
            onOpportunity.inFutureContextStoredId = '';  //in order that trigger.isupdate && trigger.isafter runs
        }
        
        
//        if(trigger.isDelete && trigger.isBefore) {
//            list<Opportunity> opps = new list<Opportunity>();
//           for(Opportunity opp:trigger.old) {
//                if(!opp.SkipTriggerfromDataloader__c)
//                    opps.add(opp);
//            }
//            if(!opps.isEmpty())
//                onOpportunity.ondelete(opps);
//        }
    }   
    

}