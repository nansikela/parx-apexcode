public class FallTriggerHelperUpdateTimecards {

	// we get a list of falls and select for them the most ancient date
	// for this date we select all the coaching timecards for this list of falls
	// then we just do an update on the timecards to set the prices right
	private static DateTime minimumDate=System.now();
	private static list<Timecard__c> timecardstoupdate=new list<Timecard__c>();
	
	public static void changeTimecardPrices(map<Id, Fall__c> fmap) {
		setMinimumDate(fmap);
		getCoachingTimecards(fmap);
		updateCoachingTimecards();
	}
	
	private static void setMinimumDate(map<Id, Fall__c> fmap) {
		Date mdate=System.today();
		Time midnight=Time.newInstance(0, 0, 0, 0);
		for (Fall__c f: fmap.values()) {
			if (f.Datum_Fallkategorie_Aenderung__c!=null && f.Datum_Fallkategorie_Aenderung__c<mdate) mdate=f.Datum_Fallkategorie_Aenderung__c;
		}
		minimumDate=DateTime.newInstance(mdate,midnight);
	}
	
	private static void getCoachingTimecards(map<Id, Fall__c> fmap) {
		try {
			map<Id, Timecard__c> tcmap= new map<Id, Timecard__c>();
			for (Timecard__c tc: [SELECT Id, Fall__c, TCFallkategorie__c FROM Timecard__c 
							WHERE Fall__c IN :fmap.keySet()
							AND von__c>=:minimumDate
							AND Aktivitaet__c IN: systemHelper.getMapCoachingActivity().values()
							]) {
				tc.TCFallkategorie__c=fmap.get(tc.Fall__c).Fallkategorie__c;
				if (!tcmap.containsKey(tc.id)) tcmap.put(tc.id,tc);
			}
			if (!tcmap.isEmpty()) timecardstoupdate=tcmap.values();
		} catch (System.Queryexception e) {
			systemHelper.logError(e.getMessage(), 'FallTriggerHelperUpdateTimecards', 'getCoachingTimecards', String.valueOf(fmap.size()));
		}
	}
	
	private static void updateCoachingTimecards() {
		if (!timecardstoupdate.isEmpty()) {
			try {
				update timecardstoupdate;
			} catch (System.Dmlexception e) {
				systemHelper.logError(e.getMessage(), 'FallTriggerHelperUpdateTimecards', 'updateCoachingTimecards', timecardstoupdate.get(0).Fall__c);
			}
		}
	}
}