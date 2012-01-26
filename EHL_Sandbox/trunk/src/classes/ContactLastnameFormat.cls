public class ContactLastnameFormat {
	
	/**
	 * exceptionWords: These words will be spelled as the way they were registered
	 * exceptionPrefixes: If a word starts with one of these, this part is replaced by the registered prefix,
	 * 					  the next letter is changed to upper case and the rest is changed to lower case 
	 */ 
	private static String[] exceptionWords = new String[] {'am','an','auf','im','vom','von','der','zu','zum','zur','of','de','del','las','les','los','y','ten','ter','van','a','da','das','de','dos','af','av','von','\'t', 'PhD'};
	//private static String[] exceptionPrefixes = new String[] {'t\'','O\'','Van','Mc'};
	private static String[] exceptionPrefixes = new String[] {'t\'','O\'','Mc'};
	
	/**
	 * Handle a list of contacts (format all last names)
	 *
	 */
	public Boolean formatContacts(List<Contact> contactList)
	{
		Boolean success = false;
		try
		{
			for(Contact c : contactList)
			{
				c.LastName = capitalizePhrase(c.LastName);
			}
			success = true;   
		}
		catch (System.Exception e)
		{
			System.debug('***** Exception occured: ' + e);
		}
		return success;
	}

	
	/**
	 * Handle a list of words (phrase)
	 * Capitalize each word and remove multiple spaces
	 *
	 */
	private String capitalizePhrase(String phrase)
	{
		String formattedPhrase = '';
		
		String[] words = phrase.replaceAll('[\\s]{2,}', ' ').split('\\s');
		for (String word : words)
		{
			formattedPhrase += capitalizeWord(word) + ' '; 
		}
		return formattedPhrase.trim();
	}
	
	
	/**
	 * Capitalize one word
	 *
	 */
	private String capitalizeWord(String word)
	{
		// all to lower case
		String formattedWord = word.trim().toLowerCase();
		
		// handle hyphen (recursion)
		if (formattedWord.contains('-') && formattedWord.indexOf('-') > 0 )
		{
			String[] wordAtoms = formattedWord.split('-');
			formattedWord = '';
			for (String atom : wordAtoms)
			{
				formattedWord += capitalizeWord(atom) + '-';
			}
			return formattedWord.substring(0, formattedWord.length()-1);
		}
		
		// search through exception words
		for (String e : exceptionWords)
		{
			if (formattedWord.equalsIgnoreCase(e))
			{
				return e;
			}
		}
		
		// search through exception prefixes
		for (String e : exceptionPrefixes)
		{
			if (formattedWord.startsWith(e.toLowerCase()))
			{
				// replace prefix and capitalize rest
				Integer prefixLength = e.length();
				return e + formattedWord.substring(prefixLength, prefixLength+1).toUpperCase() + formattedWord.substring(prefixLength+1).toLowerCase(); 
			}
		}
		
		// if not yet returned, just set first letter to upper case
		return formattedWord.substring(0, 1).toUpperCase() + formattedWord.substring(1);
	}

}