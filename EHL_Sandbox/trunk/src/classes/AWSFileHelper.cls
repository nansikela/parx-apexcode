public class AWSFileHelper
{
	private Boolean interactiveMode = true; // interactive mode in VisualForce, else Webservice mode
	
	private String AWSCREDENTIALNAME = 'EHL S3';
	private final String BUCKETNAME = 'aemm.fileupload';
	private Set<String> enrollmentCategories;
	private Id relatedEnrollmentId;
	private Id RT_APPLICATION_DOC = Preferences__c.getInstance('RT_APPLICATION_DOC').Value__c;//'012P0000000Clrh';
	private Id RT_ENROLLMENT_DOC = Preferences__c.getInstance('RT_ENROLLMENT_DOC').Value__c;//'012P0000000Clrw';
	private S3.AmazonS3 as3;
	
	public List<awsFile> awsFileList {get;set;}
	public String aemmLoginId {get;set;}
	public String applicationId {get;set;}
	public S3.ListEntry[] fileList {get;set;}  
	public String errorMsg {get;set;}
	
	public Boolean hasFiles {get;set;}
	public Integer fileCount {get;set;}
	
	public String fileName {get;set;} //used to retrieve file
	
	/**
	 * Constructor without arguments
	 * Used in VisualForce page.
	 */
	public AWSFileHelper()
	{
		// set mode
		this.interactiveMode = true;
		
		// reset error message
		this.errorMsg = '';
		
		// check AEMM id
		if (ApexPages.currentPage().getParameters().get('aemmId') != null)
		{
			this.aemmLoginId = ApexPages.currentPage().getParameters().get('aemmId');
		}
		else
		{
			this.aemmLoginId = '-1';
			this.errorMsg = 'AEMM Login must be provided in URL';
		}
		
		//check applicaiton id
		if (ApexPages.currentPage().getParameters().get('appId') != null)
		{
			this.applicationId = ApexPages.currentPage().getParameters().get('appId');
		}
		else
		{
			this.applicationId = '-1';
			this.errorMsg = 'Application Id must be provided in URL';
		}
		
		// at least one param not provided -> thorw error
		if (this.errorMsg.length() > 0)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, this.errorMsg));
			System.debug('**** errorMsg: ' + this.errorMsg);
		}
		// all good -> init
		else
		{
			// initialize
			init();
		}
	}
	
	/**
	 * Constructor with arguments
	 * Used in Webservice mode
	 */
	public AWSFileHelper(String aemmId, Id applicationId)
	{
		// set mode
		this.interactiveMode = false;
		
		// store attributes to members
	  	this.aemmLoginId = aemmId;
		this.applicationId = applicationId;
		
		// initialize
		init();
	}
		
		
	/**
	 * Initalize public member fileList by fetching data from AWS
	 * 
	 * This method is called when used in Visualforce page.
	 * Same methods for webservice use is initWebservice()
	 */
	public void init()
	{
		// initialize aws connector
		AWSKeys credentials = new AWSKeys(AWSCREDENTIALNAME);
		this.as3 = new S3.AmazonS3(credentials.key,credentials.secret);
		
		try
		{
			Datetime now = Datetime.now();
			Integer maxNumberToList = null; //Set the number of Objects to return for a specific Bucket
			String Prefix = aemmLoginId + '/'; //Limits the response to files and folders from this user
			String Marker = null; //Indicates where in the bucket to begin listing. The list includes only keys that occur alphabetically after marker. This is convenient for pagination: To get the next page of results use the last key of the current page as the marker. The most keys you'd like to see in the response body. The server might return less than this number of keys, but will not return more. This is an optional argument.
			String Delimiter = null;
			
			// fetch object list from s3
			S3.ListBucketResult objectsForBucket = as3.ListBucket(BUCKETNAME, Prefix, Marker,maxNumberToList, Delimiter,as3.key,now,as3.signature('ListBucket',now),as3.secret);
			System.debug('**** bucket: ' + objectsForBucket);
			
			// there is something
			if (objectsForBucket != null)
			{
				fileList = objectsForBucket.Contents;
				if(fileList != null)
				{
					fileCount = fileList.size();
					hasFiles = !fileList.isEmpty();
				}
				else
				{
					fileCount = 0;
					hasFiles = false;
				}
			}
			// no file found
			else
			{
				fileCount = 0;
				hasFiles = false;
			}
			
			// get related enrollment object (if available)
			List<Enrollment__c> relatedEnrollments = [select Id from Enrollment__c where Application__c = :applicationId];
			if (relatedEnrollments.size() > 0)
			{
				this.relatedEnrollmentId = relatedEnrollments[0].Id;
			}
			
			// get enrollment categories
			this.enrollmentCategories = new Set<String>();
			Map<String, EnrollmentDocumentCategory__c> allCategories = EnrollmentDocumentCategory__c.getAll();
			for (String key : allCategories.keySet())
			{
				System.debug('**** key: ' + key);
				EnrollmentDocumentCategory__c edc = allCategories.get(key); 
				System.debug('**** edc: ' + edc);
				this.enrollmentCategories.add(edc.Name);
			}
			
		}
		catch(System.CalloutException callout)
		{
			System.debug('**** CALLOUT EXCEPTION: ' + callout);
			if (this.interactiveMode)
			{
				ApexPages.addMessages(callout);
			}
		}
		catch(Exception ex)
		{
			System.debug('**** EXCEPTION: ' + ex);
			if (this.interactiveMode)
			{
				ApexPages.addMessages(ex);
			}
		}
	}
	
	/**
	 * Parse member fileList into member awsFileList
	 * 
	 * Used to parse path aemmLoginId/category/file.
	 */
	private void parseFileStructure()
	{
		// init vars
		this.awsFileList = new List<awsFile>();
		
		// skip if no files available
		if (this.fileList != null)
		{
			// loop fileList entries
			for(S3.ListEntry file : fileList)
			{
				List<String> path = file.Key.split('/');
				
				// require exactly 3 path items
				if(path.size() == 3 )
				{
					//is file in two folders
					String fileName = path[2];
					String[] fileNamePoints = fileName.split('\\.');
					System.debug('**** fileNamePoints ' + fileNamePoints);
					System.debug('**** fileNamePoints s ' + fileNamePoints.size());
					String fileType = '';
					
					if (fileNamePoints.size() > 0)
					{
						fileType = fileNamePoints[fileNamePoints.size()-1];
						if(fileType.length() > 10)
						{
							fileType = '';
						}
					}
					System.debug('**** file prop ' + file.key + '; ' + fileName + '; ' + fileType + '; ' + path[1] + '; ' + file.LastModified);
					
					// create new awsFile using parsed values
					this.awsFileList.add(new awsFile(file.key, fileName, fileType, path[1], file.LastModified));
				}
			}
		}
	}
	
	/**
	 * Parses path for this user and creates SF objects
	 * 
	 */
	public PageReference writeToSalesforce()
	{
		// init vars
		PageReference returnPage = null;
		
		// parse fileList if not yet done
		if (this.awsFileList == null)
		{
			parseFileStructure();
		}
		
		System.debug('***** The following enrollment categories were found: ' + this.enrollmentCategories);
		System.debug('***** The following enrollment categories were found: ' + EnrollmentDocumentCategory__c.getAll());
		
		// require application id and files
		if (this.applicationId != '-1' && this.awsFileList!=null )
		{
			// create map of existing applicaiton_documents (existing in sfdc)
			Map<String, Application_Document__c> existingAppDocsMap = new Map<String, Application_Document__c>();
			List<Application_Document__c> appDocSFList = [Select a.Category__c, a.Type__c, a.Title__c, a.Path__c, a.Last_Modified_Date__c, a.Id, a.Application__c, a.RecordTypeId From Application_Document__c a where a.Application__c = :this.applicationId];
			for(Application_Document__c a : appDocSFList ){
				existingAppDocsMap.put(a.Path__c, a);
			}
			
			// init lists
			List<Application_Document__c> docToInsert = new List<Application_Document__c>();
			List<Application_Document__c> docToUpdate = new List<Application_Document__c>();
			List<Application_Document__c> docToDelete = new List<Application_Document__c>();
			
			System.debug('***** Start processing aws files.');
			
			// loof aws files
			for (awsFile f : this.awsFileList)
			{
				Boolean doInsert = true;
				Boolean doUpdate = false;
				Id recordTypeId = null;
				Id enrollmentId = null;
				
				Application_Document__c oldAppDoc;
				
				System.debug('***** Scanning file ' + f.path + '/' + f.title + '...');
				
				// check for enrollment category
				if (this.relatedEnrollmentId != null && this.enrollmentCategories.contains(f.category))
				{
					recordTypeId = RT_ENROLLMENT_DOC;
					enrollmentId = this.relatedEnrollmentId;
				}
				else
				{
					recordTypeId = RT_APPLICATION_DOC;
					enrollmentId = null;
				}
				
				// this file exists in sfdc as appication_document
				if(existingAppDocsMap.containsKey(f.path))
				{
					doInsert = false;
					oldAppDoc = existingAppDocsMap.get(f.path);
					
					// no changes to meta data -> nop
					if (oldAppDoc.Type__c == f.fileType
						&& oldAppDoc.Title__c == f.title
						&& oldAppDoc.Path__c == f.path
						&& oldAppDoc.Category__c == f.category
						&& oldAppDoc.Last_Modified_Date__c == f.lastModifiedDate
						&& oldAppDoc.recordTypeId == recordTypeId){
						//do nothing, is still the same
					}
					// metadata changed, request update
					else
					{
						doUpdate = true;
					}
					
					// remove this file from map of existing application_documents
					existingAppDocsMap.remove(f.path);
				}
				System.debug('***** ...doinsert: ' + doInsert + ', doUpdate: ' + doUpdate);
				
				// create application_document to be inserted
				if (doInsert)
				{
					Application_Document__c d = new Application_Document__c();
					d.Application__c = applicationId;
					d.Type__c = f.fileType;
					d.Title__c = f.title;
					d.Path__c = f.path;
					d.Category__c = f.category;
					d.Last_Modified_Date__c = f.lastModifiedDate;
					d.RecordTypeId = recordTypeId;
					d.Enrollment__c = enrollmentId;
					docToInsert.add(d);
				}
				// create application_document to be updated
				else if(doUpdate && oldAppDoc != null)
				{
					Application_Document__c d = new Application_Document__c(Id=oldAppDoc.Id);
					d.Type__c = f.fileType;
					d.Title__c = f.title;
					d.Path__c = f.path;
					d.Category__c = f.category;
					d.Last_Modified_Date__c = f.lastModifiedDate;
					d.RecordTypeId = recordTypeId;
					d.Enrollment__c = enrollmentId;
					docToUpdate.add(d);
				}
			}
			
			// try perfoming CRUD opteration
			try
			{
				System.debug('***** Files to insert: ' + docToInsert);
				System.debug('***** Files to update: ' + docToUpdate);
				
				// perform bulk insert and update to sfdc
				insert docToInsert;
				update docToUpdate;
				
				// there are remaining entries in the existing applicaiton_document map
				if(existingAppDocsMap.size() > 0)
				{
					// remaining items need to be deleted in sfdc
					for(String keyPath : existingAppDocsMap.keySet())
					{
						docToDelete.add(existingAppDocsMap.get(keyPath));
					}
					System.debug('***** Files to delete: ' + docToDelete);
					delete docToDelete;
				}
			}
			catch(System.Exception e)
			{
				System.debug('DML EXCEPTION: ' + e);
				if (this.interactiveMode)
				{
					ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
				}
			}
			if (this.interactiveMode)
			{
				returnPage = new PageReference('/' + applicationId);
			}
		}
		// missing application id or no files available
		else
		{
			if (this.interactiveMode)
			{
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'ApplicationId not valid or no files available.'));
			}
			System.debug('****** ERROR: ApplicationId not valid or no files available.');
		}
		
		return returnPage;
	}
	
	
	/**
	 * Inner Class awsFile
	 *
	 */
	public class awsFile
	{
		public String path {get; set;}
		public String title {get; set;}
		public String fileType {get; set;}
		public String category {get; set;}
		public Datetime lastModifiedDate {get; set;}
		
		public awsFile (String pPath, String pTitle, String pFileType, String pCategory, Datetime pLastModifiedDate)
		{
			path = pPath;
			title = pTitle;
			fileType = pFileType ;
			category = pCategory;
			lastModifiedDate = pLastModifiedDate;
		}
	}
	
}