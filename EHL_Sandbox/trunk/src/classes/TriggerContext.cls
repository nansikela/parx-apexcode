public with sharing class TriggerContext {
	private static boolean isAddressUpdated = false;
	private static boolean isAccountUpdated = false;
	private static boolean isContactUpdated = false;
	private static boolean isBatchjob = false;
	
	//setter
	public static void setAddressIsUpdated() {
        System.debug('**** TriggerContext set addressUpdated to true');
		isAddressUpdated = true;
	}	
	
	public static void setAccountIsUpdated() {
        System.debug('**** TriggerContext set accountUpdated to true');
		isAccountUpdated = true;
	}	
	
	public static void setContactIsUpdated() {
        System.debug('**** TriggerContext set contactUpdated to true');
		isContactUpdated = true;
	}
	
	public static void setIsBatchjob() {
        System.debug('**** TriggerContext set isBatchjob to true');
		isBatchjob = true;
	}
	
	
	//getter
	public static boolean getIsAddressUpdated() {
		return isAddressUpdated;
	}	
	
	public static boolean getIsAccountUpdated() {
		return isAccountUpdated;
	}	
	
	public static boolean getIsContactUpdated() {
		return isContactUpdated;
	}
	
	public static boolean getIsBatchjob() {
		return isBatchjob;
	}
	
	//reset scope ==> used in test class
	public static void reset() {
		isAddressUpdated = false;
		isAccountUpdated = false;
		isContactUpdated = false;
	}
}