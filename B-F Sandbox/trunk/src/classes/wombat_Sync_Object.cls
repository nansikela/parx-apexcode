global class wombat_Sync_Object {
	public boolean Success { get; set; }
	public List<String> Messages { get; set; }
	public Integer totalSize { 
		get { 
			if (this.Messages == null) {
				return 0;
			} else {
				return this.Messages.size();
			}
		} 
	}
	public List<wombat_Sync_Item> Items { get; set; }
	public Integer totalItems {
		get {
			if (this.Items == null) {
				return 0;
			} else {
				return this.Items.size();
			}
		}
	}
	
	public wombat_Sync_Object() {
		this.Success = true;
		this.Messages = new List<String>();
		this.Items = new List<wombat_Sync_Item>();
	}
}