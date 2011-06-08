trigger onLead on Lead (after insert, before insert, before update) {
	
	if (trigger.isBefore) {
		// sync of both portal fields in lead
		// the effort to change the old portal__c field to picklist is to much
		for(Lead l:trigger.new) {
			if (l.PortalSelection__c!=null) l.Portal__c=l.PortalSelection__c;
			if (l.Portal__c!=null && l.PortalSelection__c==null) l.PortalSelection__c=l.Portal__c;
		}
	}
	
	if (trigger.isAfter) {
		list<Lead> Leads2Convert = new list<Lead>();
		List<GlobalSettings__c> settings = GlobalSettings__c.getall().values();
		
		map<String, String> OwnerId = new map<String, String>();
		for(GlobalSettings__c GS:settings) {
			for(Lead l:trigger.new) {
				if(GS.portal__c ==l.Portal__c && GS.isPro__c == l.Gigaset_Pro__c && GS.Autofreischaltung__c ) {
					Leads2Convert.add(l);
					if(GS.Freischaltung_Owner_Id__c == null || GS.Freischaltung_Owner_Id__c == '')
						l.addError('problem with custom Settings!');
					OwnerId.put(GS.Portal__c, GS.Freischaltung_Owner_Id__c);
				}
			}
		}
		if(!leads2Convert.isEmpty()) {
			Database.LeadConvert[] lcArray = new Database.LeadConvert[] {};
			Database.LeadConvert lc;
			LeadStatus convertstatus = [select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
			
			for(Lead l:Leads2Convert) {
				lc = new database.LeadConvert();
				lc.setLeadId(l.Id);
				lc.setDoNotCreateOpportunity(true);
				lc.setConvertedStatus(convertStatus.MasterLabel);
				lc.setOwnerId(OwnerId.get(l.portal__c));
				lcArray.add(lc);
			}
			
			Database.LeadConvertResult[] results = Database.convertLead(lcArray);
			
			//system.debug('result ...' +results);
			list<ErrorLog__c> elArray=new list<ErrorLog__c>();
			ErrorLog__c el;
			list<String> contactIds = new list<String>();
			for(Database.LeadConvertResult r:results) {
				if(!r.isSuccess()) {
					el =new ErrorLog__c();
					String msg = r.getErrors()[0].getMessage();
					el.Message__c=msg.substring(0,msg.length()<254?msg.length():254);
					el.Job__c='lead Convertierung';
					el.Component__c='lead';
					el.ErrorIdText__c='failed bei der lead konvertierung...';
					el.LogLevel__c='error';
					elArray.add(el);
				}
				else
					contactIds.add(r.getContactId());
			}
			try {
				if(!elArray.isEmpty())
					insert elArray;
			}
			catch(exception e) {}
	
			list<Contact> contactArray = new list<Contact>([select id, toActivate__c from Contact where Id IN: contactIds]);
			for(Contact c:contactArray) {
				c.toActivate__c = true;
			}
			if(!contactArray.isEmpty())
				update contactArray;
			
		}
	}
}