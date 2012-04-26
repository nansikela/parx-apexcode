global class wombat_Sync_Item {
	public String Object_API_Name { get; set; }
	public List<String> ColumnNames { get; set; }
	public List<String> ColumnValues { get; set; }
	public Integer totalSize { 
		get {
			if (this.records == null) { 
				return 0;
			} else {
				return this.records.size();
			}
		}
	}
	
	public List<sObject> records { get; set; }
	
	public wombat_Sync_Item() {
		this.Object_API_Name = '';
		this.ColumnNames = new List<String>();
		this.ColumnValues = new List<String>();
		this.records = new List<sObject>();
	}
}