function Beforeunload()
{
	top.fromIframe();
	//return "Any string value here forces a dialog box to \n" + 
      //   "appear before closing the window.";
}
window.onbeforeunload = Beforeunload;