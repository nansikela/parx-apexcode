trigger Lead_beforeInsertUpdate on Lead (before insert, before update) {
   try{
                  
        LeadAddressHandler leadHandler = new LeadAddressHandler();          
        
        if(Trigger.isInsert){
            System.debug('**** Lead: before insert trigger');
            leadHandler.insertValidationCity(Trigger.new);
           
        }else if (Trigger.isUpdate){
            System.debug('**** Lead: before update trigger');
            //cupdate state and country
            //copy state and country in account address
            leadHandler.updateValidationCity(Trigger.new, Trigger.oldMap);
        }           
        
    }catch(System.Exception e){
         System.debug('**** Final Exception Lead_beforeInsertUpdate: ' + e);
    }
    
}