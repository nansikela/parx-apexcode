public class FASearchSeminar {

	String query = 'SELECT ID, Seminar__c, seminar__r.id, Seminar__r.Seminarbeginn__c, Ort__c, Seminar__r.Seminarende__c, seminar__r.Trainer__c , seminar__r.Trainer__r.Firstname, seminar__r.Trainer__r.Lastname, seminar__r.CO_Trainer__c, seminar__r.CO_Trainer__r.Firstname, seminar__r.CO_Trainer__r.Lastname, seminar__r.Restpl_tze__c, Portfolio__r.url__c, Portfolio__r.seminartitel__c FROM Seminar_to_Portfolio__c WHERE Seminar__r.Anzeige_Auf_website__c = true';
	
	public FASearchSeminar()
	{
		String ort = WebURLEncoder.decodeParam('ort');	
		String region = WebURLEncoder.decodeParam('region');
		String q = WebURLEncoder.decodeParam('q');
		
		if(ort != '')
		{
			query += ' AND ort__c = \''+ort+'\' ';
		}
	}

}