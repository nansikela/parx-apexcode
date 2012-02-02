public with sharing class JahresAbschlussPage {

	String batchidFaktura='';
	String batchidAccounts='';
	String batchidArtikel='';
	Integer batchcounter=3;
	public String debugmsg {get; set;}
		
	public Boolean showWait { get; private set; }
	public Boolean showFinish { get; private set; }
	public Boolean showConfirm { get; private set; }
	public String pleasewait { get; private set; }
	public String finished { get; private set; }
	public Boolean debug { get; private set; }
	private String successstatus='Erfolgreich abgeschlossen';

	public JahresAbschlussPage() {
		debugmsg='';
		debug=true;
		showConfirm=true;
		showWait=false;
		showFinish=false;
		pleasewait='Bitte warten, Fakturierlauf ist noch nicht abgeschlossen ...';
		finished='Jahresabschluss beendet mit Status: ';
	}
	
	public PageReference noaction() {
		return null;
	}
	
	public PageReference confirmed() {
		showConfirm=false;
		showWait=true;
		showFinish=false;
		return null;
	}

	public PageReference init() {
		if (showFinish) return null;
		if (batchidFaktura=='') {
			batchidFaktura=OpportunityStockAndInvoicingRun.fakall();
			if (batchidFaktura=='' || batchidFaktura==null) {
				showWait=false;
				ApexPages.Message errormsg=new ApexPages.Message(ApexPages.Severity.FATAL, 'Fakturierlauf nicht gestartet!');
				ApexPages.addMessage(errormsg);
			}
			pleasewait='Bitte warten, Fakturierlauf ' + batchidFaktura + ' ist noch nicht abgeschlossen. Lassen Sie bitte dieses Fenster geöffnet!';	 
		}
		if (batchcounter==3) {
			if (checkBatchStatus(batchidFaktura)) {
				pleasewait='Bitte warten, Jahresabschluss läuft ...';
				list<String> ids=JahresAbschlussBatchStart.start();
				
				if (ids.size()==2) {
					batchcounter--;
					batchidAccounts=ids.get(0);
					batchidArtikel=ids.get(1);
				} else {
					batchcounter=-1;
					showWait=false;
					ApexPages.Message errormsg=new ApexPages.Message(ApexPages.Severity.FATAL, 'Jahresabschlusslauf nicht gestartet!');
					ApexPages.addMessage(errormsg);
				}
			}
		} else if (batchcounter==2) {
			debugmsg='batchid Accounts: ' + batchidAccounts + ' // batchid Artikel: ' + batchidArtikel;
			if (batchidAccounts!=null && batchidAccounts!='' && batchidArtikel!=null && batchidArtikel!='') {
				
				if (checkBatchStatus(batchidAccounts) && checkBatchStatus(batchidArtikel)) {
					batchcounter=0;
					showWait=false;
					showFinish=true;
				}
			}
		} else if (batchcounter<0) {
			showWait=false;
		}
		return null;
	}

	private Boolean checkBatchStatus(String bid) {
		if (bid!='' && bid!=null) {
			AsyncApexJob a;
			try {
				a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
				TotalJobItems, CreatedBy.Email
				from AsyncApexJob where Id =
				:bid];
			} catch (System.Queryexception e) {
				SystemSettings.logError(e.getMessage());
				debugmsg+='Batchid: ' + bid +' // ';
			}
			
			if (a!=null && (a.Status=='Completed' || a.Status=='Aborted')) {
				if (a.Status=='Aborted') successstatus='Abgebrochen';
				finished += successstatus;
				return true;
			} else
				return false;
		} else {
			return false;
		}
	}

	public String getCurrentOrLastYear() {
		String currentOrLastYear='';
		currentOrLastYear=system.today().month()==1?String.valueOf(system.today().year()-1):String.valueOf(system.today().year());
		return currentOrLastYear;
	}

}