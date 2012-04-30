public class INFW_Stateful {
// Static variables are local to the context of a Web request
// (or testMethod during a runTests call)
// Therefore, this variable will be initialized as false
// at the beginning of each Web request which accesses it.
	private static boolean alreadyCreated = false;
	public static boolean hasAlreadyCreated() {
		return alreadyCreated;
	}
	// By setting the variable to true, it maintains this
	// new value throughout the duration of the request
	// (or testMethod)
	public static void setAlreadyCreated() {
		alreadyCreated = true;
		system.debug('setting helper');
	}
	public static void cancelAlreadyCreated() {
		alreadyCreated = false;
		system.debug('setting cancel helper');
	}

}