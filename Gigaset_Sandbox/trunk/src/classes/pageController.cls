//  Copyright (c) 2009, David Van Puyvelde, Sales Engineering, Salesforce.com Inc.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  Neither the name of the salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

public class pageController {

	public Page__c page {get;set;}
	public Transient Integer expires {get;set;}
	public String pagetemplatename {get;set;}
	public String defaultlanguage {get;set;}

	public pageController() {
		//if (SystemSettings.isPro)
		//	defaultlanguage=SystemSettings.setLanguage();
		//else	
		//	defaultlanguage=System_Settings.setLanguage();
		
		String pageid = System.currentPageReference().getParameters().get('pageid');
		
		String portal='de';
		defaultlanguage='de';
		Boolean isPro=false;
		Id homepageid;
		
		if (pageid!=null && pageid!='null') {
			for (Pages__c p: Pages__c.getAll().values()) {
					if (p.PageId__c!=null && Id.ValueOf(p.PageId__c)==Id.ValueOf(pageid)) {
						portal=p.Portal__c;
						isPro=p.isPro__c;
					}
					if (p.Portal__c==portal && p.IsActive__c && p.isPro__c==isPro && p.Label__c=='Home')
						homepageid=p.PageId__c;
			}
				
			for (GlobalSettings__c gs:GlobalSettings__c.getAll().values()) {
				if (gs!=null && gs.Portal__c==portal && gs.isPro__c==isPro && gs.Sprache__c!=null) defaultlanguage=gs.Sprache__c;
			}
		}
		System.debug('pageController pageid: ' + pageid);
		if (pageid==null || pageid=='null' ) pageid=homepageid;
		try {
			page = [Select  p.PageTemplate__r.VisualForce_Page_Name__c, p.PageTemplate__c, p.PageTemplate__r.Name, p.Name, p.Cache_expires__c, p.Id
				From Page__c p where id =:pageid];
			pagetemplatename = page.PageTemplate__r.VisualForce_Page_Name__c;
			//set the caching expiry
			if(page.Cache_expires__c != null) {
				Double dexp = page.Cache_expires__c;
				expires = dexp.intValue();
			}
			else {
				expires = 600;
			}
			system.debug(pagetemplatename);
			//workaround for bug #W-638516
			System.currentPageReference().getParameters().put('pagetemplatename', pagetemplatename);
		}
		catch(QueryException qe) {
			pagetemplatename = 'Id error :';
			Apexpages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, 'No page found for page id ' + pageid));
			system.debug('No page found for page id ' + pageid);
		}
	}
	
	
	
	private static testMethod void t1() {
		
		//set up a test template
		PageTemplate__c template = new PageTemplate__c(Name='test', VisualForce_Page_Name__c='TestTemplate');
		insert template;
		//set up a test page
		Page__c pg = new Page__c(Name='testpage', PageTemplate__c = template.Id);
		insert pg;
		
		PageReference pr = Page.page;
		pr.getParameters().put('pageid', pg.Id);
		Test.setCurrentPageReference(pr);
		
		pageController pc = new pageController();
		
		System.assertEquals(pc.pagetemplatename, 'TestTemplate');		
		
		//create a controller with no pageid parameter
		pr.getParameters().remove('pageid');
		
		pageController pc2 = new pageController();
		System.assertEquals(pc2.pagetemplatename, 'Id error :');
		
	}

}