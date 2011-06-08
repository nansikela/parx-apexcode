trigger onWerbemittelPosten on Werbemittel_Posten__c (after insert, after update, after delete) {
    
   list<id> WPosten = new list<id>();
   list<id> WMittel = new list<id>();
   if(Trigger.isDelete || Trigger.isUpdate){
	   for(Werbemittel_Posten__c t:Trigger.old) {
	   	  WPosten.add(t.Bestellung__c);
	   	  WMittel.add(t.Werbemittel__c);
	   } 
   }
   else{
   	   for(Werbemittel_Posten__c t:Trigger.new) {
	   	  WPosten.add(t.Bestellung__c);
	   	  WMittel.add(t.Werbemittel__c);
	   } 
   }

   
   list<Werbemittel_Bestellung__c> Item_bestellung = new list<Werbemittel_Bestellung__c>(
       [Select Id, Posten__c From Werbemittel_Bestellung__c where Id IN :WPosten]);
     	  for(Integer i = 0 ; i < Item_bestellung.size() ; i++)  {
	     if(Item_bestellung.get(i).Posten__c  == null || Item_bestellung.get(i).Posten__c == ''){
	     		Item_bestellung.get(i).Posten__c = 'Menge\t\tTitel\n-----------------------------\n';
	     }
     	  }
    map<id, Werbemittel__c> Item_werbemittel = new map<id, Werbemittel__c>(
       [Select Id, Artikelnummer__c From Werbemittel__c where Id IN :WMittel]);


   if (Trigger.isInsert) {
       for(Integer i = 0 ; i < Item_bestellung.size() ; i++) {
       	for(Werbemittel_Posten__c temp : Trigger.new) {
       		if(Item_bestellung.get(i).Id == temp.Bestellung__c)
       			Item_bestellung.get(i).Posten__c = Item_bestellung.get(i).Posten__c +  '\n' + (temp.Menge__c).intvalue() + '\t' + temp.Verpackungseinheit__c + '\t' + temp.Titel__c + ' (' + Item_werbemittel.get(temp.Werbemittel__c).Artikelnummer__c + ')';
       	}
       }
   }
   
   if (Trigger.isUpdate) {
       for(Integer i = 0 ; i < Item_bestellung.size() ; i++) {
       	for(Integer j = 0; j < trigger.size ; j++) {
            	String []Temp = Item_bestellung.get(i).Posten__c.split((Trigger.old[j].Menge__c).intvalue() + '\t' + Trigger.old[j].Verpackungseinheit__c + '\t' + Trigger.old[j].Titel__c + ' \\(' + Item_werbemittel.get(Trigger.old[j].Werbemittel__c).Artikelnummer__c + '\\)',2);
            	if(Temp.size()== 2)
       			Item_bestellung.get(i).Posten__c = Temp[0] + (Trigger.new[j].Menge__c).intvalue() + '\t' + Trigger.new[j].Verpackungseinheit__c + '\t' + Trigger.new[j].Titel__c  + ' (' + Item_werbemittel.get(Trigger.new[j].Werbemittel__c).Artikelnummer__c + ')'+ Temp[1] ;
       	}
       }
   }
   
   if (Trigger.isDelete) { 
       for(Integer i = 0 ; i < Item_bestellung.size() ; i++) {
       	 for(Werbemittel_Posten__c temp : Trigger.old) {
      	 	String []Temp2 = Item_bestellung.get(i).Posten__c.split('\n' +  (temp.Menge__c).intvalue() + '\t' + temp.Verpackungseinheit__c + '\t' + temp.Titel__c + ' \\(' + Item_werbemittel.get(temp.Werbemittel__c).Artikelnummer__c + '\\)' ,2);
      	 	if(Temp2.size()== 2) {
     		 		Item_bestellung.get(i).Posten__c = Temp2[0] + Temp2[1] ;
      	 	}
     		 	else {
     		 		Item_bestellung.get(i).Posten__c = Temp2[0];
     		 	}
       	 }
       }
   }
   try {
   	update Item_bestellung;
   } catch (System.Exception e) {
   	System_Settings.logError(e.getMessage(), 'trigger on Werbemittelposten: ' + trigger.isInsert, 'item_bestellung size: '+ item_bestellung.size() + ' list: ' + item_bestellung, item_bestellung.get(0).id, 'ERROR');
   }
   //	System_Settings.logError(item_bestellung.get(0).id, 'trigger on Werbemittelposten: ' + trigger.isInsert, 'item_bestellung size: '+ item_bestellung.size() + ' list: ' + item_bestellung, item_bestellung.get(0).id, 'ERROR');
}